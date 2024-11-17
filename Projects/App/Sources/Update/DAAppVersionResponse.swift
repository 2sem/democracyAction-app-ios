//
//  DAAppVersionResponse.swift
//  democracyaction
//
//  Created by 영준 이 on 2018. 8. 11..
//  Copyright © 2018년 leesam. All rights reserved.
//

import Foundation

/**
 {
     app = "1.1.8";
     required = 1.1.8;
     data = "1.1.8";
 }
 */
struct DAAppVersionResponse : Codable{
    var lastestVersion : String;
    var requiredVersion : String;
    var dataVersion : String;
    
    enum CodingKeys: String, CodingKey{
        case lastestVersion = "app"
        case requiredVersion = "required"
        case dataVersion = "data"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self);
        self.lastestVersion = try container.decode(String.self, forKey: .lastestVersion);
        self.requiredVersion = try container.decode(String.self, forKey: .requiredVersion);
        self.dataVersion = try container.decode(String.self, forKey: .dataVersion);
    }
}
