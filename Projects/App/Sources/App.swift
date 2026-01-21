//
//  App.swift
//  democracyaction
//
//  SwiftUI App Entry Point
//

import SwiftUI
import SwiftData

@main
struct DemocracyActionApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var isSplashDone = false
    
    // SwiftData model container
    let modelContainer: ModelContainer
    
    init() {
        do {
            // Configure SwiftData schema
            let schema = Schema([
                Person.self,
                Group.self,
                Phone.self,
                MessageTool.self,
                Web.self,
                Event.self,
                EventGroup.self,
                EventPerson.self,
                Favorite.self
            ])
            
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            
            print("✅ SwiftData model container initialized")
        } catch {
            fatalError("Failed to initialize SwiftData: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main content - 2 tabs: Politicians and Favorites
                if isSplashDone {
                    MainScreen()
                        .transition(.opacity)
                }
                
                // Splash overlay
                if !isSplashDone {
                    SplashScreen(
                        isDone: $isSplashDone,
                        modelContainer: modelContainer
                    )
                    .transition(.opacity)
                }
            }
        }
        .modelContainer(modelContainer)
    }
}
