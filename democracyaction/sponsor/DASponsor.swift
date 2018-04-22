//
//  DCSponsor.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 10. 20..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation

class DASponsor : NSObject{
    class Urls{
        static let rootDomain = URL(string: "http://www.300korea.or.kr")!;
        static let payUrl = URL.init(string: "www/prod/prod_info", relativeTo: rootDomain)!;
        static let statUrl = URL.init(string: "www/prod/sprt_stst", relativeTo: rootDomain)!;
        static let historyUrl = URL.init(string: "www/pay/pay_hstr/01022856032", relativeTo: rootDomain)!;
        static let advUrl = URL.init(string: "www/prod/prmt?ptnr_no=\(Sources.leesam)", relativeTo: rootDomain)!;
    }
    
    enum DASponsorType : String{
        case assemply = "PPG100";
        case party = "PPG200";
    }
    
    class Sources{
        static let leesam = "PTNR00002";
        static let andycha = "PTNR00001";
    }
}
