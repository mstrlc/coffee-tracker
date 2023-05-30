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
                VStack {
                    Text("Coffee Tracker")
                        .bold()
                        .fontDesign(.rounded)
                        .font(.title).foregroundColor(.accentColor)
                }
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
