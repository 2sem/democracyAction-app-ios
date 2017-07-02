//
//  DAGroupInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 26..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation

extension DAGroupInfo{
    var groupPersons : NSMutableSet{
        get{
            //return self.persons as? Set<DAPersonInfo>;
            return self.mutableSetValue(forKey: "persons");
        }
    }
}
