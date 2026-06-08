//
//  ICS3UCulminatingApp.swift
//  ICS3UCulminating
//
//  Created by Savannah Ho Lung on 2026-06-01.
//

import SwiftUI

// MARK: - ICS3UCulminatingApp
// This is the main entry point of the app. 
// It defines the root "Scene" of the application, which in this case is a single window
// containing our SimonView.
@main
struct ICS3UCulminatingApp: App {
    
    // The 'body' property defines the content of the app's windows.
    var body: some Scene {
        WindowGroup {
            // We set SimonView as the very first screen the user sees.
            SimonView()
        }
    }
}
