//
//  UIApplication+.swift
//  democracyaction
//
//  Created by 영준 이 on 2019. 2. 17..
//  Copyright © 2019년 leesam. All rights reserved.
//

import UIKit

extension UIApplication{
    var keyRootViewController: UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
        
        return windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
    }
}
