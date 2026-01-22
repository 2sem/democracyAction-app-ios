//
//  PoliticianListViewModel.swift
//  democracyaction
//
//  ViewModel for PoliticianListScreen
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
class PoliticianListViewModel: ObservableObject {
    // MARK: - Nested Types

    enum GroupingType: CaseIterable {
        case byName
        case byGroup
        case byArea

        var title: String {
            switch self {
            case .byName: return "이름"
            case .byGroup: return "소속"
            case .byArea: return "지역"
            }
        }
    }

    struct PersonGroup: Identifiable {
        var id: String { title }
        let title: String
        let persons: [Person]
    }

    // MARK: - Published Properties

    /// Sort direction: true = ascending, false = descending
    @Published var isAscending: Bool = true

    /// Search text for filtering
    @Published var searchText: String = ""

    /// Grouping type for list organization
    @Published var groupingType: GroupingType = .byName

    /// Current chosung index for navigation
    @Published var currentChosungIndex: Int = 0
    
    @Published var groups: [PersonGroup] = []
    var groupIds: Set<String> = []

    // MARK: - Constants

    /// All Korean chosungs in order
    static let allChosungs = ["ㄱ", "ㄴ", "ㄷ", "ㄹ", "ㅁ", "ㅂ", "ㅅ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]

    // MARK: - Computed Properties

    /// Sort icon name for toolbar button
    var sortIconName: String {
        isAscending ? "arrow.up.circle" : "arrow.down.circle"
    }
    
    // MARK: - Actions
    
    /// Toggle sort direction
    func toggleSort() {
        isAscending.toggle()
    }
    
    /// Apply sorting to persons array
    func sortedPersons(_ persons: [Person]) -> [Person] {
        persons.sorted { left, right in
            isAscending
                ? left.name < right.name
                : left.name > right.name
        }
    }
    
    /// Apply filtering and sorting to persons array
    func filteredAndSortedPersons(_ persons: [Person]) -> [Person] {
        var result = persons

        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { person in
                person.name.localizedCaseInsensitiveContains(searchText) ||
                (person.area?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        // Apply sorting
        return sortedPersons(result)
    }

    /// Group persons into sections based on groupingType
    func updateGroups(withPersons persons: [Person]) {
        // First apply filtering and sorting
        let filteredPersons = filteredAndSortedPersons(persons)

        guard !filteredPersons.isEmpty else {
            self.groups = []
            return
        }

        // Group based on selected type
        switch groupingType {
            case .byName:
                self.groups = groupByName(filteredPersons)
            case .byGroup:
                self.groups = groupByGroup(filteredPersons)
            case .byArea:
                self.groups = groupByArea(filteredPersons)
        }
        
        updateGroupIds()
    }
    
    private func updateGroupIds() {
        self.groupIds = Set(self.groups.map{ $0.id })
    }
    
    func getGroupIds(fromIds ids: [String]) -> Set<String> {
        return self.groupIds.intersection(ids)
    }

    // MARK: - Private Grouping Helpers

    private func groupByName(_ persons: [Person]) -> [PersonGroup] {
        // Group by chosung (first character of nameFirstCharacters)
        let grouped = Dictionary(grouping: persons) { person in
            String(person.nameFirstCharacters.prefix(1))
        }

        let sortedKeys = grouped.keys.sorted { isAscending ? $0 < $1 : $0 > $1 }

        return sortedKeys.map { key in
            PersonGroup(title: key, persons: grouped[key] ?? [])
        }
    }

    private func groupByGroup(_ persons: [Person]) -> [PersonGroup] {
        let grouped = Dictionary(grouping: persons) { person in
            person.group?.name ?? "소속 없음"
        }

        let sortedKeys = grouped.keys.sorted { isAscending ? $0 < $1 : $0 > $1 }

        return sortedKeys.map { key in
            PersonGroup(title: key, persons: grouped[key] ?? [])
        }
    }

    private func groupByArea(_ persons: [Person]) -> [PersonGroup] {
        let grouped = Dictionary(grouping: persons) { person in
            person.area ?? "지역 없음"
        }

        let sortedKeys = grouped.keys.sorted { isAscending ? $0 < $1 : $0 > $1 }

        return sortedKeys.map { key in
            PersonGroup(title: key, persons: grouped[key] ?? [])
        }
    }

    // MARK: - Chosung Navigation

    /// Get the next section to navigate to (based on last visible section)
    /// - Parameters:
    ///   - persons: All persons in the list
    ///   - lastVisibleSectionID: ID of the last visible section (nil if none visible)
    /// - Returns: The next section, or nil if at the end
    func nextGroup(ofGroupWithId groupId: String) -> PersonGroup? {
        guard !groups.isEmpty else { return nil }

        // If no visible section, return first section
        let endGroupIndex = groups.index(before: groups.endIndex)
        guard let indexOfGroup = groups.firstIndex(where: { $0.id == groupId }), indexOfGroup < endGroupIndex else {
            return nil
        }
        
        let nextGroupIndex = groups.index(after: indexOfGroup)

        return groups[nextGroupIndex]
    }
}
