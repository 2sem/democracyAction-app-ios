//
//  DCSponsorPayRequest.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 10. 20..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import CryptoSwift

class DASponsorPayRequest : NSObject{
    init(party: Int, person: Int = 0, source: String){
        super.init();
        
        self.party = party;
        if person > 0{
            self.person = person;
            self.sponsorType = .assemply;
        }
        self.source = source;
    }
    
    var sponsorType = DASponsor.DASponsorType.party;
    var party = 9001;
    var person = 0;
    var source = DASponsor.Sources.leesam;
    
    static let plistName = "300korea";
    var secretKey : String{
        guard let plist = Bundle.main.path(forResource: type(of: self).plistName, ofType: "plist") else{
            preconditionFailure("Please create plist file named of 300korea. file[\(type(of: self).plistName).plist]");
        }
        
        guard let dict = NSDictionary.init(contentsOfFile: plist) as? [String : String] else{
            preconditionFailure("Please \(type(of: self).plistName).plist is not Property List.");
        }
        
        return dict["SecretKey"] ?? "";
    }
    
    var urlRequest : URLRequest{
        var params = "";
        params.append("pay_prod_gb=\(self.sponsorType.rawValue)");
        params.append("&party_no=\(self.party.description)");
        
        if self.person > 0{
            params.append("&cgrs_no=\(self.person.description)");
        }
        params.append("&ptnr_no=\(self.source)");
        print("pay request plain params[\(params)]");
        var url : URL?;
        do{
            let aes = try AES.init(key: self.secretKey.bytes, blockMode: .CBC(iv: [UInt8](repeating: 0x00, count: 16)), padding: .pkcs5);
            let enc_bytes = try aes.encrypt(params.bytes);
            let enc_data = Data(bytes: enc_bytes);
            let enc_base64 = enc_data.base64EncodedString(options: Data.Base64EncodingOptions.endLineWithLineFeed);
            url = URL(string: "\(DASponsor.Urls.payUrl.absoluteString)?parm=\(enc_base64)");
            print("pay request enc params[\(params)] enc[\(enc_base64)] url[\(url?.absoluteString ?? "")]");
        }catch let error{
            print("pay request encrypting has been failed. error[\(error)]");
        }
        
        var req = URLRequest(url: url!);
        req.httpMethod = "GET";
        
        return req;
    }
}
