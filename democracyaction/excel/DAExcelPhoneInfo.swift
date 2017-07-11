//
//  DAPhoneInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 8..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation

class DAExcelPhoneInfo : NSObject {
    var name = "";
    var number = "";
    
    init(title : String, number : String) {
        super.init();
        
        self.name = title;
        self.number = number;
    }
}
