//
//  DAExcelPersonInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 8..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation

class DAExcelPersonInfo : NSObject{
    internal var isLoaded = false;
    
    var id : Int = 0;
    var name = "";
    var title = "";
    var groupId : Int = 0;
    var area = "";
    var mobile = "";
    var office_asm = "";
    var office_area = "";
    //var sms = "";
    var email = "";
    var twitter = "";
    var facebook = "";
    var kakao = "";
    var instagram = "";
    var youtube = "";
    var web = "";
    var blog = "";
    var cafe = "";
    var cyworld = "";
    
    var phones : [DAExcelPhoneInfo] = [];
    private func _parseNumber(_ value : String, title : String) -> [DAExcelPhoneInfo]{
        var values : [DAExcelPhoneInfo] = []
        var i = 0;
        
        guard !value.isEmpty else{
            return values;
        }
        
        var commaNums = value.components(separatedBy: ",");
        for commaNum in commaNums{
            var seqNums = commaNum.components(separatedBy: "~");
            if seqNums.count == 1{
                i += 1;
                values.append(DAExcelPhoneInfo(title: "\(title)\(i)", number: seqNums[0]));
            }else{
                var firstNum = seqNums[0];
                var startNum = Int("\(firstNum.characters.last!)")!;
                var endNum = Int(seqNums[1])!;
                
                var leftNum = seqNums[0].substring(to: firstNum.index(before: firstNum.endIndex));
                for n in startNum...endNum{
                    i += 1;
                    values.append(DAExcelPhoneInfo(title: "\(title)\(i)", number: "\(leftNum)\(n)"));
                }
            }
        }
        
        //remove number if only one item
        if values.count == 1{
            values[0].title = title;
        }
        
        return values;
    }
    
    func parseNumbers(){
        self.phones = [];
        self.phones.append(contentsOf: self._parseNumber(self.mobile, title: "휴대폰"));
        self.phones.append(contentsOf: self._parseNumber(self.office_asm, title: "국회 사무실"));
        self.phones.append(contentsOf: self._parseNumber(self.office_area, title: "지역구 사무실"));
    }
    
    override var description: String{
        var value = "id[\(self.id)] name[\(self.name)] title[\(self.title)] group[\(self.groupId)] field[\(self.area)] office_asm[\(self.office_asm)] office_field[\(self.office_area)]email[\(self.email)] twitter[\(self.twitter)] facebook[\(self.facebook)] kakao[\(self.kakao)] instagram[\(self.instagram)] youtube[\(self.youtube)] web[\(self.web)] blog[\(self.blog)] cafe[\(self.cafe)] cyworld[\(cyworld)]";
        for phone in phones{
            value.append(" \(phone.title)[\(phone.number)]");
        }
        
        return value;
    }
}
