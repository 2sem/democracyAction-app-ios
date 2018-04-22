//
//  DAExcelGroupInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 8..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation

class DAExcelGroupInfo : NSObject{
    class FieldNames{
        static let no = "no";
        static let title = "title";
        static let detail = "detail";
        static let group = "group";
        static let field = "field";
        static let office = "office";
        static let email = "email";
        static let twitter = "twitter";
        static let facebook = "facebook";
        static let kakao = "kakao";
        static let instagram = "instagram";
        static let youtube = "youtube";
        static let web = "web";
        static let blog = "blog";
        static let cafe = "cafe";
        static let cyworld = "cyworld";
        static let image = "image";
        static let sponsor = "sponsor";
    }
    
    var id : Int = 0;
    var title : String = "";
    var detail : String = "";
    var phones : [DAExcelPhoneInfo] = [];
    var persons : [DAExcelPersonInfo] = [];
    
    var office = "";
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
    var image = "";
    var sponsor = "";
    
    private func _parseNumber(_ value : String, title : String) -> [DAExcelPhoneInfo]{
        var values : [DAExcelPhoneInfo] = []
        var i = 0;
        
        guard !value.isEmpty else{
            return values;
        }
        
        let commaNums = value.components(separatedBy: ",");
        for commaNum in commaNums{
            var seqNums = commaNum.components(separatedBy: "~");
            if seqNums.count == 1{
                i += 1;
                values.append(DAExcelPhoneInfo(title: "\(title)\(i)", number: seqNums[0]));
            }else{
                let firstNum = seqNums[0];
                let startNum = Int("\(firstNum.last!)")!;
                let endNum = Int(seqNums[1])!;
                
                let leftNum = String(seqNums[0][...firstNum.index(before: firstNum.endIndex)]);
                for n in startNum...endNum{
                    i += 1;
                    values.append(DAExcelPhoneInfo(title: "\(title)\(i)", number: "\(leftNum)\(n)"));
                }
            }
        }
        
        //remove number if only one item
        if values.count == 1{
            values[0].name = title;
        }
        
        return values;
    }
    
    func parseNumbers(){
        self.phones = [];
        self.phones.append(contentsOf: self._parseNumber(self.office, title: "대표번호"));
    }
}
