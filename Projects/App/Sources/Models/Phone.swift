//
//  Phone.swift
//  democracyaction
//
//  SwiftData model - migrated from DAPhoneInfo
//

import Foundation
import SwiftData

@Model
final class Phone {
    var name: String?
    var number: String?
    var sms: Bool = false
    
    var person: Person?
    var group: Group?
    
    init(name: String? = nil, number: String? = nil, sms: Bool = false) {
        self.name = name
        self.number = number
        self.sms = sms
    }
}
