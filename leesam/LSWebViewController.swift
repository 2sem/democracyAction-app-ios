//
//  LSWebViewController.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 8. 23..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import WebKit

class LSWebViewController: UIViewController {

    var url : URL?;
    var webView : WKWebView!;
    
    init(url : URL){
        super.init(nibName: nil, bundle: nil);
        self.url = url;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.webView = WKWebView();
        self.view.addSubview(self.webView);
        self.view.topAnchor.constraint(equalTo: self.webView.topAnchor);
        self.view.bottomAnchor.constraint(equalTo: self.webView.bottomAnchor);
        self.view.leadingAnchor.constraint(equalTo: self.webView.leadingAnchor);
        self.view.rightAnchor.constraint(equalTo: self.webView.rightAnchor);
        
        guard self.url != nil else{
            return;
        }
        
        let req = URLRequest(url: self.url!);
        self.webView.load(req);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
