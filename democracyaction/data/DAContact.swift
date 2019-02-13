//
//  DAContactInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2019. 2. 13..
//  Copyright © 2019년 leesam. All rights reserved.
//

import Foundation

class DAContact : NSObject{
    enum ContactType : Int{
        case phone
        case email
        case sms
        case twitter
        case facebook
        case kakao
        case instagram
        case web
        case blog
        case youtube
        //case search
    }
    
    var contactType : ContactType = .phone;
    var name : String?;
    var value : String;
    
    init(type: ContactType, name: String? = nil, value: String) {
        self.contactType = type;
        self.name = name;
        self.value = value;
    }
}
