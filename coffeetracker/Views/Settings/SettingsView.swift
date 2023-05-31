//
//  SettingsView.swift
//  coffeetracker
//
//  Created by Matyáš Strelec on 30/05/2023.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            HStack {
                Image("icon")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .padding(10)
                VStack(alignment: .leading) {
                    Text("Coffee Tracker")
                        .bold()
                        .font(.title)
                        .foregroundColor(.accentColor)
                    Text("Matyáš Strelec")
                        .foregroundColor(.accentColor)
                    Link("mstrlc.eu", destination: URL(string: "https://mstrlc.eu")!)
                        .underline()
                        .foregroundColor(.accentColor)
                }
            }
            .navigationBarTitle("Settings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
