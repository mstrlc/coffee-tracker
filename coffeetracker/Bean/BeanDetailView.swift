//
//  BeanDetailView.swift
//  coffeetracker
//
//  Created by Matyáš Strelec on 25/05/2023.
//

import SwiftUI
import CoreData

struct BeanDetailView: View {
    
    @Binding var bean: Bean
    
    var imageWidth = 0.8*UIScreen.main.bounds.width
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(entity: Roaster.entity(), sortDescriptors: [])
    
    private var roasters: FetchedResults<Roaster>
    
    @State private var selectedRoaster: Roaster?
    
    @State private var isShowingImagePicker = false
    @State private var capturedImage: UIImage?
    @State private var updatedImageData: Data? // New @State property for storing updated image data

    var body: some View {
        NavigationView {
            Form {
                Section("Image") {
                    if let imageData = updatedImageData ?? bean.image, let uiImage = UIImage(data: imageData) {
                        Button(action: {
                            isShowingImagePicker = true // Show the image picker
                            capturedImage = nil // Reset captured image
                        }) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: imageWidth, height: imageWidth)
                                .clipped()
                                .cornerRadius(8)
                                .scaledToFill()
                        }
                    } else {
                        Button(action: {
                            isShowingImagePicker = true // Show the image picker
                            capturedImage = nil // Reset captured image
                        }) {
                            Text("No Image")
                        }
                    }
                }
                Section("Name") {
                    TextField("Name", text: Binding(
                        get: { bean.name ?? "" },
                        set: { bean.name = $0 }
                    ))
                    Text(bean.beanRoaster?.name ?? "")
                }
                Section("Description") {
                    TextField("Description", text: Binding(
                        get: { bean.desc ?? "" },
                        set: { bean.desc = $0 }
                    ))
                }
                Section("Roaster") {
                    Picker("Roaster", selection: $selectedRoaster) {
                        Text("None").tag(nil as Roaster?)
                        ForEach(roasters, id: \.self) { roaster in
                            Text(roaster.name ?? "").tag(roaster as Roaster?)
                        }
                    }
                }
            }
            .onAppear {
                selectedRoaster = bean.beanRoaster
            }
            .onChange(of: selectedRoaster) { newRoaster in
                bean.beanRoaster = newRoaster
            }
            .listStyle(GroupedListStyle()) // Apply a grouped list style
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePickerView(capturedImage: $capturedImage) { image in
                    guard let image = image else { return }
                    capturedImage = image
                    
                    // Update the bean's image with the selected image
                    if let imageData = image.jpegData(compressionQuality: 0.8) {
                        bean.image = imageData
                        updatedImageData = imageData // Update the @State property for refreshing the UI
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
    
}
