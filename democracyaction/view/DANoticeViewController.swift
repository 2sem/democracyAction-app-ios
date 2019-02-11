//
//  DANoticeViewController.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 8..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit

class DANoticeViewController: UIViewController {

    static let storyboardName = "Main";
    static let storyboardId = "DANoticeViewController";
    
    var text : String?;
    
    @IBOutlet weak var textView: UITextView!
    
    static func instantiate() -> DANoticeViewController?{
        return UIStoryboard.init(name: storyboardName, bundle: Bundle.main).instantiateViewController(withIdentifier: storyboardId) as? DANoticeViewController;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.text = self.text;
        self.textView.contentOffset = CGPoint(x: self.textView.contentInset.left, y: self.textView.contentInset.top);        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onDone(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil);
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
