//
//  FABButton+.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 14..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import Material

extension FABButton{
    func clone(_ target : FABButton? = nil) -> FABButton{
        var value = target == nil ? FABButton() : target;
        value?.image = self.image?.withRenderingMode(.alwaysTemplate);
        value?.backgroundColor = self.backgroundColor;
        value?.tintColor = self.tintColor;
        value?.pulseColor = self.pulseColor;
        for performTarget in self.allTargets ?? []{
            //print("clone button - target[\(performTarget)]");
            var actions = self.actions(forTarget: performTarget, forControlEvent: .touchUpInside);
            for action in actions ?? []{
                value?.addTarget(performTarget, action: Selector(action), for: .touchUpInside);
                //print("clone button action[\(action)] target[\(performTarget)]");
            }
        }
        
        return value!;
    }
    
    func cloneAsMenu() -> FABMenuItem{
        var value = FABMenuItem();
        self.clone(value.fabButton);
        
        return value;
    }
}
