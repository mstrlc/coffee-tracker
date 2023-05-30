//
//  ContentView.swift
//  coffeetracker
//
//  Created by Matyáš Strelec on 25/05/2023.
//

import CoreData
import SwiftUI

enum ScreensEnum {
    case timer
    case beans
    case roasters
    case brews
    case settings
}

struct ContentView: View {
    @State var currentScreen: ScreensEnum = .timer

    var body: some View {
        TabView(selection: $currentScreen) {
            TimerView()
                .tag(ScreensEnum.timer)
                .tabItem {
                    VStack {
                        Image(systemName: "clock")
                        Text("Timer")
                    }
                }

            BrewListView()
                .tag(ScreensEnum.brews)
                .tabItem {
                    VStack {
                        Image(systemName: "mug")
                        Text("Brews")
                    }
                }

            BeanListView()
                .tag(ScreensEnum.beans)
                .tabItem {
                    VStack {
                        Image(systemName: "bag")
                        Text("Beans")
                    }
                }

            RoasterListView()
                .tag(ScreensEnum.roasters)
                .tabItem {
                    VStack {
                        Image(systemName: "flame")
                        Text("Roasters")
                    }
                }

            SettingsView()
                .tag(ScreensEnum.settings)
                .tabItem {
                    VStack {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
                }
        }
    }
}
