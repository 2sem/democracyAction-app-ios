//
//  MessageTool.swift
//  democracyaction
//
//  SwiftData model - migrated from DAMessageToolInfo
//

import Foundation
import SwiftData

@Model
final class MessageTool {
    var name: String?
    var account: String?
    
    var person: Person?
    
    init(name: String? = nil, account: String? = nil) {
        self.name = name
        self.account = account
    }
    
    // Entity names for social media
    enum EntityNames {
        static let twitter = "트위터"
        static let facebook = "페이스북"
        static let kakao = "카카오톡"
        static let instagram = "인스타그램"
    }
}
