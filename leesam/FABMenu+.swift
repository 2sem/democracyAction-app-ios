//
//  FABMenu+.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 15..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import Material
import UIKit

extension FABMenu{
    func hitTestItems(_ point: CGPoint, with event: UIEvent?) -> UIView?{
        var value : UIView?;
        
        guard self.fabMenuItems.count > 1 && self.isOpened else{
            return value;
        }
        
        var i = 0;
        for item in self.fabMenuItems{
            var targetPoint = self.convert(point, to: item.fabButton);
            //var targetPoint = item.fabButton.convert(point, to: self);
            value = item.fabButton.hitTest(targetPoint, with: event);
            #if DEBUG
                //print("hitTest items of menu. [\(i)] point[\(point)] targetPoint[\(targetPoint)] item[\(item.fabButton.convert(item.fabButton.bounds, to: self))] view[\(value)]");
            #endif
            //item.fabButton.backgroundColor = Color.blue;
            
            i += 1;
            if value != nil {
                break;
            }
        }
        
        return value;
    }
}
