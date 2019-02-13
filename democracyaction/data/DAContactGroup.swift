//
//  DAContactGroup.swift
//  democracyaction
//
//  Created by 영준 이 on 2019. 2. 13..
//  Copyright © 2019년 leesam. All rights reserved.
//

import Foundation

class DAContactGroup : NSObject{
    var name : String;
    var contacts : [DAContact] = [];
    func append(_ contact : DAContact){
        self.contacts.append(contact);
    }
    
    init(_ name: String) {
        self.name = name;
    }
}
