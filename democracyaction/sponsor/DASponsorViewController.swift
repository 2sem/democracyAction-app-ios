//
//  DASponsorViewController.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 10. 23..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import ProgressWebViewController

class DASponsorViewController: ProgressWebViewController {

    var originalRightButtons : [UIBarButtonItem] = [];
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.toolbarItemTypes = [.back, .forward, .reload];
        self.websiteTitleInNavigationBar = false;
    }
    
    override func viewDidLoad() {
        self.originalRightButtons = self.navigationItem.rightBarButtonItems ?? [];
        self.toolbarItemTypes = [.back, .forward, .flexibleSpace, .reload];
        super.viewDidLoad();
        // Do any additional setup after loading the view.
        self.load(DASponsor.Urls.advUrl);
        self.websiteTitleInNavigationBar = false;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Open Stat Page of the Sponsing
    */
    @IBAction func onStat(_ button: UIBarButtonItem) {
        let view = ProgressWebViewController.init(nibName: nil, bundle: Bundle.main);
        view.url = DASponsor.Urls.statUrl;
        view.hidesBottomBarWhenPushed = true;
        //view.websiteTitleInNavigationBar = false;
        view.toolbarItemTypes = [.back, .forward, .flexibleSpace, .reload];
        self.navigationController?.pushViewController(view, animated: true);
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
