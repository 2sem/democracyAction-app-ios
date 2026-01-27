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
    var group: Group?
    
    init(name: String? = nil, account: String? = nil) {
        self.name = name
        self.account = account
    }
    
    // Entity names for social media
    enum EntityNames {
        static let twitter = "twitter"
        static let facebook = "facebook"
        static let kakao = "kakao"
        static let instagram = "instagram"
    }
}
