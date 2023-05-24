//
//  coffeetrackerApp.swift
//  coffeetracker
//
//  Created by Matyáš Strelec on 25/05/2023.
//

import SwiftUI

@main
struct coffeetrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
