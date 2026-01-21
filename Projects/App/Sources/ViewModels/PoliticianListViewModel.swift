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

    struct PersonSection: Identifiable {
        let id = UUID()
        let title: String
        let persons: [Person]
    }

    // MARK: - Published Properties

    /// Sort direction: true = ascending, false = descending
    @Published var isAscending: Bool = true

    /// Currently selected political party filter (nil = all)
    @Published var selectedGroup: Group?

    /// Search text for filtering
    @Published var searchText: String = ""

    /// Grouping type for list organization
    @Published var groupingType: GroupingType = .byName

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

        // Filter by group if selected
        if let selectedGroup = selectedGroup {
            result = result.filter { $0.group?.no == selectedGroup.no }
        }

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
    func groupedPersons(_ persons: [Person]) -> [PersonSection] {
        // First apply filtering and sorting
        let filtered = filteredAndSortedPersons(persons)

        if filtered.isEmpty {
            return []
        }

        // Group based on selected type
        switch groupingType {
        case .byName:
            return groupByName(filtered)
        case .byGroup:
            return groupByGroup(filtered)
        case .byArea:
            return groupByArea(filtered)
        }
    }

    // MARK: - Private Grouping Helpers

    private func groupByName(_ persons: [Person]) -> [PersonSection] {
        let grouped = Dictionary(grouping: persons) { person in
            person.nameFirstCharacter
        }

        let sortedKeys = grouped.keys.sorted { isAscending ? $0 < $1 : $0 > $1 }

        return sortedKeys.map { key in
            PersonSection(title: key, persons: grouped[key] ?? [])
        }
    }

    private func groupByGroup(_ persons: [Person]) -> [PersonSection] {
        let grouped = Dictionary(grouping: persons) { person in
            person.group?.name ?? "소속 없음"
        }

        let sortedKeys = grouped.keys.sorted { isAscending ? $0 < $1 : $0 > $1 }

        return sortedKeys.map { key in
            PersonSection(title: key, persons: grouped[key] ?? [])
        }
    }

    private func groupByArea(_ persons: [Person]) -> [PersonSection] {
        let grouped = Dictionary(grouping: persons) { person in
            person.area ?? "지역 없음"
        }

        let sortedKeys = grouped.keys.sorted { isAscending ? $0 < $1 : $0 > $1 }

        return sortedKeys.map { key in
            PersonSection(title: key, persons: grouped[key] ?? [])
        }
    }
}
