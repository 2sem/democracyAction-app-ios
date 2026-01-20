//
//  DemocracyActionApp.swift
//  democracyaction
//
//  Created by SwiftUI Migration
//

import SwiftUI

@main
struct DemocracyActionApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var isSplashDone = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main content will go here after splash
                if isSplashDone {
                    // Placeholder for now - will add MainScreen later
                    Text("Main Screen")
                        .font(.largeTitle)
                        .transition(.opacity)
                }
                
                // Splash overlay
                if !isSplashDone {
                    SplashScreen(isDone: $isSplashDone)
                        .transition(.opacity)
                }
            }
        }
    }
}
