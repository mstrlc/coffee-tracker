//
//  RoasterDetailView.swift
//  coffeetracker
//
//  Created by Matyáš Strelec on 26/05/2023.
//

import SwiftUI

struct RoasterDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var roaster: Roaster?
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Bean.name, ascending: true)],
        animation: .default)
    private var beans: FetchedResults<Bean>
    let rowHeight: CGFloat = 70


    var body: some View {
        Form {
            Section("Name") {
                TextField("Name", text: Binding(
                    get: { roaster?.name ?? "" },
                    set: { roaster?.name = $0 }
                ))
            }
            Section("Country") {
                TextField("Name", text: Binding(
                    get: { roaster?.country ?? "" },
                    set: { roaster?.country = $0 }
                ))
            }
            Section("Beans") {
                List {
                    ForEach(beans) { bean in
                        if(bean.beanRoaster == roaster) {
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
                                        Text(bean.beanRoaster?.name ?? "")
                                    }
                                }
                            }
                        }
                   }
               }
            }
        }.navigationBarTitleDisplayMode(.inline)
    }
    
    
    private func getBinding(for bean: Bean) -> Binding<Bean> {
        return Binding<Bean>(
            get: { return bean },
            set: { newValue in
                bean.name = newValue.name
                try? viewContext.save() // Save the changes to Core Data
            }
        )
    }
    

}
