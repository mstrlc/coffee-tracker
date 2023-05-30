//
//  TimerView.swift
//  coffeetracker
//
//  Created by Matyáš Strelec on 09/03/2023.
//

import SwiftUI

struct TimerView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @State private var stopwatchRunning = false
    @State private var timer: Timer?
    @State private var stopwatchTime: Float = 0.0
    @State private var selectedBrew: Brew?
    @State private var isSheetPresented = false

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text(formatBrewTime(stopwatchTime))
                    .font(.system(size: 36, weight: .black))
                    .monospaced()
                HStack {
                    Button {
                        toggleTimer()
                    } label: {
                        HStack {
                            if stopwatchRunning {
                                Image(systemName: "pause")
                                Text("Pause")
                            } else {
                                Image(systemName: "play")
                                Text("Start")
                            }
                        }
                    }
                    Button {
                        resetTimer()
                    } label: {
                        HStack {
                            Image(systemName: "gobackward")
                            Text("Reset")
                        }
                    }
                }
                Button {
                    saveBrew()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save")
                    }
                }
                Spacer()
            }
            .buttonStyle(.borderedProminent)
            .navigationTitle("Timer")

        }
        .sheet(
            item: $selectedBrew,
            onDismiss: {
                stopwatchTime = 0.0
            }
        ) { brew in
            BrewDetailView(brew: getBinding(for: brew))
        }
    }

    private func toggleTimer() {
        stopwatchRunning.toggle()
        if stopwatchRunning {
            timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { _ in
                stopwatchTime += 0.001
            }
        } else {
            timer?.invalidate()
        }
    }

    private func resetTimer() {
        timer?.invalidate()
        stopwatchTime = 0
        stopwatchRunning = false
    }

    private func formatBrewTime(_ time: Float) -> String {
        let min = Int(time / 60)
        let sec = Int(time.truncatingRemainder(dividingBy: 60))
        let ms = Int((time.truncatingRemainder(dividingBy: 1)) * 1000)

        let formattedMin = String(format: "%02d", min)
        let formattedSec = String(format: "%02d", sec)
        let formattedMs = String(format: "%03d", ms)

        return "\(formattedMin):\(formattedSec).\(formattedMs)"
    }

    private func saveBrew() {
        let newBrew = Brew(context: viewContext)

        newBrew.dateTime = Date()
        newBrew.time = stopwatchTime

        do {
            try viewContext.save()
            selectedBrew = newBrew
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func getBinding(for brew: Brew) -> Binding<Brew> {
        return Binding<Brew>(
            get: { brew },
            set: { newValue in
                brew.dateTime = newValue.dateTime
                brew.time = newValue.time
                try? viewContext.save()
            }
        )
    }
}
