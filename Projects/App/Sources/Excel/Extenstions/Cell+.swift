//
//  Cell+.swift
//  App
//
//  Created by 영준 이 on 11/10/24.
//

import CoreXLSX
import Foundation

extension Cell{
    func doubleValue(_ sharedStrings: SharedStrings) -> Double?{
        Double(self.stringValue(sharedStrings) ?? "")
    }
    
    func integerValue(_ sharedStrings: SharedStrings) -> Int?{
        guard let value = self.doubleValue(sharedStrings) else {
            return nil
        }
        
        return Int(value)
    }
    
    func boolValue(_ sharedStrings: SharedStrings) -> Bool?{
        guard let value = self.stringValue(sharedStrings) else {
            return nil
        }
        
        guard let boolFromString = Bool(value) else {
            guard let intFromString = Int(value) else {
                return nil
            }
            
            return .init(truncating: intFromString as NSNumber)
        }
        
        return boolFromString
    }
}
