//
//  PoliticianListViewModel.swift
//  democracyaction
//
//  ViewModel for PoliticianListScreen
//

import Foundation
import SwiftUI
import SwiftData
import LSExtensions

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

    /// Predefined areas for grouping (matches UIKit implementation)
    static let predefinedAreas = ["서울", "경기", "부산", "인천", "대구", "대전",
                                  "광주", "울산", "세종", "강원", "충북", "충남",
                                  "전북", "전남", "경북", "경남", "제주", "비례대표"]

    // MARK: - Computed Properties

    /// Sort icon name for toolbar button
    var sortIconName: String {
        isAscending ? "arrow.up.circle" : "arrow.down.circle"
    }
    
    // MARK: - Actions
    
    /// Toggle sort direction
    func toggleSort() {
        isAscending.toggle()
        // Re-sort the groups without changing person order within groups
        sortGroups()
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
        guard !searchText.isEmpty else {
            return sortedPersons(persons)
        }
        
        // Pre-calculate Korean parts of the search text once
        let searchParts = searchText.getKoreanParts()?.trim() ?? ""
        let searchChosungs = searchText.getKoreanChoSeongs()?.trim() ?? ""
        
        let result = persons.filter { person in
            person.matches(searchText: searchText, searchParts: searchParts, searchChosungs: searchChosungs)
        }

        // Apply sorting to the filtered results
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

    /// Sort groups only, without changing person order within groups
    private func sortGroups() {
        groups.sort { left, right in
            isAscending ? left.id < right.id : left.id > right.id
        }
        updateGroupIds()
    }

    // MARK: - Private Grouping Helpers

    private func groupByName(_ persons: [Person]) -> [PersonGroup] {
        var groups: [PersonGroup] = []
        
        // Iterate through predefined chosungs (matches UIKit's koreanSingleChoSeongs)
        for chosung in Self.allChosungs {
            // Filter persons whose first character matches this chosung
            var matchingPersons = persons.filter { person in
                let firstChar = String(person.nameFirstCharacters.prefix(1))
                return firstChar == chosung
            }
            
            // For specific chosungs, also include their double consonant versions
            // This matches UIKit's logic in loadGroupsBySpell
            switch chosung {
            case "ㄱ":
                matchingPersons += persons.filter { String($0.nameFirstCharacters.prefix(1)) == "ㄲ" }
            case "ㄷ":
                matchingPersons += persons.filter { String($0.nameFirstCharacters.prefix(1)) == "ㄸ" }
            case "ㅂ":
                matchingPersons += persons.filter { String($0.nameFirstCharacters.prefix(1)) == "ㅃ" }
            case "ㅅ":
                matchingPersons += persons.filter { String($0.nameFirstCharacters.prefix(1)) == "ㅆ" }
            case "ㅈ":
                matchingPersons += persons.filter { String($0.nameFirstCharacters.prefix(1)) == "ㅉ" }
            default:
                break
            }
            
            // Skip empty groups
            guard !matchingPersons.isEmpty else {
                continue
            }
            
            // Create group for this chosung
            groups.append(PersonGroup(title: chosung, persons: matchingPersons))
        }
        
        // Sort groups by title according to sort order
        // Note: allChosungs is already in the correct order, but we need to respect isAscending
        if !isAscending {
            groups.reverse()
        }
        
        return groups
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
        var groups: [PersonGroup] = []

        // Iterate through predefined areas
        for area in Self.predefinedAreas {
            // Filter persons whose area contains this predefined area string
            let matchingPersons = persons.filter { person in
                guard let personArea = person.area else { return false }
                return personArea.contains(area)
            }

            // Skip empty groups
            guard !matchingPersons.isEmpty else {
                continue
            }

            // Create group for this area
            groups.append(PersonGroup(title: area, persons: matchingPersons))
        }

        // Sort groups by title according to sort order
        groups.sort { left, right in
            isAscending ? left.title < right.title : left.title > right.title
        }

        return groups
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
