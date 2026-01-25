//
//  DADefaults.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 18..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import UIKit

extension DADefaults {
    static var SwiftDataMigrationCompleted: Bool {
        get {
            return Defaults.bool(forKey: Keys.SwiftDataMigrationCompleted)
        }
        
        set(value) {
            Defaults.set(value, forKey: Keys.SwiftDataMigrationCompleted)
        }
    }
    
    static var InitialDataLoaded: Bool {
        get {
            return Defaults.bool(forKey: Keys.InitialDataLoaded)
        }
        
        set(value) {
            Defaults.set(value, forKey: Keys.InitialDataLoaded)
        }
    }
}

class DADefaults{
    static var Defaults : UserDefaults{
        get{
            return UserDefaults.standard;
        }
    }
    
    class Keys{
        static let LastFullADShown = "LastFullADShown";
        static let LastShareShown = "LastShareShown";
        static let LastRewardShown = "LastRewardShown";
        
        static let LastNotice = "LastNotice";
        static let DataVersion = "DataVersion"
        static let DataDownloaded = "DataDownloaded";
        
        static let LaunchCount = "LaunchCount";
        static let SwiftDataMigrationCompleted = "SwiftDataMigrationCompleted";
        static let InitialDataLoaded = "InitialDataLoaded";
        static let AdsTrackingRequested = "AdsTrackingRequested";
        static let LastOpeningAdPrepared = "LastOpeningAdPrepared";
    }
    
    static var LastFullADShown : Date{
        get{
            let seconds = Defaults.double(forKey: Keys.LastFullADShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastFullADShown);
        }
    }
    
    static var LastShareShown : Date{
        get{
            let seconds = Defaults.double(forKey: Keys.LastShareShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastShareShown);
        }
    }
    
    static var LastRewardShown : Date{
        get{
            let seconds = Defaults.double(forKey: Keys.LastRewardShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastRewardShown);
        }
    }
    
    static var LastNotice : Date{
        get{
            let seconds = Defaults.double(forKey: Keys.LastNotice);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastNotice);
        }
    }
    
    static var DataVersion : String{
        get{
            //UIApplication.shared.version
            return Defaults.string(forKey: Keys.DataVersion) ?? "";
        }
        
        set(value){
            Defaults.set(value, forKey: Keys.DataVersion);
        }
    }
    
    static var DataDownloaded : Bool{
        get{
            //UIApplication.shared.version
            return Defaults.bool(forKey: Keys.DataDownloaded);
        }
        
        set(value){
            Defaults.set(value, forKey: Keys.DataDownloaded);
        }
    }
    
    static func increaseLaunchCount(){
        self.LaunchCount = self.LaunchCount.advanced(by: 1);
    }
    
    static var LaunchCount : Int{
        get{
            //UIApplication.shared.version
            return Defaults.integer(forKey: Keys.LaunchCount);
        }

        set(value){
            Defaults.set(value, forKey: Keys.LaunchCount);
        }
    }

    static var AdsTrackingRequested : Bool{
        get{
            return Defaults.bool(forKey: Keys.AdsTrackingRequested);
        }

        set(value){
            Defaults.set(value, forKey: Keys.AdsTrackingRequested);
        }
    }

    static var LastOpeningAdPrepared : Date{
        get{
            return Defaults.object(forKey: Keys.LastOpeningAdPrepared) as? Date ?? Date.distantPast;
        }

        set(value){
            Defaults.set(value, forKey: Keys.LastOpeningAdPrepared);
        }
    }

}
