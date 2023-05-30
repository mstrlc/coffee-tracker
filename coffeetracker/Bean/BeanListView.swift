//
//  BeanListView.swift
//  coffeetracker
//
//  Created by Matyáš Strelec on 25/05/2023.
//

import CoreData
import SwiftUI

struct BeanListView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @State private var selectedBean: Bean?
    @State private var isSheetPresented = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Bean.name, ascending: true)],
        animation: .default
    )

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
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: rowHeight, height: rowHeight)
                                    .clipped()
                                    .cornerRadius(8)
                                    .padding(.trailing, 10)
                            }
                            VStack(alignment: .leading) {
                                Text(bean.name ?? "None")
                                    .bold()
                                Text(bean.beanRoaster?.name ?? "")
                                Text(bean.tastingNotes ?? "")
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
            .navigationTitle("Beans")
            .navigationBarTitleDisplayMode(.large)
            .onDisappear {
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
        .sheet(item: $selectedBean) { bean in
            BeanDetailView(bean: getBinding(for: bean))
        }
    }

    private func getBinding(for bean: Bean) -> Binding<Bean> {
        return Binding<Bean>(
            get: { bean },
            set: { newValue in
                bean.name = newValue.name
                try? viewContext.save()
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
                selectedBean = newBean
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
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
