//
//  MainViewController.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 8..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import ProgressWebViewController
import Crashlytics

class MainViewController: UITabBarController {

    private(set) static var shared : MainViewController!;
    static var staringtUrl : URL!;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        type(of: self).shared = self;
        if let url = type(of: self).staringtUrl{
            var webView = ProgressWebViewController.init(nibName: nil, bundle: nil);
            webView.url = url;
            webView.hidesBottomBarWhenPushed = true;
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        //Crashlytics.sharedInstance().crash();
    }
    
    func pushToCurrent(viewController : UIViewController, animated: Bool = true){
        guard let nav = self.selectedViewController as? UINavigationController else{
            return;
        }
        
        nav.pushViewController(viewController, animated: animated);
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //AppDelegate.sharedGADManager?.show(unit: .full);
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
