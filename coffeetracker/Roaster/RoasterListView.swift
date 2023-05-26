//
//  RoasterListView.swift
//  coffeetracker
//
//  Created by Matyáš Strelec on 26/05/2023.
//

import SwiftUI

struct RoasterListView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @State private var selectedRoaster: Roaster?
    @State private var isSheetPresented = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Roaster.name, ascending: true)],
        animation: .default)
    
    private var roasters: FetchedResults<Roaster>
    let rowHeight: CGFloat = 70
    
    var body: some View {
        NavigationView {
            List {
                ForEach(roasters) { roaster in
                    NavigationLink(destination: RoasterDetailView(roaster: getBinding(for: roaster))) {
                        HStack {
//                            if let imageData = bean.image, let uiImage = UIImage(data: imageData) {
//                                Image(uiImage: uiImage)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill) // Adjust the aspect ratio
//                                    .frame(width: rowHeight, height: rowHeight) // Set the desired image size
//                                    .clipped() // Clip the image to maintain the aspect ratio
//                                    .cornerRadius(8) // Add corner radius for a square look
//                                    .padding(.trailing, 10)
//                            }
                            VStack(alignment: .leading) {
                                Text(roaster.name ?? "")
                                    .bold()
                                Text(roaster.country ?? "")
                                Text(roaster.city ?? "")
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
            .navigationTitle("Roasters")
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
        .sheet(item: $selectedRoaster) { roaster in
            if let roaster = roaster {
                RoasterDetailView(roaster: getBinding(for: roaster))
            }
        }
    }
    
    private func getBinding(for roaster: Roaster) -> Binding<Roaster?> {
        return Binding<Roaster?>(
            get: { return roaster },
            set: { newValue in
                if let updatedRoaster = newValue {
                    // Update the selected bean with new values
                    roaster.name = updatedRoaster.name
                    // Update other properties as needed
                }
                try? viewContext.save() // Save the changes to Core Data
            }
        )
    }
    
    private func addItem() {
        withAnimation {
            let newRoaster = Roaster(context: viewContext)

//            guard let image = UIImage(named: "NoneImage") else {
//                fatalError("Failed to load image asset.")
//            }
//
//            guard let imageData = image.jpegData(compressionQuality: 1.0) else {
//                fatalError("Failed to convert image to JPEG data.")
//            }

            newRoaster.name = ""
            newRoaster.country = ""
            newRoaster.city = ""
//            newRoaster.image = imageData

            do {
                try viewContext.save()
                selectedRoaster = newRoaster // Set the selectedBean to the newly created bean
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { roasters[$0] }.forEach(viewContext.delete)
            
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


struct RoasterListView_Previews: PreviewProvider {
    static var previews: some View {
        RoasterListView()
    }
}
