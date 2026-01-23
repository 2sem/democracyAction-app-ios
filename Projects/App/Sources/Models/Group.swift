//
//  Group.swift
//  democracyaction
//
//  SwiftData model - migrated from DAGroupInfo
//

import Foundation
import SwiftData

@Model
final class Group {
    @Attribute(.unique) var no: Int16
    var name: String
    var detail: String?
    var sponsor: Int32?
    
    @Relationship(deleteRule: .cascade, inverse: \Person.group) var persons: [Person]?
    @Relationship(deleteRule: .cascade, inverse: \Phone.group) var phones: [Phone]?
    @Relationship(deleteRule: .cascade, inverse: \MessageTool.group) var messages: [MessageTool]?
    @Relationship(deleteRule: .cascade, inverse: \Web.group) var webs: [Web]?
    
    init(no: Int16, name: String) {
        self.no = no
        self.name = name
    }
}
