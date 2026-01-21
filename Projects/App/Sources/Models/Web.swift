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
    
    init(name: String? = nil, url: String? = nil) {
        self.name = name
        self.url = url
    }
    
    // Entity names for web types
    enum EntityNames {
        static let youtube = "유튜브"
        static let blog = "블로그"
        static let homepage = "홈페이지"
        static let cafe = "카페"
        static let cyworld = "싸이월드"
    }
}
