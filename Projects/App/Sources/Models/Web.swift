//
//  Web.swift
//  democracyaction
//
//  SwiftData model - migrated from DAWebInfo
//

import Foundation
import SwiftData

@Model
final class Web {
    var name: String?
    var url: String?
    
    var person: Person?
    var group: Group?
    
    init(name: String? = nil, url: String? = nil) {
        self.name = name
        self.url = url
    }
    
    // Entity names for web types
    enum EntityNames {
        static let youtube = "youtube"
        static let blog = "blog"
        static let homepage = "homepage"
        static let cafe = "cafe"
        static let cyworld = "cyworld"
    }
}
