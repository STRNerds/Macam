//
//  MacamApp.swift
//  Macam
//
//  Created by Ethan Xu on 2024-04-07.
//

import SwiftUI

@main
struct MacamApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        Settings {
            SettingsView()
        }
        .windowResizability(.contentMinSize)
    }
}
