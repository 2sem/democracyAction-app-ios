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
            self.type = .assemply;
        }
        self.source = source;
        //super.init(url: urlComponents!.url);
    }
    
    var type = DASponsor.DASponsorType.party;
    var party = 9001;
    var person = 0;
    var source = DASponsor.Sources.leesam;
    
    var urlRequest : URLRequest{
        //var urlComponents = URLComponents(url: DASponsor.Urls.payUrl, resolvingAgainstBaseURL: true);
        var params = "";
        params.append("pay_prod_gb=\(self.type.rawValue)");
        params.append("&party_no=\(self.party.description)");
        //var queries : [URLQueryItem] = urlComponents?.queryItems ?? [];
        //queries.append(URLQueryItem(name: "pay_prod_db", value: self.type.rawValue));
        //queries.append(URLQueryItem(name: "party_no", value: self.party.description));
        if self.person > 0{
            params.append("&cgrs_no=\(self.person.description)");
            //queries.append(URLQueryItem(name: "cgrs_no", value: self.person.description));
        }
        params.append("&ptnr_no=\(self.source)");
        print("pay request plain params[\(params)]");
        //queries.append(URLQueryItem(name: "ptnr_no", value: self.source));
        
        //urlComponents?.queryItems = queries;
        
        //var url = urlComponents?.url;
        var url : URL?;
        do{
            //let aes = try AES.init(key: "Oq2iAFd6sUH0RUStB1g1LQ==", iv: "", padding: .pkcs5);
            let aes = try AES.init(key: "Oq2iAFd6sUH0RUStB1g1LQ==".bytes, blockMode: .CBC(iv: [UInt8](repeating: 0x00, count: 16)), padding: .pkcs5);
            let enc_bytes = try aes.encrypt(params.bytes);
            //var enc = String.init(bytes: enc_bytes, encoding: .utf8);
            let enc_data = Data(bytes: enc_bytes);
            let enc_base64 = enc_data.base64EncodedString(options: Data.Base64EncodingOptions.endLineWithLineFeed);
            url = URL(string: "\(DASponsor.Urls.payUrl.absoluteString)?parm=\(enc_base64)");
            print("pay request enc params[\(params)] enc[\(enc_base64)] url[\(url?.absoluteString ?? "")]");
        }catch let error{
            print("pay request encrypting has been failed. error[\(error)]");
        }
        
        //do not use queryitem for ServiceKey. / will be escaped not be encoded if it contains in
        //url = URL(string: (url?.absoluteString ?? "") + "&ServiceKey=\(self.serviceKey)");
        
        var req = URLRequest(url: url!);
        //        req.addValue("text/xml", forHTTPHeaderField: "Content-Type");
        req.httpMethod = "GET";
        
        return req;
    }
}
