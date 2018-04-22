//
//  DAEventGroupInfo+.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 20..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import CoreData

extension DAEventGroupInfo{
    var groupEvents : [DAEventInfo]{
        get{
            //return self.persons as? Set<DAEventGroupInfo>;
            return self.mutableSetValue(forKey: "events").allObjects as? [DAEventInfo] ?? [];
        }
    }
    
    func findEvent(_ no : Int) -> DAEventInfo?{
        return self.groupEvents.first(where: { (event) -> Bool in
            return event.no == Int32(no);
        });
            /*.first(where: { (event) -> Bool in
            return event.no == no;
        });*/
    }
    
    func createEvent(no: Int32, name : String, detail: String = "") -> DAEventInfo{
        let event = NSEntityDescription.insertNewObject(forEntityName: DAModelController.EntityNames.DAEventInfo, into: DAModelController.Default.context) as! DAEventInfo;
        
        event.no = no;
        event.name = name;
        event.detail = detail;
        
        self.addToEvents(event);
        //self.phones = self.personPhones.adding(phone) as NSSet;
        print("create event. no[\(no)] name[\(name)]");
        return event;
    }
    
    public override var description: String{
        get{
            return self.name ?? "";
        }
    }
}
