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
    @Relationship(deleteRule: .nullify) var phones: [Phone]?
    @Relationship(deleteRule: .nullify) var messages: [MessageTool]?
    @Relationship(deleteRule: .nullify) var webs: [Web]?
    
    init(no: Int16, name: String) {
        self.no = no
        self.name = name
    }
}
