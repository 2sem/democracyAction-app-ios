//
//  DAExcelGroupInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 8..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation

class DAExcelGroupInfo : NSObject{
    var id : Int = 0;
    var title : String = "";
    var detail : String = "";
    var persons : [DAExcelPersonInfo] = [];
}
