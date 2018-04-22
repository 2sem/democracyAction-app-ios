//
//  DAGroupInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 26..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import CoreData

extension DAGroupInfo{
    var groupPersons : NSMutableSet{
        get{
            //return self.persons as? Set<DAPersonInfo>;
            return self.mutableSetValue(forKey: "persons");
        }
    }
    
    var groupPhones : [DAPhoneInfo]{
        get{
            return self.mutableSetValue(forKey: "phones").allObjects as? [DAPhoneInfo] ?? [];
        }
    }
    
    var groupTwitter : DAMessageToolInfo?{
        get{
            return self.findMessageTool(DAMessageToolInfo.EntityNames.twitter);
        }
    }
    
    var groupFacebook : DAMessageToolInfo?{
        get{
            return self.findMessageTool(DAMessageToolInfo.EntityNames.facebook);
        }
    }
    
    var groupKakao : DAMessageToolInfo?{
        get{
            return self.findMessageTool(DAMessageToolInfo.EntityNames.kakao);
        }
    }
    
    var groupInstagram : DAMessageToolInfo?{
        get{
            return self.findMessageTool(DAMessageToolInfo.EntityNames.instagram);
        }
    }
    
    var groupMessages : [DAMessageToolInfo]{
        get{
            //return self.persons as? Set<DAPersonInfo>;
            return self.mutableSetValue(forKey: "messages").allObjects as? [DAMessageToolInfo] ?? [];
        }
    }
    
    var groupWebs : [DAWebInfo]{
        get{
            //return self.persons as? Set<DAPersonInfo>;
            return self.mutableSetValue(forKey: "webs").allObjects as? [DAWebInfo] ?? [];
        }
    }
    
    var groupYoutube : DAWebInfo?{
        get{
            return self.findWebUrl(DAWebInfo.EntityNames.youtube);
        }
    }
    
    var groupBlog : DAWebInfo?{
        get{
            return self.findWebUrl(DAWebInfo.EntityNames.blog);
        }
    }
    
    var groupHomepage : DAWebInfo?{
        get{
            return self.findWebUrl(DAWebInfo.EntityNames.homepage);
        }
    }
    
    var groupCafe : DAWebInfo?{
        get{
            return self.findWebUrl(DAWebInfo.EntityNames.cafe);
        }
    }
    
    var groupCyworld : DAWebInfo?{
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
