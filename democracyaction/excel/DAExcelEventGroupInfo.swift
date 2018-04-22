//
//  DAExcelEventGroupInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 20..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation

class DAExcelEventGroupInfo : NSObject{
    class FieldNames{
        static let no = "no";
        static let name = "name";
        static let sheet = "sheet";
        static let detail = "detail";
    }
    
    var no : Int = 0;
    var name : String = "";
    var sheet : String = "";
    var detail : String = "";
    var events : [DAExcelEventInfo] = [];
}
