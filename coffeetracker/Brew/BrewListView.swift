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

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Brew.dateTime, ascending: false)],
        animation: .default
    )

    private var brews: FetchedResults<Brew>

    let rowHeight: CGFloat = 70

    var body: some View {
        NavigationView {
            List {
                ForEach(brews) { brew in
                    NavigationLink(destination: BrewDetailView(brew: getBinding(for: brew))) {
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
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
        .sheet(item: $selectedBrew) { brew in
            BrewDetailView(brew: getBinding(for: brew))
        }
    }

    private func formatDate(_ date: Date?) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        if let date = date {
            return formatter.string(from: date)
        }
        return ""
    }

    private func getBinding(for brew: Brew) -> Binding<Brew> {
        return Binding<Brew>(
            get: { brew },
            set: { newValue in
                brew.dateTime = newValue.dateTime
                try? viewContext.save()
            }
        )
    }

    private func addItem() {
        withAnimation {
            let newBrew = Brew(context: viewContext)

            newBrew.dateTime = Date()

            do {
                try viewContext.save()
                selectedBrew = newBrew
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
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
