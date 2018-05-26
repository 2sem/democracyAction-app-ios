//
//  DAEventInfo+.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 20..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import CoreData

extension DAEventInfo{
    var eventMembers : [DAEventPersonInfo]{
        get{
            //return self.persons as? Set<DAEventGroupInfo>;
            return self.mutableSetValue(forKey: "members").allObjects as? [DAEventPersonInfo] ?? [];
        }
    }
    
    var eventWebs : [DAWebInfo]{
        get{
            //return self.persons as? Set<DAPersonInfo>;
            return self.mutableSetValue(forKey: "webs").allObjects as? [DAWebInfo] ?? [];
        }
    }
    
    var eventYoutube : DAWebInfo?{
        get{
            return self.findWebUrl(DAWebInfo.EntityNames.youtube);
        }
    }
    
    var eventBlog : DAWebInfo?{
        get{
            return self.findWebUrl(DAWebInfo.EntityNames.blog);
        }
    }
    
    var eventHomepage : DAWebInfo?{
        get{
            return self.findWebUrl(DAWebInfo.EntityNames.homepage);
        }
    }
    
    var eventCafe : DAWebInfo?{
        get{
            return self.findWebUrl(DAWebInfo.EntityNames.cafe);
        }
    }
    
    func findWebUrl(_ name : String) -> DAWebInfo? {
        return (self.webs?.allObjects as? [DAWebInfo] ?? []).first(where: { (web) -> Bool in
            return web.name == name;
        })
    }
    
    func createEventPerson(_ person: DAPersonInfo) -> DAEventPersonInfo{
        let eventPerson = NSEntityDescription.insertNewObject(forEntityName: DAModelController.EntityNames.DAEventPersonInfo, into: DAModelController.shared.context) as! DAEventPersonInfo;
        
        eventPerson.person = person;
        
        self.addToMembers(eventPerson);
        //self.phones = self.personPhones.adding(phone) as NSSet;
        print("create event. no[\(person.no)] name[\(person.name?.description ?? "")]");
        return eventPerson;
    }
}
