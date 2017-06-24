//
//  DADefaults.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 18..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation

class DADefaults{
    static var Defaults : UserDefaults{
        get{
            return UserDefaults.standard;
        }
    }
    
    class Keys{
        static let LastFullADShown = "LastFullADShown";
        static let LastShareShown = "LastShareShown";
        
        static let LastNotice = "LastNotice";
    }
    
    static var LastFullADShown : Date{
        get{
            var seconds = Defaults.double(forKey: Keys.LastFullADShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastFullADShown);
        }
    }
    
    static var LastShareShown : Date{
        get{
            var seconds = Defaults.double(forKey: Keys.LastShareShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastShareShown);
        }
    }
    
    static var LastNotice : Date{
        get{
            var seconds = Defaults.double(forKey: Keys.LastNotice);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastNotice);
        }
    }
}
