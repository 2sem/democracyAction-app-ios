//
//  DAModelController+DAPersonInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 26..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import CoreData

extension DAModelController{
    func loadPersons(predicate : NSPredicate? = nil, sortWays: [NSSortDescriptor]? = [], completion: (([DAPersonInfo], NSError?) -> Void)? = nil) -> [DAPersonInfo]{
        //        self.waitInit();
        print("begin to load from \(self.classForCoder)");
        var values : [DAPersonInfo] = [];
        
        let requester = NSFetchRequest<NSFetchRequestResult>(entityName: EntityNames.DAPersonInfo);
        requester.predicate = predicate;
        requester.sortDescriptors = sortWays;
        
        //        requester.predicate = NSPredicate(format: "name == %@", "Local");
        
        do{
            values = try self.context.fetch(requester) as! [DAPersonInfo];
            print("fetch persons with predicate[\(predicate)] count[\(values.count)]");
            completion?(values, nil);
        } catch let error{
            fatalError("Can not load persons from DB");
        }
        
        return values;
    }
    
    func isExistPerson(_ name : String) -> Bool{
        var predicate = NSPredicate(format: "name == \"\(name)\"");
        return !self.loadGroups(predicate: predicate, sortWays: nil).isEmpty;
    }
    
    func findPerson(_ no : Int16) -> [DAPersonInfo]{
        var predicate = NSPredicate(format: "no == \(no)");
        return self.loadPersons(predicate: predicate, sortWays: nil);
    }
    
    func findPerson(name : String, area : String) -> [DAPersonInfo]{
        var predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [NSPredicate(format: "ANY %@ IN name", name), NSPredicate(format: "ANY %@ IN area", area)]);
        
        return self.loadPersons(predicate: predicate, sortWays: nil);
    }
    
    func findPerson(no : Int16, groupNo : Int16) -> DAPersonInfo?{
        var predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "no == \(no)"), NSPredicate(format: "group.no == \(no)")]);
        
        return self.loadPersons(predicate: predicate, sortWays: nil).first;
    }
    
    func createPerson(no: Int16, name : String, area: String = "") -> DAPersonInfo{
        let person = NSEntityDescription.insertNewObject(forEntityName: EntityNames.DAPersonInfo, into: self.context) as! DAPersonInfo;
        
        person.no = no;
        person.personName = name;
        
        person.personArea = area;
        
        return person;
    }
    
    func removePerson(_ person: DAPersonInfo){
        self.context.delete(person);
    }
    
    func refresh(person: DAPersonInfo){
        self.context.refresh(person, mergeChanges: false);
    }
}
