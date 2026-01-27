//
//  App.swift
//  democracyaction
//
//  SwiftUI App Entry Point
//

import SwiftUI
import SwiftData
import GoogleMobileAds

@main
struct DemocracyActionApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var isSplashDone = false
    @State private var isSetupDone = false
    @StateObject private var adManager = SwiftUIAdManager()
    @Environment(\.scenePhase) private var scenePhase
    @State private var isFromBackground = false
    @State private var isLaunched = false

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
            .environmentObject(adManager)
            .task {
                setupAds()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                handleScenePhaseChange(from: oldPhase, to: newPhase)
            }
        }
        .modelContainer(modelContainer)
    }

    private func setupAds() {
        guard !isSetupDone else { return }

        MobileAds.shared.start { [weak adManager] status in
            guard let adManager = adManager else { return }

            adManager.setup()

            #if DEBUG
            adManager.prepare(interstitialUnit: .full, interval: 60.0)
            adManager.prepare(openingUnit: .launch, interval: 60.0)
            #else
            adManager.prepare(interstitialUnit: .full, interval: 60.0 * 60)
            adManager.prepare(openingUnit: .launch, interval: 60.0 * 5)
            #endif

            adManager.canShowFirstTime = true
        }

        isSetupDone = true
    }

    private func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
        print("scene changed old[\(oldPhase)] new[\(newPhase)]")
        
        switch newPhase {
        case .active:
            if isFromBackground {
                handleAppDidBecomeActive()
            }
            
            isFromBackground = false
            increaseLaunchCount()
        case .inactive:
            break
        case .background:
            isFromBackground = true
            break
        @unknown default:
            break
        }
    }
    
    private func handleAppDidBecomeActive() {
        print("scene become active")
        Task {
            await adManager.requestAppTrackingIfNeed()
            await adManager.show(unit: .launch)
        }
    }
    
    private func increaseLaunchCount() {
        defer {
            isLaunched = true
        }
        
        if !isLaunched {
            DADefaults.increaseLaunchCount()
        }
    }
}
