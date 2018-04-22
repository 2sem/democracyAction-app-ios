//
//  DAPersonInfo+.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 26..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import CoreData

extension DAPersonInfo{
    var personName : String{
        get{
            return self.name ?? "";
        }
        
        set(value){
            self.nameFirstCharacters = value.getKoreanChoSeongs() ?? "";
            self.nameFirstCharacter = self.nameFirstCharacters?.first?.description;
            self.nameCharacters = value.getKoreanParts();
            
            self.name = value;
        }
    }
    
    var personArea : String{
        get{
            return self.area ?? "";
        }
        
        set(value){
            self.areaFirstCharacters = value.getKoreanChoSeongs() ?? "";
            self.areaFirstCharacter = self.areaFirstCharacters?.first?.description;
            self.areaCharacters = value.getKoreanParts();
            self.area = value;
        }
    }
    
    var personEmail : String{
        get{
            return self.email ?? "";
        }
        
        set(value){
            self.email = value;
        }
    }
    
    /*var personPhones : NSMutableSet{
        get{
            //return self.persons as? Set<DAPersonInfo>;
            return self.mutableSetValue(forKey: "phones");
        }
    }*/
    var personPhones : [DAPhoneInfo]{
        get{
            return self.mutableSetValue(forKey: "phones").allObjects as? [DAPhoneInfo] ?? [];
        }
    }
    
    var personSms : DAPhoneInfo?{
        get{
            return self.personPhones.first(where: { (phone) -> Bool in
                return phone.sms;
            })
        }
    }
    
    var personTwitter : DAMessageToolInfo?{
        get{
            return self.findMessageTool(DAMessageToolInfo.EntityNames.twitter);
        }
    }
    
    var personFacebook : DAMessageToolInfo?{
        get{
            return self.findMessageTool(DAMessageToolInfo.EntityNames.facebook);
        }
    }
    
    var personKakao : DAMessageToolInfo?{
        get{
            return self.findMessageTool(DAMessageToolInfo.EntityNames.kakao);
        }
    }
    
    var personInstagram : DAMessageToolInfo?{
        get{
            return self.findMessageTool(DAMessageToolInfo.EntityNames.instagram);
        }
    }
    
    var personMessages : NSMutableSet{
        get{
            //return self.persons as? Set<DAPersonInfo>;
            return self.mutableSetValue(forKey: "messages");
        }
    }
    
    var personWebs : NSMutableSet{
        get{
            //return self.persons as? Set<DAPersonInfo>;
            return self.mutableSetValue(forKey: "webs");
        }
    }
    
    var personYoutube : DAWebInfo?{
        get{
            return self.findWebUrl(DAWebInfo.EntityNames.youtube);
        }
    }
    
    var personBlog : DAWebInfo?{
        get{
            return self.findWebUrl(DAWebInfo.EntityNames.blog);
        }
    }
    
    var personHomepage : DAWebInfo?{
        get{
            return self.findWebUrl(DAWebInfo.EntityNames.homepage);
        }
    }
    
    var personCafe : DAWebInfo?{
        get{
            return self.findWebUrl(DAWebInfo.EntityNames.cafe);
        }
    }
    
    var personCyworld : DAWebInfo?{
        get{
            return self.findWebUrl(DAWebInfo.EntityNames.cyworld);
        }
    }
    
    @discardableResult
    func createPhone(name : String, number: String = "", canSendSMS sms: Bool = false) -> DAPhoneInfo{
        let phone = NSEntityDescription.insertNewObject(forEntityName: DAModelController.EntityNames.DAPhoneInfo, into: DAModelController.Default.context) as! DAPhoneInfo;
        
        phone.name = name;
        phone.number = number
        phone.sms = sms;
        
        self.addToPhones(phone);
        //self.phones = self.personPhones.adding(phone) as NSSet;
        
        return phone;
    }
    
    @discardableResult
    func createMessageTool(name : String, account: String = "") -> DAMessageToolInfo{
        let tool = NSEntityDescription.insertNewObject(forEntityName: DAModelController.EntityNames.DAMessageToolInfo, into: DAModelController.Default.context) as! DAMessageToolInfo;
        
        tool.name = name;
        tool.account = account;
        
        //self.messages = self.personMessages.adding(tool) as NSSet;
        self.addToMessages(tool);
        
        return tool;
    }
    
    @discardableResult
    func createWeb(name : String, url: String = "") -> DAWebInfo{
        let web = NSEntityDescription.insertNewObject(forEntityName: DAModelController.EntityNames.DAWebInfo, into: DAModelController.Default.context) as! DAWebInfo;
        
        web.name = name;
        web.url = url;
        
        self.addToWebs(web);
        //self.webs = self.personWebs.adding(web) as NSSet;
        
        return web;
    }
    
    func findMessageTool(_ name : String) -> DAMessageToolInfo? {
        return (self.messages?.allObjects as? [DAMessageToolInfo] ?? []).first(where: { (tool) -> Bool in
            return tool.name == name;
        })
    }
    
    func findWebUrl(_ name : String) -> DAWebInfo? {
        return (self.webs?.allObjects as? [DAWebInfo] ?? []).first(where: { (web) -> Bool in
            return web.name == name;
        })
    }
}
