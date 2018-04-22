//
//  DispatchQueue+.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 28..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import UIKit

extension DispatchQueue{
    func syncOrNot(execute block: () -> Swift.Void){
        //dispatchPrecondition(condition: .onQueue(self))
        //DispatchQueue.current
        if Thread.isMainThread{
            block();
        }else{
            self.sync(execute: block);
        }
    }
}
