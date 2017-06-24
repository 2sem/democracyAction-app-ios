//
//  GADInterstialManager.swift
//  sendadv
//
//  Created by 영준 이 on 2017. 4. 12..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol GADInterstialManagerDelegate : NSObjectProtocol{
    func GADInterstialGetLastShowTime() -> Date;
    func GADInterstialUpdate(showTime : Date);
}

class GADInterstialManager : NSObject, GADInterstitialDelegate{
    var window : UIWindow;
    var unitId : String;
    var interval : TimeInterval = 60.0 * 60.0 * 3.0;
    var canShowFirstTime = true;
    var delegate : GADInterstialManagerDelegate?;
    
    init(_ window : UIWindow, unitId : String, interval : TimeInterval = 60.0 * 60.0 * 3.0) {
        self.window = window;
        self.unitId = unitId;
        self.interval = interval;
        
        super.init();
        //self.reset();
    }
    
    func reset(){
        //RSDefaults.LastFullADShown = Date();
        self.delegate?.GADInterstialUpdate(showTime: Date());
    }
    
    var fullAd : GADInterstitial?
    var canShow : Bool{
        get{
            var value = true;
            let now = Date();
            
            guard self.delegate != nil else {
                return value;
            }
            
            let lastShowTime = self.delegate!.GADInterstialGetLastShowTime();
            let time_1970 = Date.init(timeIntervalSince1970: 0);
            
            //(!self.canShowFirstTime &&
            guard self.canShowFirstTime || lastShowTime > time_1970 else{
                if lastShowTime <= time_1970{
                    self.delegate?.GADInterstialUpdate(showTime: now);
                }
                value = false;
                return value;
            }
            
            let spent = now.timeIntervalSince(lastShowTime);
            value = spent > self.interval;
            print("time spent \(spent) since \(lastShowTime). now[\(now)]");
            
            return value;
        }
    }
    func show(){
        guard self.canShow else {
            return;
        }
        
        guard self.fullAd?.hasBeenUsed ?? true else{
            print("full ad is not yet used - self.fullAd?.hasBeenUsed");
            self._show();
            return;
        }
        
        print("create new full ad");
        self.fullAd = GADInterstitial(adUnitID: self.unitId);
        self.fullAd?.delegate = self;
        let req = GADRequest();
        /*if let alert = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController as? UIAlertController{
            alert.dismiss(animated: false, completion: nil);
         }
        }*/
        
        self.fullAd?.load(req);
    }
    
    private func _show(){
        guard self.window.rootViewController != nil else{
            return;
        }
        
        guard self.canShow else {
            return;
        }
        
        //ignore if alert is being presented
        /*if let alert = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController as? UIAlertController{
            alert.dismiss(animated: false, completion: nil);
        }*/
        
        guard !(UIApplication.shared.keyWindow?.rootViewController?.presentedViewController is UIAlertController) else{
            //alert.dismiss(animated: false, completion: nil);
            self.fullAd = nil;
            return;
        }
        
        print("present full ad view[\(self.window.rootViewController)]");
        self.fullAd?.present(fromRootViewController: self.window.rootViewController!);
        self.delegate?.GADInterstialUpdate(showTime: Date());
        //RSDefaults.LastFullADShown = Date();
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("Interstitial is ready to be presented");
        
        self._show();
    }
    
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        self.fullAd = nil;
    }
}
