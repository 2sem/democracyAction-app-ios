//
//  DAExcelPersonInfo+DAPersonInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 26..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation

extension DAPersonInfo{
    func syncPhones(_ person : DAExcelPersonInfo){
        //remove all office phones of the person from database
        self.removeFromPhones(self.phones!)
        self.phones = [];
        for excelPhone in person.phones{
            var phone = self.createPhone(name: excelPhone.title, number: excelPhone.number, canSendSMS: false);
            if phone.name == "휴대폰"{
                phone.sms = true;
            }
        }
        
        //add sms number into database
        /*if !person.sms.isEmpty {
            self.createPhone(name: "SMS", number: person.sms, canSendSMS: true);
        }*/
    }
    
    func syncMessageTool(_ person : DAExcelPersonInfo, name : String, value : String){
        var tool = self.findMessageTool(name);
        if tool == nil && !value.isEmpty{
            self.createMessageTool(name: name, account: value);
        }
        else if tool != nil && value.isEmpty{
            self.removeFromMessages(tool!);
        }else{
            tool?.account = value;
        }
    }
    
    func syncMessageTools(_ person : DAExcelPersonInfo){
        //add message tool info - email
        //self.syncMessageTool(person, name: DAMessageToolInfo.EntityNames.email, value: person.email);
        
        //add message tool info - twitter
        self.syncMessageTool(person, name: DAMessageToolInfo.EntityNames.twitter, value: person.twitter);
        
        //add message tool info - facebook
        self.syncMessageTool(person, name: DAMessageToolInfo.EntityNames.facebook, value: person.facebook);
        
        //add message tool info - kakao
        self.syncMessageTool(person, name: DAMessageToolInfo.EntityNames.kakao, value: person.kakao);
    }
    
    func syncWebUrl(_ person : DAExcelPersonInfo, name : String, value : String){
        var webUrl = self.findWebUrl(name);
        if webUrl == nil && !value.isEmpty{
            self.createWeb(name: name, url: value);
        }
        else if webUrl != nil && value.isEmpty{
            self.removeFromWebs(webUrl!);
        }else{
            webUrl?.url = value;
        }
    }
    
    func syncWebUrls(_ person : DAExcelPersonInfo){
        //add web url - youtube
        self.syncWebUrl(person, name: DAWebInfo.EntityNames.youtube, value: person.youtube);
        
        //add web url - homepage
        self.syncWebUrl(person, name: DAWebInfo.EntityNames.homepage, value: person.web);
        
        //add blog url - blog
        self.syncWebUrl(person, name: DAWebInfo.EntityNames.blog, value: person.blog);
        
        //add cafe url - cafe
        self.syncWebUrl(person, name: DAWebInfo.EntityNames.cafe, value: person.cafe);
        
        //add cyworld url - cyworld
        self.syncWebUrl(person, name: DAWebInfo.EntityNames.cyworld, value: person.cyworld);
    }
}
