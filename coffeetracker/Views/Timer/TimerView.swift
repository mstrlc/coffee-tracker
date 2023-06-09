//
//  TimerView.swift
//  coffeetracker
//
//  Created by Matyáš Strelec on 09/03/2023.
//

import Combine
import SwiftUI

struct TimerView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @State private var stopwatchRunning = false
    @State private var stopwatchTime: Float = 0.0
    @State private var selectedBrew: Brew?
    @State private var isSheetPresented = false
    @State private var cancellable: Cancellable?

    private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text(formatBrewTime(stopwatchTime))
                    .font(.system(size: 46, weight: .black))
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
            // Start the timer and use the sink operator to execute the closure for each timer tick
            cancellable = timer.sink { _ in
                stopwatchTime += 0.1
            }
        } else {
            // If the stopwatch is not running, cancel the timer and set cancellable to nil
            cancellable?.cancel()
            cancellable = nil
        }
    }

    private func resetTimer() {
        // Cancel the timer and set cancellable to nil
        cancellable?.cancel()
        cancellable = nil
        stopwatchTime = 0
        stopwatchRunning = false
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
