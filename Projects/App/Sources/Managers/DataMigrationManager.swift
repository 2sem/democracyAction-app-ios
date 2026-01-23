//
//  DataMigrationManager.swift
//  democracyaction
//
//  Handles migration from Core Data to SwiftData
//  Observable object for real-time progress updates in SplashScreen
//

import Foundation
import CoreData
import SwiftData

@MainActor
class DataMigrationManager: ObservableObject {
    @Published var migrationProgress: Double = 0.0
    @Published var migrationStatus: MigrationStatus = .idle
    @Published var currentStep: String = ""

    enum MigrationStatus: Equatable {
        case idle
        case checking
        case migrating
        case completed
        case failed(String) // Changed from Error to String for Equatable
        
        static func == (lhs: MigrationStatus, rhs: MigrationStatus) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle),
                 (.checking, .checking),
                 (.migrating, .migrating),
                 (.completed, .completed):
                return true
            case (.failed(let lhsMessage), .failed(let rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }
    }

    var isMigrationCompleted: Bool {
        get { DADefaults.SwiftDataMigrationCompleted }
        set { DADefaults.SwiftDataMigrationCompleted = newValue }
    }

    /// Main entry point - checks if migration is needed and performs it
    /// - Returns: true if migration was performed, false if skipped
    func checkAndMigrateIfNeeded(modelContext: ModelContext) async -> Bool {
        print("[DataMigration] checkAndMigrateIfNeeded started")

        if isMigrationCompleted {
            print("[DataMigration] Migration already completed")
            migrationStatus = .completed
            currentStep = "Migration already completed"
            return false
        }

        migrationStatus = .checking
        currentStep = "Checking for Core Data..."
        print("[DataMigration] Checking for Core Data")

        guard await hasCoreData() else {
            print("[DataMigration] No Core Data found, migration not needed")
            migrationStatus = .completed
            currentStep = "No migration needed"
            isMigrationCompleted = true
            return false
        }

        migrationStatus = .migrating
        currentStep = "Starting migration..."
        print("[DataMigration] Core Data found, starting migration")

        do {
            try await performMigration(modelContext: modelContext)
            print("[DataMigration] Migration completed successfully")
            migrationStatus = .completed
            currentStep = "Migration completed"
            isMigrationCompleted = true
            return true
        } catch {
            print("[DataMigration] Migration failed: \(error.localizedDescription)")
            migrationStatus = .failed(error.localizedDescription)
            currentStep = "Migration failed: \(error.localizedDescription)"
            return false
        }
    }

    /// Check if Core Data has any data to migrate
    private func hasCoreData() async -> Bool {
        print("[DataMigration] Checking Core Data entities")
        let context = DAModelController.shared.context

        return await withCheckedContinuation { continuation in
            context.perform {
                let personRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "DAPersonInfo")
                personRequest.fetchLimit = 1

                let groupRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "DAGroupInfo")
                groupRequest.fetchLimit = 1

                do {
                    let personCount = try context.count(for: personRequest)
                    let groupCount = try context.count(for: groupRequest)
                    let hasData = personCount > 0 || groupCount > 0

                    print("[DataMigration] Core Data check - persons: \(personCount), groups: \(groupCount), hasData: \(hasData)")
                    continuation.resume(returning: hasData)
                } catch {
                    print("[DataMigration] Error checking Core Data: \(error)")
                    continuation.resume(returning: false)
                }
            }
        }
    }

    /// Perform the actual migration
    private func performMigration(modelContext: ModelContext) async throws {
        print("[DataMigration] performMigration started")

        // Wait for Core Data to be ready
        await Task.yield()

        // Step 1: Migrate Groups (10% progress)
        currentStep = "Migrating groups..."
        migrationProgress = 0.0
        try await migrateGroups(with: modelContext)
        migrationProgress = 0.10

        // Step 1.5: Migrate Group Phones/Messages/Webs (5% progress)
        currentStep = "Migrating group contact info..."
        try await migrateGroupData(with: modelContext)
        migrationProgress = 0.15

        // Step 2: Migrate Persons (40% progress)
        currentStep = "Migrating persons..."
        try await migratePersons(with: modelContext)
        migrationProgress = 0.50

        // Step 3: Migrate Phones (10% progress)
        currentStep = "Migrating phones..."
        try await migratePhones(with: modelContext)
        migrationProgress = 0.60

        // Step 4: Migrate Messages (10% progress)
        currentStep = "Migrating social media..."
        try await migrateMessages(with: modelContext)
        migrationProgress = 0.70

        // Step 5: Migrate Webs (10% progress)
        currentStep = "Migrating websites..."
        try await migrateWebs(with: modelContext)
        migrationProgress = 0.80

        // Step 6: Migrate Favorites (5% progress)
        currentStep = "Migrating favorites..."
        try await migrateFavorites(with: modelContext)
        migrationProgress = 0.85

        // Step 7: Migrate Event Groups (5% progress)
        currentStep = "Migrating event groups..."
        try await migrateEventGroups(with: modelContext)
        migrationProgress = 0.90

        // Step 8: Migrate Events (10% progress)
        currentStep = "Migrating events..."
        try await migrateEvents(with: modelContext)
        migrationProgress = 0.95

        // Final save
        currentStep = "Saving data..."
        try modelContext.save()

        migrationProgress = 1.0
        print("[DataMigration] Migration completed successfully!")
    }

    // MARK: - Individual Migration Methods

    /// Migrate Groups from Core Data to SwiftData
    private func migrateGroups(with modelContext: ModelContext) async throws {
        print("[DataMigration] Fetching Core Data groups")
        let context = DAModelController.shared.context

        let coreDataGroups = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[DAGroupInfo], Error>) in
            context.perform {
                let request = NSFetchRequest<DAGroupInfo>(entityName: "DAGroupInfo")

                do {
                    let groups = try context.fetch(request)
                    print("[DataMigration] Fetched \(groups.count) groups from Core Data")
                    continuation.resume(returning: groups)
                } catch {
                    print("[DataMigration] Error fetching groups: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }

        print("[DataMigration] Migrating \(coreDataGroups.count) groups")

        for cdGroup in coreDataGroups {
            let group = Group(
                no: cdGroup.no,
                name: cdGroup.name ?? ""
            )
            group.detail = cdGroup.detail
            group.sponsor = cdGroup.sponsor

            modelContext.insert(group)
        }

        // Save batch
        try modelContext.save()
        print("[DataMigration] Saved \(coreDataGroups.count) groups to SwiftData")
    }

    /// Migrate Group-level phones, messages, and webs from Core Data to SwiftData
    private func migrateGroupData(with modelContext: ModelContext) async throws {
        print("[DataMigration] Fetching Core Data groups with related data")
        let context = DAModelController.shared.context

        let coreDataGroups = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[DAGroupInfo], Error>) in
            context.perform {
                let request = NSFetchRequest<DAGroupInfo>(entityName: "DAGroupInfo")

                do {
                    let groups = try context.fetch(request)
                    continuation.resume(returning: groups)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }

        // Get all SwiftData groups for linking
        let sdGroups = try modelContext.fetch(FetchDescriptor<Group>())
        let groupsByNo = Dictionary(uniqueKeysWithValues: sdGroups.map { ($0.no, $0) })

        var phoneCount = 0
        var messageCount = 0
        var webCount = 0

        for cdGroup in coreDataGroups {
            guard let sdGroup = groupsByNo[cdGroup.no] else { continue }

            // Migrate group phones
            if let groupPhones = cdGroup.phones?.allObjects as? [DAPhoneInfo] {
                for cdPhone in groupPhones {
                    let phone = Phone(
                        name: cdPhone.name,
                        number: cdPhone.number,
                        sms: cdPhone.sms
                    )
                    
                    phone.group = sdGroup
                    modelContext.insert(phone)
                    phoneCount += 1
                }
            }

            // Migrate group messages (social media)
            if let groupMessages = cdGroup.messages?.allObjects as? [DAMessageToolInfo] {
                for cdMessage in groupMessages {
                    let message = MessageTool(
                        name: cdMessage.name,
                        account: cdMessage.account
                    )
                    message.group = sdGroup
                    modelContext.insert(message)
                    messageCount += 1
                }
            }

            // Migrate group webs (homepage, blog, youtube)
            if let groupWebs = cdGroup.webs?.allObjects as? [DAWebInfo] {
                for cdWeb in groupWebs {
                    let web = Web(
                        name: cdWeb.name,
                        url: cdWeb.url
                    )
                    web.group = sdGroup
                    modelContext.insert(web)
                    webCount += 1
                }
            }

            // Batch save every 50 groups
            if phoneCount % 50 == 0 {
                try modelContext.save()
            }
        }

        try modelContext.save()
        print("[DataMigration] Migrated \(phoneCount) group phones, \(messageCount) group messages, \(webCount) group webs")
    }


    /// Migrate Persons from Core Data to SwiftData
    private func migratePersons(with modelContext: ModelContext) async throws {
        print("[DataMigration] Fetching Core Data persons")
        let context = DAModelController.shared.context

        let coreDataPersons = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[DAPersonInfo], Error>) in
            context.perform {
                let request = NSFetchRequest<DAPersonInfo>(entityName: "DAPersonInfo")

                do {
                    let persons = try context.fetch(request)
                    print("[DataMigration] Fetched \(persons.count) persons from Core Data")
                    continuation.resume(returning: persons)
                } catch {
                    print("[DataMigration] Error fetching persons: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }

        // Get all groups for linking
        let groups = try modelContext.fetch(FetchDescriptor<Group>())
        let groupsByNo = Dictionary(uniqueKeysWithValues: groups.map { ($0.no, $0) })

        let totalItems = coreDataPersons.count
        print("[DataMigration] Migrating \(totalItems) persons")

        for (i, cdPerson) in coreDataPersons.enumerated() {
            let person = Person(
                no: cdPerson.no,
                name: cdPerson.name ?? "",
                nameCharacters: cdPerson.nameCharacters ?? "",
                nameFirstCharacter: cdPerson.nameFirstCharacter ?? "",
                nameFirstCharacters: cdPerson.nameFirstCharacters ?? "?"
            )

            person.area = cdPerson.area
            person.areaCharacters = cdPerson.areaCharacters
            person.areaFirstCharacter = cdPerson.areaFirstCharacter
            person.areaFirstCharacters = cdPerson.areaFirstCharacters
            person.email = cdPerson.email
            person.job = cdPerson.job
            person.sponsor = cdPerson.sponsor

            // Link to group
            if let cdGroup = cdPerson.group {
                person.group = groupsByNo[cdGroup.no]
            }

            modelContext.insert(person)

            // Batch save every 100 items
            if (i + 1) % 100 == 0 {
                try modelContext.save()
                print("[DataMigration] Saved batch at \(i + 1) items")
            }
        }

        // Final save
        try modelContext.save()
        print("[DataMigration] Saved \(totalItems) persons to SwiftData")
    }

    /// Migrate Phones from Core Data to SwiftData
    private func migratePhones(with modelContext: ModelContext) async throws {
        print("[DataMigration] Fetching Core Data persons with phones")
        let context = DAModelController.shared.context

        let coreDataPersons = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[DAPersonInfo], Error>) in
            context.perform {
                let request = NSFetchRequest<DAPersonInfo>(entityName: "DAPersonInfo")

                do {
                    let persons = try context.fetch(request)
                    continuation.resume(returning: persons)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }

        let sdPersons = try modelContext.fetch(FetchDescriptor<Person>())
        let personsByNo = Dictionary(uniqueKeysWithValues: sdPersons.map { ($0.no, $0) })

        var phoneCount = 0
        for cdPerson in coreDataPersons {
            guard let phones = cdPerson.phones?.allObjects as? [DAPhoneInfo],
                  let sdPerson = personsByNo[cdPerson.no] else { continue }

            for cdPhone in phones {
                let phone = Phone(
                    name: cdPhone.name,
                    number: cdPhone.number,
                    sms: cdPhone.sms
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
        print("[DataMigration] Migrated \(phoneCount) phones")
    }

    /// Migrate Message Tools from Core Data to SwiftData
    private func migrateMessages(with modelContext: ModelContext) async throws {
        print("[DataMigration] Fetching Core Data persons with messages")
        let context = DAModelController.shared.context

        let coreDataPersons = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[DAPersonInfo], Error>) in
            context.perform {
                let request = NSFetchRequest<DAPersonInfo>(entityName: "DAPersonInfo")

                do {
                    let persons = try context.fetch(request)
                    continuation.resume(returning: persons)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }

        let sdPersons = try modelContext.fetch(FetchDescriptor<Person>())
        let personsByNo = Dictionary(uniqueKeysWithValues: sdPersons.map { ($0.no, $0) })

        var messageCount = 0
        for cdPerson in coreDataPersons {
            guard let messages = cdPerson.messages?.allObjects as? [DAMessageToolInfo],
                  let sdPerson = personsByNo[cdPerson.no] else { continue }

            for cdMessage in messages {
                let message = MessageTool(
                    name: cdMessage.name,
                    account: cdMessage.account
                )
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
        print("[DataMigration] Migrated \(messageCount) messages")
    }

    /// Migrate Web URLs from Core Data to SwiftData
    private func migrateWebs(with modelContext: ModelContext) async throws {
        print("[DataMigration] Fetching Core Data persons with webs")
        let context = DAModelController.shared.context

        let coreDataPersons = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[DAPersonInfo], Error>) in
            context.perform {
                let request = NSFetchRequest<DAPersonInfo>(entityName: "DAPersonInfo")

                do {
                    let persons = try context.fetch(request)
                    continuation.resume(returning: persons)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }

        let sdPersons = try modelContext.fetch(FetchDescriptor<Person>())
        let personsByNo = Dictionary(uniqueKeysWithValues: sdPersons.map { ($0.no, $0) })

        var webCount = 0
        for cdPerson in coreDataPersons {
            guard let webs = cdPerson.webs?.allObjects as? [DAWebInfo],
                  let sdPerson = personsByNo[cdPerson.no] else { continue }

            for cdWeb in webs {
                let web = Web(
                    name: cdWeb.name,
                    url: cdWeb.url
                )
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
        print("[DataMigration] Migrated \(webCount) webs")
    }

    /// Migrate Favorites from Core Data to SwiftData
    private func migrateFavorites(with modelContext: ModelContext) async throws {
        print("[DataMigration] Fetching Core Data favorites")
        let context = DAModelController.shared.context

        let coreDataFavorites = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[DAFavoriteInfo], Error>) in
            context.perform {
                let request = NSFetchRequest<DAFavoriteInfo>(entityName: "DAFavoriteInfo")

                do {
                    let favorites = try context.fetch(request)
                    print("[DataMigration] Fetched \(favorites.count) favorites from Core Data")
                    continuation.resume(returning: favorites)
                } catch {
                    print("[DataMigration] Error fetching favorites: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }

        let sdPersons = try modelContext.fetch(FetchDescriptor<Person>())
        let personsByNo = Dictionary(uniqueKeysWithValues: sdPersons.map { ($0.no, $0) })

        print("[DataMigration] Migrating \(coreDataFavorites.count) favorites")

        for cdFavorite in coreDataFavorites {
            guard let cdPerson = cdFavorite.person,
                  let sdPerson = personsByNo[cdPerson.no] else { continue }

            let favorite = Favorite(
                isAlarmOn: cdFavorite.isAlarmOn,
                person: sdPerson
            )
            modelContext.insert(favorite)
        }

        try modelContext.save()
        print("[DataMigration] Saved \(coreDataFavorites.count) favorites to SwiftData")
    }

    /// Migrate Event Groups from Core Data to SwiftData
    private func migrateEventGroups(with modelContext: ModelContext) async throws {
        print("[DataMigration] Fetching Core Data event groups")
        let context = DAModelController.shared.context

        let coreDataEventGroups = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[DAEventGroupInfo], Error>) in
            context.perform {
                let request = NSFetchRequest<DAEventGroupInfo>(entityName: "DAEventGroupInfo")

                do {
                    let eventGroups = try context.fetch(request)
                    print("[DataMigration] Fetched \(eventGroups.count) event groups from Core Data")
                    continuation.resume(returning: eventGroups)
                } catch {
                    print("[DataMigration] Error fetching event groups: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }

        print("[DataMigration] Migrating \(coreDataEventGroups.count) event groups")

        for cdEventGroup in coreDataEventGroups {
            let eventGroup = EventGroup(
                no: cdEventGroup.no,
                name: cdEventGroup.name ?? ""
            )
            eventGroup.detail = cdEventGroup.detail

            modelContext.insert(eventGroup)
        }

        try modelContext.save()
        print("[DataMigration] Saved \(coreDataEventGroups.count) event groups to SwiftData")
    }

    /// Migrate Events from Core Data to SwiftData
    private func migrateEvents(with modelContext: ModelContext) async throws {
        print("[DataMigration] Fetching Core Data events")
        let context = DAModelController.shared.context

        let coreDataEvents = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[DAEventInfo], Error>) in
            context.perform {
                let request = NSFetchRequest<DAEventInfo>(entityName: "DAEventInfo")

                do {
                    let events = try context.fetch(request)
                    print("[DataMigration] Fetched \(events.count) events from Core Data")
                    continuation.resume(returning: events)
                } catch {
                    print("[DataMigration] Error fetching events: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }

        let sdPersons = try modelContext.fetch(FetchDescriptor<Person>())
        let personsByNo = Dictionary(uniqueKeysWithValues: sdPersons.map { ($0.no, $0) })

        print("[DataMigration] Migrating \(coreDataEvents.count) events")

        for cdEvent in coreDataEvents {
            let event = Event(
                no: cdEvent.no,
                name: cdEvent.name ?? ""
            )
            event.detail = cdEvent.detail

            // Migrate event members
            if let members = cdEvent.members?.allObjects as? [DAEventPersonInfo] {
                for cdMember in members {
                    if let cdPerson = cdMember.person,
                       let sdPerson = personsByNo[cdPerson.no] {
                        let eventPerson = EventPerson(person: sdPerson)
                        modelContext.insert(eventPerson)
                        if event.members == nil {
                            event.members = []
                        }
                        event.members?.append(eventPerson)
                    }
                }
            }

            modelContext.insert(event)
        }

        try modelContext.save()
        print("[DataMigration] Saved \(coreDataEvents.count) events to SwiftData")
    }
}
