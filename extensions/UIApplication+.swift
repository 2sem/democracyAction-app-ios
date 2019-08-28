//
//  UIApplication+.swift
//  democracyaction
//
//  Created by 영준 이 on 2019. 2. 17..
//  Copyright © 2019년 leesam. All rights reserved.
//

import UIKit

extension UIApplication{
    func isVersion(lessThan version: String, orSame same: Bool = false) -> Bool{
        let value = self.version.compare(version, options: .numeric);
        var candidates : [ComparisonResult] = [.orderedAscending];
        if same{
            candidates.append(.orderedSame);
        }
        
        return candidates.contains(value);
    }

    func isVersion(largerThan version: String, orSame same: Bool = false) -> Bool{
        let value = self.version.compare(version, options: .numeric);
        var candidates : [ComparisonResult] = [.orderedDescending];
        if same{
            candidates.append(.orderedSame);
        }
        
        return candidates.contains(value);
    }
}
