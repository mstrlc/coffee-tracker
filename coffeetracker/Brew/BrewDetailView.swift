//
//  BrewDetailView.swift
//  coffeetracker
//
//  Created by Matyáš Strelec on 26/05/2023.
//

import SwiftUI

struct BrewDetailView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @State private var selectedBean: Bean?
    @State private var selectedDateTime: Date?

    @Binding var brew: Brew

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Bean.name, ascending: false)],
        animation: .default
    )

    private var beans: FetchedResults<Bean>

    let rowHeight: CGFloat = 70

    var body: some View {
        Form {
            Section("Beans") {
                Picker("Beans", selection: $selectedBean) {
                    Text("None").tag(nil as Bean?)
                    ForEach(beans, id: \.self) { bean in
                        Text(bean.name ?? "").tag(bean as Bean?)
                    }
                }
            }
            .onAppear {
                selectedBean = brew.brewBean
            }
            .onChange(of: selectedBean) { newBean in
                brew.brewBean = newBean
            }
            Section("Date & time") {
                DatePicker(
                    "When",
                    selection: Binding(
                        get: {
                            selectedDateTime ?? brew.dateTime ?? Date()
                        },
                        set: { newDate in
                            selectedDateTime = newDate
                        }
                    ), displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.automatic)
            }
            Section("Brew time") {
                HStack {
                    Text(formatBrewTime(brew.time))
                        .monospaced()

                    Spacer()

                    HStack {
                        Button(action: {
                            brew.time += 1.0
                            brew.time = brew.time.rounded()
                        }) {
                            Image(systemName: "plus")
                        }

                        Button(action: {
                            if brew.time >= 1.0 {
                                brew.time -= 1.0
                                brew.time = brew.time.rounded()
                            }
                        }) {
                            Image(systemName: "minus")
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .buttonStyle(.borderless)
                }
            }
            Section("Weight") {
                VStack {
                    HStack {
                        HStack {
                            TextField(
                                "Coffee",
                                text: Binding(
                                    get: { brew.coffeeWeight ?? "" },
                                    set: { brew.coffeeWeight = $0 }
                                )
                            ).keyboardType(.numberPad)
                            Text(" g")
                        }
                        Divider()
                            .frame(width: 40)
                        HStack {
                            TextField(
                                "Water",
                                text: Binding(
                                    get: { brew.waterWeight ?? "" },
                                    set: { brew.waterWeight = $0 }
                                )
                            ).keyboardType(.numberPad)
                            Text(" g")
                        }
                    }
                }
            }
            Section("Details") {
                VStack {
                    HStack {
                        TextField(
                            "Grinder",
                            text: Binding(
                                get: { brew.grinder ?? "" },
                                set: { brew.grinder = $0 }
                            ))
                        Divider()
                        TextField(
                            "Clicks",
                            text: Binding(
                                get: { brew.clicks ?? "" },
                                set: { brew.clicks = $0 }
                            ))
                    }
                    Divider()
                    TextField(
                        "Method",
                        text: Binding(
                            get: { brew.method ?? "" },
                            set: { brew.method = $0 }
                        ))
                    Divider()
                    TextEditor(
                        text: Binding(
                            get: { brew.notes ?? "" },
                            set: { brew.notes = $0 }
                        )
                    )
                    .frame(height: 80)
                }
            }
            Section("Rating") {
                HStack {
                    Slider(
                        value: Binding(
                            get: { Double(brew.rating ?? "") ?? 5 },
                            set: { brew.rating = String(Int($0)) }
                        ), in: 1...10, step: 1)
                    Text("\(brew.rating ?? "")/10")
                        .monospaced()
                }
            }
        }
        .onAppear {
            selectedDateTime = brew.dateTime
        }
        .onChange(of: selectedDateTime) { newDateTime in
            brew.dateTime = newDateTime
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(brew.brewBean?.name ?? "")
    }

	private func formatBrewTime(_ time: Float) -> String {
		let min = Int(time / 60)
		let sec = Int(time.truncatingRemainder(dividingBy: 60))
		let ms = Int((time.truncatingRemainder(dividingBy: 1)) * 10)

		let formattedMin = String(format: "%02d", min)
		let formattedSec = String(format: "%02d", sec)
		let formattedMs = String(format: "%01d", ms)

		return "\(formattedMin):\(formattedSec).\(formattedMs)"
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
