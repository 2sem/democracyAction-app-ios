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
            case .byGroup: return "정당"
            case .byArea: return "지역구"
            }
        }
    }
    
    enum SearchScope: CaseIterable {
        case all
        case name
        case area
        
        var title: String {
            switch self {
            case .all: return "모두"
            case .name: return "이름"
            case .area: return "지역구"
            }
        }
    }

    struct PersonGroup: Identifiable {
        var id: String { title }
        let title: String
        let persons: [Person]
        let group: Group?  // Party/group reference for accessing phones, social media, etc.
    }

    // MARK: - Published Properties

    /// Search text for filtering
    @Published var searchText: String = ""

    /// Search scope for filtering
    @Published var searchScope: SearchScope = .all

    /// Grouping type for list organization
    @Published var groupingType: GroupingType = .byName
    
    /// Debounce timer for search
    private var searchDebounceTimer: Timer?
    
    /// Debounced refresh function
    func debouncedRefresh(withPersons persons: [Person], completion: @escaping () -> Void) {
        searchDebounceTimer?.invalidate()
        
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            Task { @MainActor in
                self.updateGroups(withPersons: persons)
                completion()
            }
        }
    }

    /// Current chosung index for navigation
    @Published var currentChosungIndex: Int = 0
    
    @Published var groups: [PersonGroup] = []

    // MARK: - Constants

    /// All Korean chosungs in order
    static let allChosungs = ["ㄱ", "ㄴ", "ㄷ", "ㄹ", "ㅁ", "ㅂ", "ㅅ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]

    /// Predefined areas for grouping (matches UIKit implementation)
    static let predefinedAreas = ["서울", "경기", "부산", "인천", "대구", "대전",
                                  "광주", "울산", "세종", "강원", "충북", "충남",
                                  "전북", "전남", "경북", "경남", "제주", "비례대표"]

    /// Apply sorting to persons array
    func sortedPersons(_ persons: [Person]) -> [Person] {
        persons.sorted { left, right in
            left.name < right.name
        }
    }
    
    /// Apply filtering and sorting to persons array
    func filteredAndSortedPersons(_ persons: [Person]) -> [Person] {
        guard !searchText.isEmpty else {
            return sortedPersons(persons)
        }
        
        // Pre-calculate Korean parts of the search text once
        let searchParts = searchText.getKoreanParts(false)?.trim() ?? ""
        let searchChosungs = searchText.getKoreanChoSeongs(false)?.trim() ?? ""
        
        let result = persons.filter { person in
            person.matches(searchText: searchText, searchParts: searchParts, searchChosungs: searchChosungs, searchScope: searchScope)
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
            groups.append(PersonGroup(title: chosung, persons: matchingPersons, group: nil))
        }
        
        return groups
    }

    private func groupByGroup(_ persons: [Person]) -> [PersonGroup] {
        let grouped = Dictionary(grouping: persons) { person in
            person.group?.name ?? "소속 없음"
        }

        let sortedKeys = grouped.keys.sorted()

        return sortedKeys.map { key in
            let personsInGroup = grouped[key] ?? []
            let group = personsInGroup.first?.group  // All persons in this group have the same Group
            return PersonGroup(title: key, persons: personsInGroup, group: group)
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
            groups.append(PersonGroup(title: area, persons: matchingPersons, group: nil))
        }

        return groups
    }
}
