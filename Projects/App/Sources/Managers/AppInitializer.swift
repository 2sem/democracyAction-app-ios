//
//  AppInitializer.swift
//  democracyaction
//
//  Centralizes app initialization logic
//

import Foundation

@MainActor
class AppInitializer {
    
    static func initialize() async throws {
        print("🚀 Initializing app...")
        
        // Increment launch count
        DADefaults.increaseLaunchCount()
        print("✅ Launch count: \(DADefaults.LaunchCount)")
        
        // Add any other initialization here
        // e.g., API configuration, UserDefaults setup, etc.
    }
}
