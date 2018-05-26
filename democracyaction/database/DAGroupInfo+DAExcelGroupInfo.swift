//
//  DAGroupInfo+DAExcelGroupInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 12..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation

extension DAGroupInfo{
    func syncPhones(_ group : DAExcelGroupInfo){
        //remove all office phones of the person from database
        //self.removeFromPhones(<#T##value: DAPhoneInfo##DAPhoneInfo#>)
        let phoneSet = NSSet(array: self.groupPhones.filter({ (phone) -> Bool in
            return !phone.sms;
        }));
        self.removeFromPhones(phoneSet);
        for phone in phoneSet{
            DAModelController.shared.removePhone(phone as! DAPhoneInfo);
        }
        /*self.phones = NSSet(array: self.personPhones.filter({ (phone) -> Bool in
         return phone.sms;
         }));*/
        for excelPhone in group.phones{
            if excelPhone.name == "휴대폰"{
                if let mobile = self.groupPhones.filter({ (phone) -> Bool in
                    return !phone.sms;
                }).first, mobile.number?.isEmpty == true {
                    mobile.sms = true;
                }else{
                    self.createPhone(name: excelPhone.name, number: excelPhone.number, canSendSMS: true);
                }
                continue;
            }
            
            self.createPhone(name: excelPhone.name, number: excelPhone.number, canSendSMS: false);
        }
        
        //add sms number into database
        /*if !person.sms.isEmpty {
         self.createPhone(name: "SMS", number: person.sms, canSendSMS: true);
         }*/
    }
    
    func syncMessageTool(_ group : DAExcelGroupInfo, name : String, value : String){
        //find by tool name
        let tool = self.findMessageTool(name);
        if tool == nil && !value.isEmpty{
            //create new tool
            self.createMessageTool(name: name, account: value);
        }
        else if tool != nil && value.isEmpty{
            self.removeFromMessages(tool!);
        }else{
            //update account
            tool?.account = value;
        }
    }
    
    func syncMessageTools(_ group : DAExcelGroupInfo){
        //add message tool info - email
        //self.syncMessageTool(person, name: DAMessageToolInfo.EntityNames.email, value: person.email);
        
        //add message tool info - twitter
        self.syncMessageTool(group, name: DAMessageToolInfo.EntityNames.twitter, value: group.twitter);
        
        //add message tool info - facebook
        self.syncMessageTool(group, name: DAMessageToolInfo.EntityNames.facebook, value: group.facebook);
        
        //add message tool info - kakao
        self.syncMessageTool(group, name: DAMessageToolInfo.EntityNames.kakao, value: group.kakao);
    }
    
    func syncWebUrl(_ group : DAExcelGroupInfo, name : String, value : String){
        //find by url name
        let webUrl = self.findWebUrl(name);
        if webUrl == nil && !value.isEmpty{
            self.createWeb(name: name, url: value);
        }
        else if webUrl != nil && value.isEmpty{
            self.removeFromWebs(webUrl!);
        }else{
            webUrl?.url = value;
        }
    }
    
    func syncWebUrls(_ group : DAExcelGroupInfo){
        //add web url - youtube
        self.syncWebUrl(group, name: DAWebInfo.EntityNames.youtube, value: group.youtube);
        
        //add web url - homepage
        self.syncWebUrl(group, name: DAWebInfo.EntityNames.homepage, value: group.web);
        
        //add blog url - blog
        self.syncWebUrl(group, name: DAWebInfo.EntityNames.blog, value: group.blog);
        
        //add cafe url - cafe
        self.syncWebUrl(group, name: DAWebInfo.EntityNames.cafe, value: group.cafe);
        
        //add cyworld url - cyworld
        self.syncWebUrl(group, name: DAWebInfo.EntityNames.cyworld, value: group.cyworld);
    }
}
