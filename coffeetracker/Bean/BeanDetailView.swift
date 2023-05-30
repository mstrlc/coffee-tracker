//
//  BeanDetailView.swift
//  coffeetracker
//
//  Created by Matyáš Strelec on 25/05/2023.
//

import CoreData
import SwiftUI

struct BeanDetailView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @State private var selectedRoaster: Roaster?
    @State private var capturedImage: UIImage?
    @State private var updatedImageData: Data?
    @State private var isShowingImagePicker = false

    @Binding var bean: Bean

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Roaster.name, ascending: true)],
        animation: .default
    )

    private var roasters: FetchedResults<Roaster>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Brew.dateTime, ascending: false)],
        animation: .default
    )

    private var brews: FetchedResults<Brew>

    var imageWidth = 0.8 * UIScreen.main.bounds.width
    let rowHeight: CGFloat = 70

    var body: some View {
        Form {
            Section("Image") {
                if let imageData = updatedImageData ?? bean.image,
                    let uiImage = UIImage(data: imageData)
                {
                    Button(action: {
                        isShowingImagePicker = true  // Show the image picker
                        capturedImage = nil  // Reset captured image
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
                        isShowingImagePicker = true  // Show the image picker
                        capturedImage = nil  // Reset captured image
                    }) {
                        Text("No Image")
                    }
                }
            }
            Section("Name") {
                TextField(
                    "Name",
                    text: Binding(
                        get: { bean.name ?? "" },
                        set: { bean.name = $0 }
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
            Section("Tasting notes") {
                TextField(
                    "Tasting notes",
                    text: Binding(
                        get: { bean.tastingNotes ?? "" },
                        set: { bean.tastingNotes = $0 }
                    ))
            }
            Section("Brews") {
                List {
                    ForEach(brews) { brew in
                        if brew.brewBean == bean {
                            NavigationLink(destination: BrewDetailView(brew: getBinding(for: brew)))
                            {
                                HStack {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(brew.brewBean?.name ?? "None")
                                            Text("–")
                                            Text(brew.brewBean?.beanRoaster?.name ?? "None")
                                        }
                                        .bold()
                                        .lineLimit(1)
                                        Text(formatDate(brew.dateTime))
                                        HStack {
                                            Text(brew.method ?? "None")
                                            Text("–")
                                            Text((brew.rating ?? "0") + " / 10")
                                        }
                                    }
                                }
                            }
                        }
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
        .listStyle(GroupedListStyle())
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePickerView(capturedImage: $capturedImage) { image in
                guard let image = image else { return }
                capturedImage = image

                // Update the bean's image with the selected image
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    bean.image = imageData
                    updatedImageData = imageData  // Update the @State property for refreshing the UI
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(bean.name ?? "")
    }

    private func formatDate(_ date: Date?) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        if let date = date {
            return formatter.string(from: date)
        }
        return "Error formatting date"
    }

    private func getBinding(for bean: Bean) -> Binding<Bean> {
        return Binding<Bean>(
            get: { bean },
            set: { newValue in
                bean.name = newValue.name
                try? viewContext.save()  // Save the changes to Core Data
            }
        )
    }

    private func getBinding(for brew: Brew) -> Binding<Brew> {
        return Binding<Brew>(
            get: { brew },
            set: { newValue in
                brew.dateTime = newValue.dateTime
                try? viewContext.save()  // Save the changes to Core Data
            }
        )
    }
}
