//
//  SplashScreen.swift
//  democracyaction
//
//  Created by SwiftUI Migration
//

import SwiftUI
import SwiftData

struct SplashScreen: View {
    @Binding var isDone: Bool
    let modelContainer: ModelContainer
    
    @StateObject private var migrationManager = DataMigrationManager()
    @State private var showError = false

    var body: some View {
        ZStack {
            Color(red: 0.2, green: 0.4, blue: 0.8) // Brand color
                .ignoresSafeArea()

            VStack(spacing: 30) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)

                VStack(spacing: 12) {
                    Text(migrationManager.currentStep)
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    if migrationManager.migrationStatus == .migrating {
                        ProgressView(value: migrationManager.migrationProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                            .frame(width: 200)
                        
                        Text("\(Int(migrationManager.migrationProgress * 100))%")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.caption)
                    }
                }
            }
        }
        .alert("Migration Error", isPresented: $showError) {
            Button("Retry") {
                Task {
                    await performInitialization()
                }
            }
            Button("Cancel", role: .cancel) {
                // User can cancel and app will continue without migration
                isDone = true
            }
        } message: {
            Text(migrationManager.currentStep)
        }
        .task {
            await performInitialization()
        }
    }

    private func performInitialization() async {
        do {
            migrationManager.currentStep = "Initializing..."
            
            // Initialize app (launch count, etc.)
            try await AppInitializer.initialize()
            
            // Check if Core Data → SwiftData migration is needed
            let migrated = await migrationManager.checkAndMigrateIfNeeded(
                modelContext: modelContainer.mainContext
            )
            
            if migrated {
                print("[SplashScreen] Migration completed")
            } else {
                print("[SplashScreen] Migration skipped or already done")
            }
            
            // Check if migration failed
            if case .failed = migrationManager.migrationStatus {
                showError = true
                return
            }

            migrationManager.currentStep = "Ready!"
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            await MainActor.run {
                withAnimation {
                    isDone = true
                }
            }
        } catch {
            await MainActor.run {
                migrationManager.currentStep = "Error: \(error.localizedDescription)"
                showError = true
            }
        }
    }
}

#Preview {
    let schema = Schema([Person.self, Group.self, Phone.self, MessageTool.self, Web.self, Event.self, EventGroup.self, EventPerson.self, Favorite.self])
    let container = try! ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    return SplashScreen(isDone: .constant(false), modelContainer: container)
}
