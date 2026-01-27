//
//  Person.swift
//  democracyaction
//
//  SwiftData model - migrated from DAPersonInfo
//

import Foundation
import SwiftData

@Model
final class Person {
    @Attribute(.unique) var no: Int16
    var name: String
    var nameCharacters: String
    var nameFirstCharacter: String
    var nameFirstCharacters: String
    
    var area: String?
    var areaCharacters: String?
    var areaFirstCharacter: String?
    var areaFirstCharacters: String?
    
    var email: String?
    var job: String?
    var sponsor: Int32?
    
    // Relationships
    var group: Group?
    @Relationship(deleteRule: .cascade, inverse: \Phone.person) var phones: [Phone]?
    @Relationship(deleteRule: .cascade, inverse: \MessageTool.person) var messages: [MessageTool]?
    @Relationship(deleteRule: .cascade, inverse: \Web.person) var webs: [Web]?
    @Relationship(deleteRule: .cascade, inverse: \Favorite.person) var favorite: Favorite?
    
    init(no: Int16, name: String, nameCharacters: String, nameFirstCharacter: String, nameFirstCharacters: String) {
        self.no = no
        self.name = name
        self.nameCharacters = nameCharacters
        self.nameFirstCharacter = nameFirstCharacter
        self.nameFirstCharacters = nameFirstCharacters
    }
    
    // Computed properties
    var photo: URL? {
        Bundle.main.url(forResource: "\(no)", withExtension: "jpg", subdirectory: "photos") 
        ?? Bundle.main.url(forResource: "\(no)", withExtension: "png", subdirectory: "photos")
    }
    
    var personPhones: [Phone] {
        phones ?? []
    }
    
    var personSms: Phone? {
        personPhones.first(where: { $0.sms })
    }
    
    func findMessageTool(_ name: String) -> MessageTool? {
        messages?.first(where: { $0.name == name })
    }
    
    func findWebUrl(_ name: String) -> Web? {
        webs?.first(where: { $0.name == name })
    }
}
