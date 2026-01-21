//
//  PoliticianListViewModel.swift
//  democracyaction
//
//  ViewModel for PoliticianListScreen - manages state and business logic
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
class PoliticianListViewModel: ObservableObject {
    // MARK: - Published Properties

    /// Sort direction: true = ascending, false = descending
    @Published var isAscending: Bool = true

    /// Currently selected political party filter (nil = all)
    @Published var selectedGroup: Group?

    /// Search text for filtering
    @Published var searchText: String = ""

    // MARK: - Computed Properties

    /// Sort icon name for toolbar button
    var sortIconName: String {
        isAscending ? "arrow.down.doc" : "arrow.up.doc"
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

        // Filter by search text (if implemented later)
        if !searchText.isEmpty {
            result = result.filter { person in
                person.name.localizedCaseInsensitiveContains(searchText) ||
                (person.area?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        // Apply sorting
        return sortedPersons(result)
    }
}
