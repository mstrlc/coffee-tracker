//
//  RoasterListView.swift
//  coffeetracker
//
//  Created by Matyáš Strelec on 26/05/2023.
//

import CoreData
import SwiftUI

struct RoasterListView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @State private var selectedRoaster: Roaster?
    @State private var isSheetPresented = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Roaster.name, ascending: true)],
        animation: .default
    )

    private var roasters: FetchedResults<Roaster>

    private let rowHeight: CGFloat = 70

    var body: some View {
        NavigationView {
            List {
                ForEach(roasters) { roaster in
                    NavigationLink(
                        destination: RoasterDetailView(roaster: getBinding(for: roaster))
                    ) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(roaster.name ?? "None")
                                    .bold()
                                    .lineLimit(1)
                                Text((roaster.city ?? "None") + " – " + (roaster.country ?? "None"))
                                Text(getStats(roaster))
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
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
        // When tapping Add, a new sheet opens
        .sheet(item: $selectedRoaster) { roaster in
            RoasterDetailView(roaster: getBinding(for: roaster))
        }
    }

    private func getStats(_ roaster: Roaster) -> String {
        do {
            let fetchRequest: NSFetchRequest<Bean> = Bean.fetchRequest()
            let beans = try viewContext.fetch(fetchRequest)
            
            // Filter the entities where the roaster matches
            let filteredBeans = beans.filter { $0.beanRoaster == roaster }

            let beansCount = filteredBeans.count

            return "Beans: \(beansCount)"
        } catch {
            return "Error retrieving stats"
        }
    }

    private func getBinding(for roaster: Roaster) -> Binding<Roaster> {
        return Binding<Roaster>(
            get: { roaster },
            set: { newValue in
                roaster.name = newValue.name
                try? viewContext.save()
            }
        )
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
            let newRoaster = Roaster(context: viewContext)
            newRoaster.name = ""
            do {
                try viewContext.save()
                selectedRoaster = newRoaster
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
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
