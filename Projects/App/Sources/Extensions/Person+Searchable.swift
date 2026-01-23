//
//  Person+Searchable.swift
//  democracyaction
//
//  Created by Gemini on 2026-01-23.
//

import Foundation
import LSExtensions

extension Person {
    /// Checks if the person matches the given search text, including Korean-specific character matching.
    ///
    /// - Parameters:
    ///   - searchText: The raw search text.
    ///   - searchParts: Pre-calculated Korean jamo/decomposed parts of the search text.
    ///   - searchChosungs: Pre-calculated Korean chosung/initial-consonant parts of the search text.
    /// - Returns: `true` if the person is a match, otherwise `false`.
    func matches(searchText: String, searchParts: String, searchChosungs: String) -> Bool {
        // Match by decomposed characters (jamo) on name OR area
        if !searchParts.isEmpty {
            if self.nameCharacters.contains(searchParts) { return true }
            if let areaCharacters = self.areaCharacters, areaCharacters.contains(searchParts) { return true }
        }

        // Match by initial consonants (chosung) on name OR area
        if !searchChosungs.isEmpty && searchChosungs == searchText {
            if self.nameFirstCharacters.contains(searchChosungs) { return true }
            if let areaFirstCharacters = self.areaFirstCharacters, areaFirstCharacters.contains(searchChosungs) { return true }
        }

        // Standard substring match on name OR area
        if self.name.contains(searchText) { return true }
        if let area = self.area, area.contains(searchText) { return true }

        return false
    }
}
