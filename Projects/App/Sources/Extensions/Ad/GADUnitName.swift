//
//  GADUnitName.swift
//  App
//
//  Created for SwiftUI AdMob migration
//

import Foundation

extension SwiftUIAdManager {
    enum GADUnitName: String {
        case full = "FullAd"
        case infoBottom = "InfoBottom"
        case favBottom = "FavBottom"
        case native = "Native"

        // Note: These raw values match the KEY names from GADUnitIdentifiers in Info.plist
        // GADManager will lookup actual ad unit IDs from the plist
    }
}
