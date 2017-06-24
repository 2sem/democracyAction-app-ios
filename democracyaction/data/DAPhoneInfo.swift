//
//  DAPhoneInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 8..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation

class DAPhoneInfo : NSObject {
    var title = "";
    var number = "";
    
    init(title : String, number : String) {
        super.init();
        
        self.title = title;
        self.number = number;
    }
}
