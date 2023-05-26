//
//  BrewListView.swift
//  coffeetracker
//
//  Created by Matyáš Strelec on 26/05/2023.
//

import SwiftUI

struct BrewListView: View {
    
    @Environment(\.managedObjectContext) private var viewContext

    @State private var selectedBrew: Brew?
    @State private var isSheetPresented = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Brew.dateTime, ascending: true)],
        animation: .default)
    
    private var brews: FetchedResults<Brew>
    let rowHeight: CGFloat = 70
    

    var body: some View {
        NavigationView {
            List {
                ForEach(brews) { brew in
                    NavigationLink(destination: BrewDetailView(brew: getBinding(for: brew))) {
                        HStack {
//                            if let imageData = brew.image, let uiImage = UIImage(data: imageData) {
//                                Image(uiImage: uiImage)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill) // Adjust the aspect ratio
//                                    .frame(width: rowHeight, height: rowHeight) // Set the desired image size
//                                    .clipped() // Clip the image to maintain the aspect ratio
//                                    .cornerRadius(8) // Add corner radius for a square look
//                                    .padding(.trailing, 10)
//                            }
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(brew.dateTime != nil ? "\(brew.dateTime!)" : "")
                                        .bold()
//                                    Text("\(brew.city ?? ""), \(brew.country ?? "")")
                                }
                                Text("12 brews, 32 total brews")
                            }
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addItem) {
                        Text("Add")
                    }
                }
            }
            .navigationTitle("Brews")
            .navigationBarTitleDisplayMode(.large)
            .onDisappear {
                // Save the viewContext
                do {
                    try viewContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
        .sheet(item: $selectedBrew) { brew in
            if let brew = brew {
                BrewDetailView(brew: getBinding(for: brew))
            }
        }
    }
    
    private func getBinding(for brew: Brew) -> Binding<Brew> {
        return Binding<Brew>(
            get: { return brew },
            set: { newValue in
                brew.dateTime = newValue.dateTime
                try? viewContext.save() // Save the changes to Core Data
            }
        )
    }
    
    private func addItem() {
        withAnimation {
            let newBrew = Brew(context: viewContext)

//            guard let image = UIImage(named: "NoneImage") else {
//                fatalError("Failed to load image asset.")
//            }
//
//            guard let imageData = image.jpegData(compressionQuality: 1.0) else {
//                fatalError("Failed to convert image to JPEG data.")
//            }

            newBrew.dateTime = Date()

            //            newbrew.image = imageData

            do {
                try viewContext.save()
                selectedBrew = newBrew // Set the selectedBean to the newly created bean
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { brews[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct BrewListView_Previews: PreviewProvider {
    static var previews: some View {
        BrewListView()
    }
}
