//
//  UIView+.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 29..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    var viewController : UIViewController?{
        get{
            var value : UIViewController?;
            
            let next = self.next;
            guard next != nil else{
                return value;
            }
            
            //            if let n = next as? UIViewController {
            if next is UIViewController{
                value = next as? UIViewController;
                return value;
            } else{
                value = (next as? UIView)?.viewController;
            }
            
            return value;
        }
    }
}
