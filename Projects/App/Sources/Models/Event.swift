//
//  Event.swift
//  democracyaction
//
//  SwiftData models for events - migrated from DAEventInfo, DAEventGroupInfo, DAEventPersonInfo
//

import Foundation
import SwiftData

@Model
final class EventGroup {
    @Attribute(.unique) var no: Int16
    var name: String
    var detail: String?
    
    @Relationship(deleteRule: .nullify) var events: [Event]?
    
    init(no: Int16, name: String) {
        self.no = no
        self.name = name
    }
}

@Model
final class Event {
    @Attribute(.unique) var no: Int32
    var name: String
    var detail: String?
    
    @Relationship(deleteRule: .nullify) var members: [EventPerson]?
    @Relationship(deleteRule: .nullify) var webs: [Web]?
    
    init(no: Int32, name: String) {
        self.no = no
        self.name = name
    }
}

@Model
final class EventPerson {
    var person: Person?
    
    init(person: Person? = nil) {
        self.person = person
    }
}
