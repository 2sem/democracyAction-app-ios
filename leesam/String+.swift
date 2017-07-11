//
//  String+.swift
//  WhoCallMe
//
//  Created by 영준 이 on 2016. 3. 11..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit

extension String {
    var any : Bool{
        get{
            return !self.isEmpty;
        }
    }
    
    func localized(_ defaultText : String? = nil, locale: Locale? = Locale.current) -> String{
        var value = self;
        var bundlePath : String? = nil;
        if bundlePath == nil{
            bundlePath = Bundle.main.path(forResource: locale?.identifier, ofType: "lproj");
        }
        if bundlePath == nil{
            bundlePath = Bundle.main.path(forResource: locale?.languageCode, ofType: "lproj");
        }
        if bundlePath == nil{
            bundlePath = Bundle.main.path(forResource: "\(locale?.languageCode ?? "")-\(locale?.scriptCode ?? "")", ofType: "lproj");
        }
        
        //check if specified lang equals to base lang
        if bundlePath == nil && locale?.languageCode == "en"{
            bundlePath = Bundle.main.path(forResource: nil, ofType: "lproj");
        }
        if bundlePath == nil{
            value = NSLocalizedString(defaultText ?? self, comment: "");
        }else{
            var bundle = Bundle(path: bundlePath!)!;
            //            value = bundle.localizedString(forKey: self, value: defaultText ?? self, table: nil);
            
            value = bundle.localizedString(forKey: self, value: defaultText ?? self, table: nil);
            //            value = NSLocalizedString(self, tableName: nil, bundle: bundle, value: defaultText ?? self, comment: "");
        }
        
        return value;
        //        return NSLocalizedString(defaultText ?? self, comment: "");
    }

    func containsKorean() -> Bool{
        var value = false;
        
        for char in self.characters{
            value = char.isKorean();
            if value {
                break;
            }
        }
        
        return value;
    }
    
    func getKoreanChoSeongs(_ double2One : Bool = true) -> String?{
        var value : String = "";
        
        guard self.containsKorean() else {
            return value;
        }
        
        var noKorean = true;
        var lastCho = "";
        for (i, char) in self.characters.enumerated(){
            var cho = char.getKoreanChoseong();
            
            if double2One && cho != nil{
                let doubleCho = lastCho.getMergeKoreanChoseong(cho!);
                if !doubleCho.isEmpty{
                    value.replaceSubrange((value.characters.index(value.endIndex, offsetBy: -1) ..< value.endIndex), with: "");
                    cho = doubleCho;
                }
            }
            
            value += cho != nil ? cho! : (noKorean ? "" : " ");
            //NSLog("\(char) => \(cho) - \(String(char))");
            noKorean = cho == nil;
            
            lastCho = cho ?? "";
//            var singleString = String(char);
//            var scalars = singleString.unicodeScalars;
//            var scalarString = "";
//            
//            for scalar in scalars{
//                scalarString = String(format:"%X ", scalar.value);
//            }
//            NSLog("[\(i)] \(char) hash[\(char.hashValue)] scalar[\(scalarString)]");
        }
        
        //어 : C5B4 = ㅇ(U+3147) + ㅓ(U+3153)
        //hangul jungseong - begin - ㅏ(U+314F) 1161
        //가(U+AC00) = ㄱ(U+3131, U+1100, U+11A8)
        //각(U+AC01) =
        //아(U+C544) = ㅇ(U+3147) + ㅏ(U+314F, U+1161)
        //NSLog("###### \(value) ######");
        return value;
    }
    
    func getMergeKoreanChoseong(_ targetChoseong : String) -> String{
        var value = "";
        
        switch(self){
            case "ㄱ":
                if targetChoseong == "ㄱ"{
                    value = "ㄲ";
                }
                break;
            case "ㄷ":
                if targetChoseong == "ㄷ"{
                    value = "ㄸ";
                }
                break;
            case "ㅂ":
                if targetChoseong == "ㅂ"{
                    value = "ㅃ";
                }
                break;
            case "ㅅ":
                if targetChoseong == "ㅅ"{
                    value = "ㅆ";
                }
                break;
            case "ㅈ":
                if targetChoseong == "ㅉ"{
                    value = "ㅉ";
                }
            break;
            default:
                break;
        }
        
        return value;
    }
    
    func getKoreanParts(_ double2One : Bool = true) -> String?{
        var value : String = "";
        
        guard self.containsKorean() else {
            return value;
        }
        
        var noKorean = true;
        var lastCho = "";
        for (i, char) in self.characters.enumerated(){
            var kor = char.getKoreanParts();
            
            //print("get parts \(char) => \(kor)");
            
            value += kor ?? "";
        }
        
        //어 : C5B4 = ㅇ(U+3147) + ㅓ(U+3153)
        //hangul jungseong - begin - ㅏ(U+314F) 1161
        //가(U+AC00) = ㄱ(U+3131, U+1100, U+11A8)
        //각(U+AC01) =
        //아(U+C544) = ㅇ(U+3147) + ㅏ(U+314F, U+1161)
        //NSLog("###### \(value) ######");
        return value;
    }

    
    var length : Int{
        get{
            return self.characters.count;
        }
    }
    
    func trim() -> String{
        return self.trimmingCharacters(in: CharacterSet.whitespaces);
    }

    func isHex() -> Bool{
        var value = true;
        
        let hexStrings = "abcdef0123456789";
        let lower = self.lowercased();
        
        for char in lower.characters {
            let range = hexStrings.range(of: String(char));
            //print("find \(char) in \(hexStrings) => \(range)");
            
            if range == nil || range?.isEmpty == true{
                value = false;
                break;
            }
        }
        
        if self.length <= 0{
            value = false;
        }
        
        return value;
    }
    
    func toUIColor() -> UIColor?{
        var value : UIColor?;
        let colorString = self.trim();
        
        guard colorString.length >= 6 else{
            return value;
        }
        
        var index = self.startIndex;
        
        //skip #
        if self[index] == "#"  {
            index = self.index(index, offsetBy: 1);
        }
        
        let length = self.substring(from: index).length;
        if length < 6 {
            return value;
        }
        
        do{
            //parse each 2 characters
            let rString = self.substring(with: index..<self.index(index, offsetBy: 2));
            index = self.index(index, offsetBy: 2);
            
            let gString = self.substring(with: index..<self.index(index, offsetBy: 2));
            index = self.index(index, offsetBy: 2);
            
            let bString = self.substring(with: index..<self.index(index, offsetBy: 2));
            
            var aString = "";
            if length > 6 {
                index = self.index(index, offsetBy: 2);
                
                aString = self.substring(with: index..<(self.index(index, offsetBy: 2)));
            }
            
            //check string is hex string to avoid fatalError
            if !rString.isHex(){
                throw StringExtensionError.invalidHex("[\(rString)] is not hex string.");
            }
            
            if !gString.isHex(){
                throw StringExtensionError.invalidHex("[\(gString)] is not hex string.");
            }
            
            if !bString.isHex(){
                throw StringExtensionError.invalidHex("[\(bString)] is not hex string.");
            }
            
            var alpha : CGFloat = 1.0;
            //faltalError will be raised if string is not hex string
            let rValue = CGFloat(Int(rString, radix: 16)!) / 255.0;
            let gValue = CGFloat(Int(gString, radix: 16)!) / 255.0;
            let bValue = CGFloat(Int(bString, radix: 16)!) / 255.0;
            
            if aString.isHex(){
                alpha = CGFloat(Int(aString, radix: 16)!) / 255.0;
            }
            
            value = UIColor(red: rValue, green: gValue, blue: bValue, alpha: alpha);
            print("create color[\(value)] with [\(self)]");
        }catch(let error){
            print("invalid color value[\(self)] error[\(error)]");
        }
        
        return value;
    }
    
    func toDate(_ format : String = "yyyy-MM-dd'T'HH:mm:ssZZZZ") -> Date?{
        let formatter = DateFormatter();
        formatter.dateFormat = format;
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul");
        
        return formatter.date(from: self);
    }
}

enum StringExtensionError : Error{
    case invalidHex(String);
}
