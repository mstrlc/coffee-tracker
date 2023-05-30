//
//  RoasterDetailView.swift
//  coffeetracker
//
//  Created by Matyáš Strelec on 26/05/2023.
//

import SwiftUI

struct RoasterDetailView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @Binding var roaster: Roaster

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Bean.name, ascending: true)],
        animation: .default
    )

    private var beans: FetchedResults<Bean>

    let rowHeight: CGFloat = 70

    var body: some View {
        Form {
            Section("Name") {
                TextField(
                    "Name",
                    text: Binding(
                        get: { roaster.name ?? "" },
                        set: { roaster.name = $0 }
                    ))
            }
            Section("Location") {
                HStack {
                    TextField(
                        "City",
                        text: Binding(
                            get: { roaster.city ?? "" },
                            set: { roaster.city = $0 }
                        ))
                    TextField(
                        "Country",
                        text: Binding(
                            get: { roaster.country ?? "" },
                            set: { roaster.country = $0 }
                        ))
                }
            }
            Section("Beans") {
                List {
                    ForEach(beans) { bean in
                        if bean.beanRoaster == roaster {
                            NavigationLink(destination: BeanDetailView(bean: getBinding(for: bean)))
                            {
                                HStack {
                                    if let imageData = bean.image,
                                        let uiImage = UIImage(data: imageData)
                                    {
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
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(roaster.name ?? "")
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
}
