//
//  BeanListView.swift
//  coffeetracker
//
//  Created by Matyáš Strelec on 25/05/2023.
//

import SwiftUI
import CoreData

struct BeanListView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @State private var selectedBean: Bean?
    @State private var isSheetPresented = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Bean.name, ascending: true)],
        animation: .default)
    
    private var beans: FetchedResults<Bean>
    let rowHeight: CGFloat = 70
    
    var body: some View {
        NavigationView {
            List {
                ForEach(beans) { bean in
                    NavigationLink(destination: BeanDetailView(bean: getBinding(for: bean))) {
                        HStack {
                            if let imageData = bean.image, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill) // Adjust the aspect ratio
                                    .frame(width: rowHeight, height: rowHeight) // Set the desired image size
                                    .clipped() // Clip the image to maintain the aspect ratio
                                    .cornerRadius(8) // Add corner radius for a square look
                                    .padding(.trailing, 10)
                            }
                            VStack(alignment: .leading) {
                                Text(bean.name ?? "")
                                    .bold()
                                Text(bean.desc ?? "")
                            }
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Beans")
            .navigationBarTitleDisplayMode(.inline)
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
        .sheet(item: $selectedBean) { bean in
            if let bean = bean {
                BeanDetailView(bean: getBinding(for: bean))
            }
        }
    }
    
    private func getBinding(for bean: Bean) -> Binding<Bean?> {
        return Binding<Bean?>(
            get: { return bean },
            set: { newValue in
                if let updatedBean = newValue {
                    // Update the selected bean with new values
                    bean.name = updatedBean.name
                    // Update other properties as needed
                }
                try? viewContext.save() // Save the changes to Core Data
            }
        )
    }
    
    private func addItem() {
        withAnimation {
            let newBean = Bean(context: viewContext)

            guard let image = UIImage(named: "NoneImage") else {
                fatalError("Failed to load image asset.")
            }

            guard let imageData = image.jpegData(compressionQuality: 1.0) else {
                fatalError("Failed to convert image to JPEG data.")
            }

            newBean.name = ""
            newBean.desc = ""
            newBean.image = imageData

            do {
                try viewContext.save()
                selectedBean = newBean // Set the selectedBean to the newly created bean
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { beans[$0] }.forEach(viewContext.delete)
            
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

struct BeanListView_Previews: PreviewProvider {
    static var previews: some View {
        BeanListView()
    }
}
