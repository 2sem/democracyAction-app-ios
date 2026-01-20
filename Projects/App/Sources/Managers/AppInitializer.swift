//
//  AppInitializer.swift
//  democracyaction
//
//  Created by SwiftUI Migration
//

import Foundation

@MainActor
class AppInitializer {
    static func initialize() async throws {
        // Increment launch count (moved from AppDelegate)
        DADefaults.increaseLaunchCount()
        
        // Future initialization will go here:
        // - Database migrations
        // - UserDefaults setup
        // - API configuration
        // - Excel data import if needed
    }
}
