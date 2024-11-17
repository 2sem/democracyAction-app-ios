//
//  DAModelController+DAEventPersonInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 8. 10..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation

extension DAModelController{
    func removeEventPerson(_ person: DAEventPersonInfo){
        self.context.delete(person);
    }
}
