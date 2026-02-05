//
//  AppDelegate.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 8..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import GoogleMobileAds
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import LSExtensions
import StoreKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let reviewInterval = 30;
    static var firebase : Messaging!;

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        MobileAds.shared.start(completionHandler: nil);
        FirebaseApp.configure();
        Messaging.messaging().delegate = self;
        KakaoManager.initialize()

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
            let category = push["category"] as? String ?? "";

            print("launching with push[\(push)]");
            self.performPushCommand(title, body: body, category: category, info: push);
        }

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard url.scheme == "kakao17b433ae9a9c34394a229a2b1bb94a58" else {
            return false;
        }

        return true;
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        guard DADefaults.LaunchCount % reviewInterval != 0 else{
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
            return;
        }
    }
    
}

extension AppDelegate : UNUserNotificationCenterDelegate{
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs device[\(deviceToken.hexString)]");
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error)");
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("receive push notification in foreground. identifier[\(notification.request.identifier)] title[\(notification.request.content.title)] body[\(notification.request.content.body)]");
        completionHandler([.alert, .sound]);
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("receive push. title[\(response.notification.request.content.title)] body[\(response.notification.request.content.body)] userInfo[\(response.notification.request.content.userInfo)]");
        let title = response.notification.request.content.title;
        let msg = response.notification.request.content.body;
        let category = response.notification.request.content.userInfo["category"] as? String;

        self.performPushCommand(title, body: msg, category: category ?? "", info: response.notification.request.content.userInfo);
        completionHandler();
    }
}

extension AppDelegate : MessagingDelegate{
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("fcm device[\(fcmToken)]");
        type(of: self).firebase = messaging;
        messaging.subscribe(toTopic: "notice");
    }
}

extension AppDelegate{
    func performPushCommand(_ title : String, body : String, category : String, info: [AnyHashable : Any]){
        print("parse push command. category[\(category)] title[\(title)] body[\(body)] info[\(info)]");

        switch category{
        case "congress/law":
            guard let lawId = info["law"] as? String,
                  let url = URL(string: "http://likms.assembly.go.kr/bill/billDetail.do?billId=\(lawId)") else{
                return;
            }

            UIApplication.shared.open(url);
        default:
            print("receive unknown command. category[\(category.debugDescription)]");
            break;
        }
    }
}


