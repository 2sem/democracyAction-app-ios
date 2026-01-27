//
//  InitialDataManager.swift
//  democracyaction
//
//  Handles initial data setup for fresh app installs
//  Separate from migration logic for clean separation of concerns
//

import Foundation
import SwiftData

@MainActor
class InitialDataManager: ObservableObject {
    @Published var progress: Double = 0.0
    @Published var status: DataStatus = .idle
    @Published var currentStep: String = ""

    enum DataStatus: Equatable {
        case idle
        case checking
        case loading
        case completed
        case failed(String)

        static func == (lhs: DataStatus, rhs: DataStatus) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle),
                 (.checking, .checking),
                 (.loading, .loading),
                 (.completed, .completed):
                return true
            case (.failed(let lhsMessage), .failed(let rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }
    }

    var isDataLoaded: Bool {
        get { DADefaults.InitialDataLoaded }
        set { DADefaults.InitialDataLoaded = newValue }
    }

    /// Check if initial data load is needed and perform it
    /// - Returns: true if data was loaded, false if skipped
    func checkAndLoadIfNeeded(modelContext: ModelContext) async -> Bool {
        print("[InitialData] checkAndLoadIfNeeded started")

        // Already loaded before
        if isDataLoaded {
            print("[InitialData] Initial data already loaded")
            status = .completed
            currentStep = "데이터가 이미 로드됨"
            return false
        }

        status = .checking
        currentStep = "기존 데이터 확인 중..."
        print("[InitialData] Checking if data exists")

        // Check if SwiftData already has data
        if await hasData(modelContext: modelContext) {
            print("[InitialData] Data already exists, skipping load")
            status = .completed
            currentStep = "데이터가 이미 존재함"
            isDataLoaded = true
            return false
        }

        // Fresh install - load initial data
        status = .loading
        currentStep = "초기 데이터 로딩 중..."
        print("[InitialData] No data found, loading from Excel")

        do {
            try await loadInitialData(modelContext: modelContext)
            print("[InitialData] Initial data load completed successfully")
            status = .completed
            currentStep = "데이터가 성공적으로 로드됨"
            isDataLoaded = true
            return true
        } catch {
            print("[InitialData] Initial data load failed: \(error.localizedDescription)")
            status = .failed(error.localizedDescription)
            currentStep = "데이터 로딩 실패: \(error.localizedDescription)"
            return false
        }
    }

    /// Check if SwiftData already has data
    private func hasData(modelContext: ModelContext) async -> Bool {
        print("[InitialData] Checking SwiftData for existing data")

        do {
            let personDescriptor = FetchDescriptor<Person>()
            let personCount = try modelContext.fetchCount(personDescriptor)

            let groupDescriptor = FetchDescriptor<Group>()
            let groupCount = try modelContext.fetchCount(groupDescriptor)

            let hasData = personCount > 0 || groupCount > 0
            print("[InitialData] Data check - persons: \(personCount), groups: \(groupCount), hasData: \(hasData)")

            return hasData
        } catch {
            print("[InitialData] Error checking data: \(error)")
            return false
        }
    }

    /// Load initial data from bundled Excel file
    private func loadInitialData(modelContext: ModelContext) async throws {
        print("[InitialData] Loading data from Excel")

        let loader = ExcelDataLoader()

        try await loader.loadFromExcel(modelContext: modelContext) { progress, step in
            await MainActor.run {
                self.progress = progress
                self.currentStep = step
            }
        }

        print("[InitialData] Data load from Excel completed")
    }
}
