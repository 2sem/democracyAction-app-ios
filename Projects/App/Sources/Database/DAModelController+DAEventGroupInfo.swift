//
//  DAModelController+DAEventGroupInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 20..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import CoreData

extension DAModelController{
    func loadEventGroups(predicate : NSPredicate? = nil, sortWays: [NSSortDescriptor]? = [NSSortDescriptor(key: "no", ascending: true)], completion: (([DAEventGroupInfo], NSError?) -> Void)? = nil) -> [DAEventGroupInfo]{
        print("begin to load from \(self.classForCoder)");
        var values : [DAEventGroupInfo] = [];
        
        let requester = NSFetchRequest<NSFetchRequestResult>(entityName: EntityNames.DAEventGroupInfo);
        requester.predicate = predicate;
        requester.sortDescriptors = sortWays;
        
        //        requester.predicate = NSPredicate(format: "name == %@", "Local");
        
        do{
            values = try self.context.fetch(requester) as! [DAEventGroupInfo];
            print("fetch eventGroups with predicate[\(predicate?.description ?? "")] count[\(values.count)]");
            completion?(values, nil);
        } catch{
            fatalError("Can not load persons from DB");
        }
        
        return values;
    }
    
    func isExistEventGroups(_ no : Int16) -> Bool{
        let predicate = NSPredicate(format: "#no == \"\(no)\"");
        return !self.loadEventGroups(predicate: predicate, sortWays: nil).isEmpty;
    }
    
    func findEventGroup(_ no : Int16) -> DAEventGroupInfo?{
        let predicate = NSPredicate(format: "#no == \(no)");
        return self.loadEventGroups(predicate: predicate, sortWays: nil).first;
    }
    
    /*func findPerson(name : String, area : String) -> [DAPersonInfo]{
     var predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [NSPredicate(format: "ANY %@ IN name", name), NSPredicate(format: "ANY %@ IN area", area)]);
     
     return self.loadPersons(predicate: predicate, sortWays: nil);
     }*/
    
    func createEventGroup(no: Int16, name : String, detail: String = "") -> DAEventGroupInfo{
        let eventGroup = NSEntityDescription.insertNewObject(forEntityName: EntityNames.DAEventGroupInfo, into: self.context) as! DAEventGroupInfo;
        
        eventGroup.no = no;
        eventGroup.name = name;
        eventGroup.detail = detail;
        
        print("create new event group. no[\(no)] name[\(name)]");
        return eventGroup;
    }
    
    func removeEventGroup(_ person: DAEventGroupInfo){
        self.context.delete(person);
    }
    
    func refresh(eventGroup: DAPersonInfo){
        self.context.refresh(eventGroup, mergeChanges: false);
    }
}
