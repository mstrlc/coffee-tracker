//
//  ContentView.swift
//  coffeetracker
//
//  Created by Matyáš Strelec on 25/05/2023.
//


import SwiftUI
import CoreData

enum ScreensEnum {
    case Beans
    case Roasters
    case Brews
}

struct ContentView: View {
    
    @State var currentScreen: ScreensEnum = .Beans
    
    var body: some View {
        
        TabView(selection: $currentScreen) {
            
            BeanListView()
                .tag(ScreensEnum.Beans)
                .tabItem {
                    VStack {
                        Image(systemName: "bag")
                        Text("Beans")
                    }
                }
            
            RoasterListView()
                .tag(ScreensEnum.Roasters)
                .tabItem {
                    VStack {
                        Image(systemName: "flame")
                        Text("Roasters")
                    }
                }
            
            BrewListView()
                .tag(ScreensEnum.Brews)
                .tabItem {
                    VStack {
                        Image(systemName: "mug")
                        Text("Brews")
                    }
                }
        }
    }
}
