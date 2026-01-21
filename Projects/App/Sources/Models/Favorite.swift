//
//  Favorite.swift
//  democracyaction
//
//  SwiftData model - migrated from DAFavoriteInfo
//

import Foundation
import SwiftData

@Model
final class Favorite {
    var isAlarmOn: Bool = false
    var person: Person?
    
    init(isAlarmOn: Bool = false, person: Person? = nil) {
        self.isAlarmOn = isAlarmOn
        self.person = person
    }
}
