//
//  ExcelDataLoader.swift
//  democracyaction
//
//  Loads initial data from bundled Excel file into SwiftData
//  Used for fresh app installs when no Core Data migration is needed
//

import Foundation
import SwiftData

@MainActor
class ExcelDataLoader {
    /// Progress callback: (progress: Double, currentStep: String)
    typealias ProgressCallback = (Double, String) async -> Void

    /// Main entry point: Load data from bundled Excel file into SwiftData
    /// - Parameters:
    ///   - modelContext: SwiftData model context
    ///   - progressCallback: Optional callback for progress updates
    func loadFromExcel(
        modelContext: ModelContext,
        progressCallback: ProgressCallback? = nil
    ) async throws {
        print("[ExcelDataLoader] Starting initial data load from Excel")

        // Load Excel file from bundle
        guard let excelURL = Bundle.main.url(
            forResource: "direct_democracy",
            withExtension: "xlsx",
            subdirectory: "Resources/Datas"
        ) ?? Bundle.main.url(
            forResource: "direct_democracy",
            withExtension: "xlsx"
        ) else {
            throw ExcelLoaderError.excelFileNotFound
        }

        // Initialize Excel controller
        let excel = DAExcelController(excelURL)
        excel.loadFromFlie()

        print("[ExcelDataLoader] Excel loaded - version: \(excel.version)")

        // Step 1: Load Groups (0.00 → 0.10)
        await progressCallback?(0.0, "Loading groups...")
        try await syncGroups(excel: excel, modelContext: modelContext)
        await progressCallback?(0.10, "Groups loaded")

        // Step 2: Load Group contact info (0.10 → 0.15)
        await progressCallback?(0.10, "Loading group contact info...")
        try await syncGroupData(excel: excel, modelContext: modelContext)
        await progressCallback?(0.15, "Group contact info loaded")

        // Step 3: Load Persons (0.15 → 0.55)
        await progressCallback?(0.15, "Loading politicians...")
        try await syncPersons(excel: excel, modelContext: modelContext)
        await progressCallback?(0.55, "Politicians loaded")

        // Step 4: Load Person phones (0.55 → 0.65)
        await progressCallback?(0.55, "Loading phone numbers...")
        try await syncPersonPhones(excel: excel, modelContext: modelContext)
        await progressCallback?(0.65, "Phone numbers loaded")

        // Step 5: Load Person messages (0.65 → 0.75)
        await progressCallback?(0.65, "Loading social media...")
        try await syncPersonMessages(excel: excel, modelContext: modelContext)
        await progressCallback?(0.75, "Social media loaded")

        // Step 6: Load Person webs (0.75 → 0.85)
        await progressCallback?(0.75, "Loading websites...")
        try await syncPersonWebs(excel: excel, modelContext: modelContext)
        await progressCallback?(0.85, "Websites loaded")

        // Step 7: Load Events (0.85 → 0.95)
        await progressCallback?(0.85, "Loading events...")
        try await syncEvents(excel: excel, modelContext: modelContext)
        await progressCallback?(0.95, "Events loaded")

        // Step 8: Final save (0.95 → 1.00)
        await progressCallback?(0.95, "Saving data...")
        try modelContext.save()
        await progressCallback?(1.0, "Data loaded successfully")

        // Update data version
        DADefaults.DataVersion = excel.version

        print("[ExcelDataLoader] Initial data load completed - version: \(excel.version)")
    }

    // MARK: - Group Syncing

    /// Sync groups from Excel to SwiftData
    private func syncGroups(excel: DAExcelController, modelContext: ModelContext) async throws {
        let excelGroups = Array(excel.groups.values)
        print("[ExcelDataLoader] Loading \(excelGroups.count) groups")

        for excelGroup in excelGroups {
            let group = Group(
                no: Int16(excelGroup.id),
                name: excelGroup.title
            )
            group.detail = excelGroup.detail

            modelContext.insert(group)
        }

        // Batch save
        try modelContext.save()
        print("[ExcelDataLoader] Saved \(excelGroups.count) groups")
    }

    /// Sync group contact info (phones, messages, webs)
    private func syncGroupData(excel: DAExcelController, modelContext: ModelContext) async throws {
        let excelGroups = Array(excel.groups.values)

        // Get all SwiftData groups for linking
        let sdGroups = try modelContext.fetch(FetchDescriptor<Group>())
        let groupsByNo = Dictionary(uniqueKeysWithValues: sdGroups.map { ($0.no, $0) })

        var phoneCount = 0
        var messageCount = 0
        var webCount = 0

        for excelGroup in excelGroups {
            guard let sdGroup = groupsByNo[Int16(excelGroup.id)] else { continue }

            // Sync group phones
            for excelPhone in excelGroup.phones {
                let phone = Phone(
                    name: excelPhone.name,
                    number: excelPhone.number,
                    sms: excelPhone.name == "휴대폰"
                )
                phone.group = sdGroup
                modelContext.insert(phone)
                phoneCount += 1
            }

            // Sync group message tools (social media)
            let messageTools = buildMessageTools(from: excelGroup)
            for (name, account) in messageTools {
                let message = MessageTool(name: name, account: account)
                message.group = sdGroup
                modelContext.insert(message)
                messageCount += 1
            }

            // Sync group webs
            let webs = buildWebs(from: excelGroup)
            for (name, url) in webs {
                let web = Web(name: name, url: url)
                web.group = sdGroup
                modelContext.insert(web)
                webCount += 1
            }
        }

        try modelContext.save()
        print("[ExcelDataLoader] Saved \(phoneCount) group phones, \(messageCount) group messages, \(webCount) group webs")
    }

    // MARK: - Person Syncing

    /// Sync persons from Excel to SwiftData
    private func syncPersons(excel: DAExcelController, modelContext: ModelContext) async throws {
        let excelPersons = excel.persons
        print("[ExcelDataLoader] Loading \(excelPersons.count) persons")

        // Get all groups for linking
        let groups = try modelContext.fetch(FetchDescriptor<Group>())
        let groupsByNo = Dictionary(uniqueKeysWithValues: groups.map { ($0.no, $0) })

        for (index, excelPerson) in excelPersons.enumerated() {
            let person = Person(
                no: Int16(excelPerson.id),
                name: excelPerson.name,
                nameCharacters: excelPerson.name,
                nameFirstCharacter: String(excelPerson.name.first ?? Character("")),
                nameFirstCharacters: excelPerson.name.getKoreanChoSeongs(false) ?? "?"
            )

            // Area data
            person.area = excelPerson.area.isEmpty ? nil : excelPerson.area
            if let area = person.area {
                person.areaCharacters = area
                person.areaFirstCharacter = String(area.first ?? Character(""))
                person.areaFirstCharacters = area.getKoreanChoSeongs(false)
            }

            // Other data
            person.email = excelPerson.email.isEmpty ? nil : excelPerson.email
            person.job = excelPerson.title.isEmpty ? nil : excelPerson.title

            // Link to group
            person.group = groupsByNo[Int16(excelPerson.groupId)]

            modelContext.insert(person)

            // Batch save every 100 items
            if (index + 1) % 100 == 0 {
                try modelContext.save()
                print("[ExcelDataLoader] Saved batch at \(index + 1) persons")
            }
        }

        // Final save
        try modelContext.save()
        print("[ExcelDataLoader] Saved \(excelPersons.count) persons")
    }

    /// Sync person phones from Excel to SwiftData
    private func syncPersonPhones(excel: DAExcelController, modelContext: ModelContext) async throws {
        let excelPersons = excel.persons

        // Get all persons for linking
        let sdPersons = try modelContext.fetch(FetchDescriptor<Person>())
        let personsByNo = Dictionary(uniqueKeysWithValues: sdPersons.map { ($0.no, $0) })

        var phoneCount = 0
        for excelPerson in excelPersons {
            guard let sdPerson = personsByNo[Int16(excelPerson.id)] else { continue }

            for excelPhone in excelPerson.phones {
                let phone = Phone(
                    name: excelPhone.name,
                    number: excelPhone.number,
                    sms: excelPhone.name == "휴대폰"
                )
                phone.person = sdPerson
                modelContext.insert(phone)
                phoneCount += 1
            }

            // Batch save every 100 persons
            if phoneCount % 100 == 0 {
                try modelContext.save()
            }
        }

        try modelContext.save()
        print("[ExcelDataLoader] Saved \(phoneCount) person phones")
    }

    /// Sync person message tools from Excel to SwiftData
    private func syncPersonMessages(excel: DAExcelController, modelContext: ModelContext) async throws {
        let excelPersons = excel.persons

        // Get all persons for linking
        let sdPersons = try modelContext.fetch(FetchDescriptor<Person>())
        let personsByNo = Dictionary(uniqueKeysWithValues: sdPersons.map { ($0.no, $0) })

        var messageCount = 0
        for excelPerson in excelPersons {
            guard let sdPerson = personsByNo[Int16(excelPerson.id)] else { continue }

            let messageTools = buildMessageTools(from: excelPerson)
            for (name, account) in messageTools {
                let message = MessageTool(name: name, account: account)
                message.person = sdPerson
                modelContext.insert(message)
                messageCount += 1
            }

            // Batch save every 100 persons
            if messageCount % 100 == 0 {
                try modelContext.save()
            }
        }

        try modelContext.save()
        print("[ExcelDataLoader] Saved \(messageCount) person messages")
    }

    /// Sync person webs from Excel to SwiftData
    private func syncPersonWebs(excel: DAExcelController, modelContext: ModelContext) async throws {
        let excelPersons = excel.persons

        // Get all persons for linking
        let sdPersons = try modelContext.fetch(FetchDescriptor<Person>())
        let personsByNo = Dictionary(uniqueKeysWithValues: sdPersons.map { ($0.no, $0) })

        var webCount = 0
        for excelPerson in excelPersons {
            guard let sdPerson = personsByNo[Int16(excelPerson.id)] else { continue }

            let webs = buildWebs(from: excelPerson)
            for (name, url) in webs {
                let web = Web(name: name, url: url)
                web.person = sdPerson
                modelContext.insert(web)
                webCount += 1
            }

            // Batch save every 100 persons
            if webCount % 100 == 0 {
                try modelContext.save()
            }
        }

        try modelContext.save()
        print("[ExcelDataLoader] Saved \(webCount) person webs")
    }

    // MARK: - Event Syncing

    /// Sync events from Excel to SwiftData
    private func syncEvents(excel: DAExcelController, modelContext: ModelContext) async throws {
        let excelEventGroups = excel.eventGroups
        print("[ExcelDataLoader] Loading \(excelEventGroups.count) event groups")

        // Get all persons for linking
        let sdPersons = try modelContext.fetch(FetchDescriptor<Person>())
        let personsByNo = Dictionary(uniqueKeysWithValues: sdPersons.map { ($0.no, $0) })

        for excelEventGroup in excelEventGroups {
            let eventGroup = EventGroup(
                no: Int16(excelEventGroup.no),
                name: excelEventGroup.name
            )
            eventGroup.detail = excelEventGroup.detail
            modelContext.insert(eventGroup)

            // Sync events in this group
            for excelEvent in excelEventGroup.events {
                let event = Event(
                    no: Int32(excelEvent.no),
                    name: excelEvent.title
                )
                event.detail = excelEvent.detail

                // Sync event members (persons is array of Int IDs)
                for personId in excelEvent.persons {
                    if let sdPerson = personsByNo[Int16(personId)] {
                        let eventPerson = EventPerson(person: sdPerson)
                        modelContext.insert(eventPerson)
                        if event.members == nil {
                            event.members = []
                        }
                        event.members?.append(eventPerson)
                    }
                }

                modelContext.insert(event)
            }
        }

        try modelContext.save()
        print("[ExcelDataLoader] Saved \(excelEventGroups.count) event groups")
    }

    // MARK: - Helper Methods

    /// Build message tools array from Excel group
    private func buildMessageTools(from excelGroup: DAExcelGroupInfo) -> [(name: String, account: String)] {
        var tools: [(String, String)] = []

        if !excelGroup.twitter.isEmpty {
            tools.append(("twitter", excelGroup.twitter))
        }
        if !excelGroup.facebook.isEmpty {
            tools.append(("facebook", excelGroup.facebook))
        }
        if !excelGroup.kakao.isEmpty {
            tools.append(("kakao", excelGroup.kakao))
        }
        if !excelGroup.instagram.isEmpty {
            tools.append(("instagram", excelGroup.instagram))
        }
        if !excelGroup.youtube.isEmpty {
            tools.append(("youtube", excelGroup.youtube))
        }

        return tools
    }

    /// Build message tools array from Excel person
    private func buildMessageTools(from excelPerson: DAExcelPersonInfo) -> [(name: String, account: String)] {
        var tools: [(String, String)] = []

        if !excelPerson.twitter.isEmpty {
            tools.append(("twitter", excelPerson.twitter))
        }
        if !excelPerson.facebook.isEmpty {
            tools.append(("facebook", excelPerson.facebook))
        }
        if !excelPerson.kakao.isEmpty {
            tools.append(("kakao", excelPerson.kakao))
        }
        if !excelPerson.instagram.isEmpty {
            tools.append(("instagram", excelPerson.instagram))
        }
        if !excelPerson.youtube.isEmpty {
            tools.append(("youtube", excelPerson.youtube))
        }

        return tools
    }

    /// Build webs array from Excel group
    private func buildWebs(from excelGroup: DAExcelGroupInfo) -> [(name: String, url: String)] {
        var webs: [(String, String)] = []

        if !excelGroup.web.isEmpty {
            webs.append(("homepage", excelGroup.web))
        }
        if !excelGroup.blog.isEmpty {
            webs.append(("blog", excelGroup.blog))
        }
        if !excelGroup.cafe.isEmpty {
            webs.append(("cafe", excelGroup.cafe))
        }
        if !excelGroup.cyworld.isEmpty {
            webs.append(("cyworld", excelGroup.cyworld))
        }

        return webs
    }

    /// Build webs array from Excel person
    private func buildWebs(from excelPerson: DAExcelPersonInfo) -> [(name: String, url: String)] {
        var webs: [(String, String)] = []

        if !excelPerson.web.isEmpty {
            webs.append(("homepage", excelPerson.web))
        }
        if !excelPerson.blog.isEmpty {
            webs.append(("blog", excelPerson.blog))
        }
        if !excelPerson.cafe.isEmpty {
            webs.append(("cafe", excelPerson.cafe))
        }
        if !excelPerson.cyworld.isEmpty {
            webs.append(("cyworld", excelPerson.cyworld))
        }

        return webs
    }
}

// MARK: - Error Types

enum ExcelLoaderError: Error, LocalizedError {
    case excelFileNotFound
    case parseError(String)

    var errorDescription: String? {
        switch self {
        case .excelFileNotFound:
            return "Excel file 'direct_democracy.xlsx' not found in bundle"
        case .parseError(let message):
            return "Failed to parse Excel: \(message)"
        }
    }
}
