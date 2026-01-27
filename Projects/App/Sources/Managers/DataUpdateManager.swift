//
//  DataUpdateManager.swift
//  democracyaction
//
//  Handles checking for and syncing Excel data updates
//  Called after app initialization to update data if bundled Excel is newer
//

import Foundation
import SwiftData

@MainActor
class DataUpdateManager: ObservableObject {
    @Published var progress: Double = 0.0
    @Published var status: UpdateStatus = .idle
    @Published var currentStep: String = ""

    enum UpdateStatus: Equatable {
        case idle
        case checking
        case updating
        case completed
        case failed(String)

        static func == (lhs: UpdateStatus, rhs: UpdateStatus) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle),
                 (.checking, .checking),
                 (.updating, .updating),
                 (.completed, .completed):
                return true
            case (.failed(let lhsMessage), .failed(let rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }
    }

    /// Check if bundled Excel has updates and sync if needed
    /// - Returns: true if data was updated, false if no update needed
    func checkAndUpdateIfNeeded(modelContext: ModelContext) async -> Bool {
        print("[DataUpdate] checkAndUpdateIfNeeded started")

        status = .checking
        currentStep = "데이터 업데이트 확인 중..."

        // Load bundled Excel to check version
        guard let excelURL = Bundle.main.url(
            forResource: "direct_democracy",
            withExtension: "xlsx",
            subdirectory: "Resources/Datas"
        ) ?? Bundle.main.url(
            forResource: "direct_democracy",
            withExtension: "xlsx"
        ) else {
            print("[DataUpdate] Bundled Excel not found")
            status = .completed
            currentStep = "업데이트 가능 없음"
            return false
        }

        let excel = DAExcelController(excelURL)
        let bundledVersion = excel.version
        let currentVersion = DADefaults.DataVersion

        print("[DataUpdate] Bundled version: \(bundledVersion), Current version: \(currentVersion)")

        // Check if update is needed
        guard bundledVersion > currentVersion else {
            print("[DataUpdate] Data is up to date")
            status = .completed
            currentStep = "데이터가 최신 상태임"
            return false
        }

        // Update needed
        print("[DataUpdate] Update available: \(currentVersion) → \(bundledVersion)")
        status = .updating
        currentStep = "데이터 업데이트 중..."

        do {
            try await syncUpdates(excel: excel, modelContext: modelContext)
            print("[DataUpdate] Update completed successfully")
            status = .completed
            currentStep = "업데이트 완료"
            return true
        } catch {
            print("[DataUpdate] Update failed: \(error.localizedDescription)")
            status = .failed(error.localizedDescription)
            currentStep = "업데이트 실패: \(error.localizedDescription)"
            return false
        }
    }

    /// Sync updates from Excel to SwiftData
    private func syncUpdates(excel: DAExcelController, modelContext: ModelContext) async throws {
        print("[DataUpdate] Syncing updates from Excel version \(excel.version)")

        // Load Excel data
        excel.loadFromFlie()

        // Progress tracking
        currentStep = "그룹 동기화 중..."
        progress = 0.0

        // Sync groups (update existing, add new)
        try await syncGroupUpdates(excel: excel, modelContext: modelContext)
        progress = 0.25

        // Sync persons (update existing, add new, remove deleted)
        currentStep = "정치인 동기화 중..."
        try await syncPersonUpdates(excel: excel, modelContext: modelContext)
        progress = 0.75

        // Sync events
        currentStep = "이벤트 동기화 중..."
        try await syncEventUpdates(excel: excel, modelContext: modelContext)
        progress = 0.95

        // Final save
        currentStep = "업데이트 저장 중..."
        try modelContext.save()

        // Update version
        DADefaults.DataVersion = excel.version
        progress = 1.0

        print("[DataUpdate] Sync completed - updated to version \(excel.version)")
    }

    // MARK: - Update Sync Methods

    /// Sync group updates from Excel
    private func syncGroupUpdates(excel: DAExcelController, modelContext: ModelContext) async throws {
        let excelGroups = Array(excel.groups.values)
        print("[DataUpdate] Syncing \(excelGroups.count) groups")

        // Get existing groups
        let existingGroups = try modelContext.fetch(FetchDescriptor<Group>())
        let groupsByNo = Dictionary(uniqueKeysWithValues: existingGroups.map { ($0.no, $0) })

        for excelGroup in excelGroups {
            let groupNo = Int16(excelGroup.id)

            if let existingGroup = groupsByNo[groupNo] {
                // Update existing group
                existingGroup.name = excelGroup.title
                existingGroup.detail = excelGroup.detail
                print("[DataUpdate] Updated group \(groupNo): \(excelGroup.title)")
            } else {
                // Add new group
                let newGroup = Group(no: groupNo, name: excelGroup.title)
                newGroup.detail = excelGroup.detail
                modelContext.insert(newGroup)
                print("[DataUpdate] Added new group \(groupNo): \(excelGroup.title)")
            }
        }

        try modelContext.save()
    }

    /// Sync person updates from Excel
    private func syncPersonUpdates(excel: DAExcelController, modelContext: ModelContext) async throws {
        let excelPersons = excel.persons
        print("[DataUpdate] Syncing \(excelPersons.count) persons")

        // Get existing persons and groups
        let existingPersons = try modelContext.fetch(FetchDescriptor<Person>())
        let personsByNo = Dictionary(uniqueKeysWithValues: existingPersons.map { ($0.no, $0) })

        let existingGroups = try modelContext.fetch(FetchDescriptor<Group>())
        let groupsByNo = Dictionary(uniqueKeysWithValues: existingGroups.map { ($0.no, $0) })

        // Track which persons exist in Excel
        var excelPersonNos = Set<Int16>()

        for excelPerson in excelPersons {
            let personNo = Int16(excelPerson.id)
            excelPersonNos.insert(personNo)

            if let existingPerson = personsByNo[personNo] {
                // Update existing person
                existingPerson.name = excelPerson.name
                existingPerson.nameCharacters = excelPerson.name.getKoreanParts(false) ?? ""
                existingPerson.nameFirstCharacter = String(excelPerson.name.first ?? Character(""))
                existingPerson.nameFirstCharacters = excelPerson.name.getKoreanChoSeongs(false) ?? "?"

                existingPerson.area = excelPerson.area.isEmpty ? nil : excelPerson.area
                if let area = existingPerson.area {
                    existingPerson.areaCharacters = area
                    existingPerson.areaFirstCharacter = String(area.first ?? Character(""))
                    existingPerson.areaFirstCharacters = area.getKoreanChoSeongs(false)
                }

                existingPerson.email = excelPerson.email.isEmpty ? nil : excelPerson.email
                existingPerson.job = excelPerson.title.isEmpty ? nil : excelPerson.title
                existingPerson.group = groupsByNo[Int16(excelPerson.groupId)]

                print("[DataUpdate] Updated person \(personNo): \(excelPerson.name)")
            } else {
                // Add new person
                let newPerson = Person(
                    no: personNo,
                    name: excelPerson.name,
                    nameCharacters: excelPerson.name,
                    nameFirstCharacter: String(excelPerson.name.first ?? Character("")),
                    nameFirstCharacters: excelPerson.name.getKoreanChoSeongs(false) ?? "?"
                )

                newPerson.area = excelPerson.area.isEmpty ? nil : excelPerson.area
                if let area = newPerson.area {
                    newPerson.areaCharacters = area
                    newPerson.areaFirstCharacter = String(area.first ?? Character(""))
                    newPerson.areaFirstCharacters = area.getKoreanChoSeongs(false)
                }

                newPerson.email = excelPerson.email.isEmpty ? nil : excelPerson.email
                newPerson.job = excelPerson.title.isEmpty ? nil : excelPerson.title
                newPerson.group = groupsByNo[Int16(excelPerson.groupId)]

                modelContext.insert(newPerson)
                print("[DataUpdate] Added new person \(personNo): \(excelPerson.name)")
            }
        }

        // Remove persons that no longer exist in Excel
        for existingPerson in existingPersons {
            if !excelPersonNos.contains(existingPerson.no) {
                print("[DataUpdate] Removing deleted person \(existingPerson.no): \(existingPerson.name)")
                modelContext.delete(existingPerson)
            }
        }

        try modelContext.save()
    }

    /// Sync event updates from Excel
    private func syncEventUpdates(excel: DAExcelController, modelContext: ModelContext) async throws {
        let excelEventGroups = excel.eventGroups
        print("[DataUpdate] Syncing \(excelEventGroups.count) event groups")

        // Get existing event groups
        let existingEventGroups = try modelContext.fetch(FetchDescriptor<EventGroup>())
        let eventGroupsByNo = Dictionary(uniqueKeysWithValues: existingEventGroups.map { ($0.no, $0) })

        for excelEventGroup in excelEventGroups {
            let eventGroupNo = Int16(excelEventGroup.no)

            if let existingEventGroup = eventGroupsByNo[eventGroupNo] {
                // Update existing event group
                existingEventGroup.name = excelEventGroup.name
                existingEventGroup.detail = excelEventGroup.detail
            } else {
                // Add new event group
                let newEventGroup = EventGroup(no: eventGroupNo, name: excelEventGroup.name)
                newEventGroup.detail = excelEventGroup.detail
                modelContext.insert(newEventGroup)
            }
        }

        try modelContext.save()
    }
}
