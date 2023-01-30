//
//  AppDelegate.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 8..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import LSExtensions
import LProgressWebViewController
import GADManager
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ReviewManagerDelegate, GADRewardManagerDelegate {
    var window: UIWindow?
    enum GADUnitName : String{
        case full = "FullAd"
        case info = "InfoBottom"
        case fav = "FavBottom"
    }
    static var sharedGADManager : GADManager<GADUnitName>?;
    var rewardAd : GADRewardManager?;
    var reviewManager : ReviewManager?;
    let reviewInterval = 30;
    var deviceToken : String?;
    static var firebase : Messaging!;

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        DAInfoTableViewController.startingQuery = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL;
        /*launchOptions?.forEach({ (key, value) in
            //print("launch option key[\(key)] value[\(value)]\n");
            DAInfoTableViewController.startingSearchName += "launch option key[\(key)] value[\(value)]\n";
        })*/
        GADMobileAds.sharedInstance().start(completionHandler: nil);
        //GADMobileAds.configure(withApplicationID: "ca-app-pub-968437x8399371172~5739040449");
        FirebaseApp.configure();
        Messaging.messaging().delegate = self;
        
        self.reviewManager = ReviewManager(self.window!, interval: 60.0 * 60 * 24 * 3);
        self.reviewManager?.delegate = self;
        //self.reviewManager?.show();
        
        self.rewardAd = GADRewardManager(self.window!, unitId: GADInterstitialAd.loadUnitId(name: "RewardAd") ?? "", interval: 60.0 * 60.0 * 12); //
        self.rewardAd?.delegate = self;
        
        var adManager = GADManager<GADUnitName>.init(self.window!);
        AppDelegate.sharedGADManager = adManager;
        adManager.delegate = self;
    #if DEBUG
        adManager.prepare(interstitialUnit: .full, interval: 60.0);
    #else
        adManager.prepare(interstitialUnit: .full, interval: 60.0 * 60.0 * 1);
    #endif
        
        adManager.canShowFirstTime = true;
        
        if self.rewardAd?.canShow ?? false{
            //self.fullAd?.show();
        }
        
        UNUserNotificationCenter.current().delegate = self;
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (result, error) in
            guard result else{
                return;
            }
            
            DispatchQueue.main.syncInMain {
                application.registerForRemoteNotifications();
            }
        }
        
        if let push = launchOptions?[.remoteNotification] as? [String: AnyObject]{
            let noti = push["aps"] as! [String: AnyObject];
            let alert = noti["alert"] as! [String: AnyObject];
            let title = alert["title"] as? String ?? "";
            let body = alert["body"] as? String ?? "";
            //Custom data can be receive from 'aps' not 'alert'
            let category = push["category"] as? String ?? "";
            //let item = push["item"] as? String ?? "";
        
            print("launching with push[\(push)]");
            self.performPushCommand(title, body: body, category: category, info: push);
        }
        
        DADefaults.increaseLaunchCount();
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard url.scheme == "kakao17b433ae9a9c34394a229a2b1bb94a58" else {
            return false;
        }
        
        DAInfoTableViewController.startingQuery = url;
        return true;
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        //DAInfoTableViewController.startingQuery = launchOptions?[UIApplicationLaunchOptionsKey.url] as? URL;
        guard DADefaults.LaunchCount % reviewInterval != 0 else{
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
                DADefaults.increaseLaunchCount();
            }
            return;
        }
        
        print("app going to foreground");
        /*guard self.reviewManager?.canShow ?? false else{
            return;
        }
        self.reviewManager?.show();*/
        //self.fullAd?.show();
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func reviewGetLastShowTime() -> Date {
        return DADefaults.LastFullADShown;
    }
    
    func reviewUpdate(showTime: Date) {
        DADefaults.LastFullADShown = showTime;
    }
    
    // MARK: GADRewardManagerDelegate
    func GADRewardGetLastShowTime() -> Date {
        return DADefaults.LastRewardShown;
    }
    
    func GADRewardUserCompleted() {
        DADefaults.LastRewardShown = Date();
    }
    
    func GADRewardUpdate(showTime: Date) {
        
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate{
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //let device = deviceToken.reduce("", {$0 + String(format: "%02X", $1)});
        print("APNs device[\(deviceToken.hexString)]");
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error)");
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //update app
        print("receive push notification in foreground. identifier[\(notification.request.identifier)] title[\(notification.request.content.title)] body[\(notification.request.content.body)]");
        
        //UNNotificationPresentationOptions
        completionHandler([.alert, .sound]);
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("receive push. title[\(response.notification.request.content.title)] body[\(response.notification.request.content.body)] userInfo[\(response.notification.request.content.userInfo)]");
        //let item = response.notification.request.content.userInfo["item"] as? String;
        var title = response.notification.request.content.title;
        var msg = response.notification.request.content.body;
        let category = response.notification.request.content.userInfo["category"] as? String;
        
        self.performPushCommand(title, body: msg, category: category ?? "", info: response.notification.request.content.userInfo);
        print("what the heck");
        /*if let push = launchOptions?[.remoteNotification] as? [String: AnyObject]{
         let noti = push["aps"] as! [String: AnyObject];
         let alert = noti["alert"] as! [String: AnyObject];
         RSSearchTableViewController.startingKeyword = alert["body"] as? String ?? "";
         print("launching with push[\(push)]");
         }*/
        completionHandler();
    }
}

extension AppDelegate : MessagingDelegate{
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("fcm device[\(fcmToken)]");
        let topic = "notice";
        //let topic = "congress_2_9770881_law";
        type(of: self).firebase = messaging;
        messaging.subscribe(toTopic: topic);
        //messaging.unsubscribe(fromTopic: topic);
    }
}

extension AppDelegate{
    func performPushCommand(_ title : String, body : String, category : String, info: [AnyHashable : Any]){
        print("parse push command. category[\(category)] title[\(title)] body[\(body)] info[\(info)]");
        
        switch category{
        case "congress/law":
            guard let lawId = info["law"] as? String else{
                return;
            }
            
            guard let url = URL(string: "http://likms.assembly.go.kr/bill/billDetail.do?billId=\(lawId)") else{
                return;
            }
            
            if let mainView = MainViewController.shared{
                let webView = ProgressWebViewController.init(nibName: nil, bundle: nil);
                //http://likms.assembly.go.kr/bill/billDetail.do?billId=PRC_E1O8N0G7H2T7T1C4A0M1O0O8J7O3F8
                webView.url = URL(string: "http://likms.assembly.go.kr/bill/billDetail.do?billId=\(lawId)");
                webView.hidesBottomBarWhenPushed = true;
                mainView.pushToCurrent(viewController: webView);
            }else{
                MainViewController.staringtUrl = url;
            }
            break;
        default:
            print("receive unkown command. category[\(category.debugDescription)]");
            break;
        }
    }
}

extension AppDelegate : GADManagerDelegate{
    typealias E = GADUnitName
    
    func GAD<E>(manager: GADManager<E>, lastShownTimeForUnit unit: E) -> Date{
        return Date();
    }
    
    func GAD<E>(manager: GADManager<E>, updatShownTimeForUnit unit: E, showTime time: Date){
        
    }
    
    func GAD<E>(manager: GADManager<E>, lastPreparedTimeForUnit unit: E) -> Date{
        let now = Date();
        if DADefaults.LastFullADShown > now{
            DADefaults.LastFullADShown = now;
        }
        
        return DADefaults.LastFullADShown;
        //Calendar.current.component(<#T##component: Calendar.Component##Calendar.Component#>, from: <#T##Date#>)
    }
    
    func GAD<E>(manager: GADManager<E>, updateLastPreparedTimeForUnit unit: E, preparedTime time: Date){
        DADefaults.LastFullADShown = time;

        //RNInfoTableViewController.shared?.needAds = false;
        //RNFavoriteTableViewController.shared?.needAds = false;
    }
    
    func GAD<E>(manager: GADManager<E>, willPresentADForUnit unit: E) where E : Hashable, E : RawRepresentable, E.RawValue == String {
        //DAInfoTableViewController.shared?.needAds = false;
        //DAFavoriteTableViewController.shared?.needAds = false;
    }
}


