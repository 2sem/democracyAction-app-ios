//
//  DAEventInfo+DAExcelEventInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 20..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import CoreData

extension DAEventInfo{
    func syncMembers(_ excelEvent : DAExcelEventInfo){
        let excelPersons = DAModelController.Default.loadPersons(predicate: NSPredicate.init(format: "#no IN %@", excelEvent.persons), sortWays: nil, completion: nil);
        
        let modelMembers = self.eventMembers.map { (member) -> DAPersonInfo in
            return member.person!;
        }
        
        let newPersons = excelPersons.filter { (person) -> Bool in
            return !modelMembers.contains(where: { (member) -> Bool in
                return member.no == person.no;
            })
        }.map { (person) -> DAEventPersonInfo in
            return self.createEventPerson(person);
        }
        
        let removedMembers = self.eventMembers.filter { (event) -> Bool in
            return !excelEvent.persons.contains(Int(event.person!.no));
        }
        
        /*for member in newMembers{
            self.addToMembers(member);
        }*/
        
        //self.addToMembers(NSSet(array: newPersons));
        
        for member in removedMembers{
            self.removeFromMembers(member);
            DAModelController.Default.removeEventPerson(member);
        }
        
        print("sync event members. event[\(excelEvent.title)] newMembers[\(newPersons.count)] removedMembers[\(removedMembers.count)] member[\(self.eventMembers.count)]");
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
    
    func syncWebUrl(_ event : DAExcelEventInfo, name : String, value : String){
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
    
    func syncWebUrls(_ event : DAExcelEventInfo){
        //add web url - youtube
        //self.syncWebUrl(event, name: DAWebInfo.EntityNames.youtube, value: event.youtube);
        
        //add web url - homepage
        self.syncWebUrl(event, name: DAWebInfo.EntityNames.homepage, value: event.web);
        
        //add blog url - blog
        //self.syncWebUrl(event, name: DAWebInfo.EntityNames.blog, value: event.blog);
        
        //add cafe url - cafe
        //self.syncWebUrl(event, name: DAWebInfo.EntityNames.cafe, value: event.cafe);
        
        //add cyworld url - cyworld
        //self.syncWebUrl(event, name: DAWebInfo.EntityNames.cyworld, value: event.cyworld);
    }
}
