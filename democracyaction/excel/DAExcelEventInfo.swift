//
//  DAExcelEventInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 19..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation

class DAExcelEventInfo : NSObject{
    class FieldNames{
        static let no = "no";
        static let title = "title";
        static let sheet = "sheet";
        static let memberId = "memberid";
        static let detail = "detail";
        static let web = "web";
    }

    var no : Int = 0;
    var title : String = "";
    var sheet : String = "";
    var detail : String = "";
    var persons : [Int] = [];
    var web = "";
}
