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
    @StateObject private var initialDataManager = InitialDataManager()
    @StateObject private var updateManager = DataUpdateManager()
    @State private var showError = false
    @State private var errorMessage = ""

    private var currentStep: String {
        if updateManager.status == .updating {
            return updateManager.currentStep
        }
        if initialDataManager.status == .loading {
            return initialDataManager.currentStep
        }
        return migrationManager.currentStep
    }
    
    private var progress: Double {
        if updateManager.status == .updating {
            return updateManager.progress
        }
        if initialDataManager.status == .loading {
            return initialDataManager.progress
        }
        return migrationManager.migrationProgress
    }
    
    private var isProgressActive: Bool {
        migrationManager.migrationStatus == .migrating 
        || initialDataManager.status == .loading
        || updateManager.status == .updating
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Logo
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 300)

                Spacer()

                // Loading indicators at bottom
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.5)

                    VStack(spacing: 12) {
                        Text(currentStep)
                            .foregroundColor(.primary)
                            .font(.headline)

                        if isProgressActive {
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                .frame(width: 200)

                            Text("\(Int(progress * 100))%")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                .padding(.bottom, 60)
            }
            .padding(.horizontal, 40)
        }
        .alert("초기화 오류", isPresented: $showError) {
            Button("다시 시도") {
                Task {
                    await performInitialization()
                }
            }
            Button("취소", role: .cancel) {
                // User can cancel and app will continue without data
                isDone = true
            }
        } message: {
            Text(errorMessage)
        }
        .task {
            await performInitialization()
        }
    }

    private func performInitialization() async {
        do {
            migrationManager.currentStep = "초기화 중..."
            
            // Initialize app (launch count, etc.)
            try await AppInitializer.initialize()
            
            // 1. Attempt Core Data to SwiftData migration
            let migrationResult = await migrationManager.checkAndMigrateIfNeeded(
                modelContext: modelContainer.mainContext
            )
            
            switch migrationResult {
            case .migrationCompleted:
                print("[SplashScreen] Migration completed successfully.")
            case .migrationSkipped:
                print("[SplashScreen] Migration was already completed.")
            case .migrationFailed(let error):
                errorMessage = "Failed to migrate data: \(error.localizedDescription)"
                showError = true
                return
            case .noCoreDataFound:
                print("[SplashScreen] No Core Data found. Checking for initial data load.")
                // 2. If no Core Data, check if we need to load initial data
                _ = await initialDataManager.checkAndLoadIfNeeded(
                    modelContext: modelContainer.mainContext
                )

                if case .failed(let msg) = initialDataManager.status {
                    errorMessage = "Failed to load initial data: \(msg)"
                    showError = true
                    return
                }
            }

            // 3. Check for Excel data updates (on every launch)
            print("[SplashScreen] Checking for data updates...")
            _ = await updateManager.checkAndUpdateIfNeeded(
                modelContext: modelContainer.mainContext
            )

            if case .failed(let msg) = updateManager.status {
                errorMessage = "Failed to update data: \(msg)"
                showError = true
                return
            }

            migrationManager.currentStep = "준비 완료!"
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            await MainActor.run {
                withAnimation {
                    isDone = true
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
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
