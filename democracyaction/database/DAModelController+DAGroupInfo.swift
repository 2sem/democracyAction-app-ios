//
//  DAModelzController+DAGroupInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 24..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import CoreData
import LSExtensions

extension DAModelController{
    func loadGroups(predicate : NSPredicate? = nil, sortWays: [NSSortDescriptor]? = [], completion: (([DAGroupInfo], NSError?) -> Void)? = nil) -> [DAGroupInfo]{
        //        self.waitInit();
        print("begin to load from \(self.classForCoder)");
        var values : [DAGroupInfo] = [];
        
        let requester = NSFetchRequest<NSFetchRequestResult>(entityName: EntityNames.DAGroupInfo);
        requester.predicate = predicate;
        requester.sortDescriptors = sortWays;
        
        //        requester.predicate = NSPredicate(format: "name == %@", "Local");
        
        do{
            values = try self.context.fetch(requester) as! [DAGroupInfo];
            print("fetch groups with predicate[\(predicate?.description ?? "")] count[\(values.count)]");
            /*values.forEach({ (group) in
                print("group name[\(group.name)] num[\(group.no)]");
            })*/
            completion?(values, nil);
        } catch{
            fatalError("Can not load groups from DB");
        }
        
        return values;
    }
    
    func isExistGroup(_ name : String) -> Bool{
        let predicate = NSPredicate(format: "name == \"\(name)\"");
        return !self.loadGroups(predicate: predicate, sortWays: nil).isEmpty;
    }
    
    func findGroup(_ no : Int16) -> DAGroupInfo?{
        //var predicate = NSPredicate(format: "no == %i",  no);
        //var predicate = NSPredicate(format: "no == %@",  "\(no)");
        //var predicate = NSPredicate(format: "no == %@",  no.description);
        //var predicate = NSPredicate(format: "\(DAModelController.EntityNames.DAGroupInfo).no == \(no)");
        //var predicate = NSPredicate(format: "%K == \(no)",  "no");
        let predicate = NSPredicate(format: "#no == \(no)");
        //var predicate = NSPredicate(format: "name == %@",  "자유한국당");
        return self.loadGroups(predicate: predicate, sortWays: nil).first;
    }
    
    func createPredicateWithNameArea(_ name : String, area : String = "") -> NSPredicate?{
        //var predicate : NSPredicate?;
        var values : [NSPredicate] = [];
        
        guard !name.isEmpty || !area.isEmpty else{
            return nil;
        }
        
        let nameCho = name.getKoreanChoSeongs() ?? "";
        let nameKors = (name.getKoreanParts() ?? "").trim();
        
        let areaCho = area.getKoreanChoSeongs() ?? "";
        let areaKors = (area.getKoreanParts() ?? "").trim();

        //var predicateWithName = predicate_name_first;
        
        //if !value.isEmpty{
        if name == nameCho{
            values.append(NSPredicate(format: "ANY %@ IN nameFirstCharacters", nameCho));
        }else if !name.isEmpty{
            values.append(NSPredicate(format: "ANY %@ IN name", name));
            if !nameKors.isEmpty{
                values.append(NSPredicate(format: "ANY %@ IN nameCharacters", nameKors))
            }
        }
        
        if area == areaCho{
            values.append(NSPredicate(format: "ANY %@ IN areaFirstCharacters", areaCho));
        }else if !area.isEmpty{
            values.append(NSPredicate(format: "ANY %@ IN area", area));
            if !areaKors.isEmpty{
                values.append(NSPredicate(format: "ANY %@ IN areaCharacters", areaKors));
            }
        }

        return NSCompoundPredicate(orPredicateWithSubpredicates: values);
    }
    
    func loadGroupsBySpell(_ isAscending : Bool = true, name : String = "", area : String = "") -> [DAPersonGroup]{
        var values : [DAPersonGroup] = [];
        var i = 0;
        
        let predicate_name_area : NSPredicate! = self.createPredicateWithNameArea(name, area: area);
        
        for spell in Character.koreanSingleChoSeongs.sorted(by: { (left, right) -> Bool in
            return isAscending ? left < right : left > right;
        }){
            //var choseongGroup = person.name.getKoreanChoSeongs(false)?.characters.first?.description ?? "";
            var predicate = NSPredicate(format: "nameFirstCharacter == %@", spell);
            
            //for spell group
            if predicate_name_area != nil{
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate_name_area]);
            }
            
            let persons = self.loadPersons(predicate: predicate, sortWays: [NSSortDescriptor.init(key: "name", ascending: isAscending)], completion: nil);
            
            guard !persons.isEmpty else{
                continue;
            }
            
            let group = DAPersonGroup();
            group.id = i;
            group.name = spell;
            group.persons = persons;
            values.append(group);
            i += 1;
            
            //values[firstSpell] = group;
            
            print("load spell group. spell[\(spell)] count[\(group.persons.count)]");
        }
        
        return values;
    }
    
    func loadGroupsByArea(_ isAscending : Bool = true, areas : [String], name : String = "", area : String = "") -> [DAPersonGroup]{
        var values : [DAPersonGroup] = [];
        var i = 0;
        
        let predicate_name_area : NSPredicate! = self.createPredicateWithNameArea(name, area: area);
        
        for area in areas{
            //var choseongGroup = person.name.getKoreanChoSeongs(false)?.characters.first?.description ?? "";
            var predicate = NSPredicate(format: "ANY %@ IN area", area);
            
            //for spell group
            if predicate_name_area != nil{
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate_name_area]);
            }
            
            let persons = self.loadPersons(predicate: predicate, sortWays: [NSSortDescriptor.init(key: "name", ascending: true)], completion: nil);
            
            guard !persons.isEmpty else{
                continue;
            }
            
            let group = DAPersonGroup();
            group.id = i;
            group.name = area;
            group.persons = persons;
            values.append(group);
            i += 1;
            
            //values[firstSpell] = group;
            
            print("load spell group. area[\(area)] count[\(group.persons.count)]");
        }
        
        values.sort { (left, right) -> Bool in
            return isAscending ? left.name < right.name : left.name > right.name;
        }
        
        return values;
    }
    
    func loadGroups(_ isAscending : Bool = true, name : String = "", area : String = "") -> [DAPersonGroup]{
        var values : [Int : DAPersonGroup] = [:];
        
        let predicate_name_area : NSPredicate! = self.createPredicateWithNameArea(name, area: area);
        
        let persons = self.loadPersons(predicate: predicate_name_area, sortWays: [NSSortDescriptor.init(key: "name", ascending: isAscending)], completion: nil);
        
        for person in persons{
            var group = values[Int(person.group?.no ?? 0)]; // person.group?.no ??
            if group == nil{
                group = DAPersonGroup();
                group?.id = Int(person.group?.no ?? 0);
                group?.name = person.group?.name ?? "";
                group?.detail = person.group?.detail ?? "";
                group?.sponsor = Int(person.group?.sponsor ?? 0);
                values[Int(person.group?.no ?? 0)] = group;
                
                group?.phones = person.group?.groupPhones ?? [];
                group?.messages = person.group?.groupMessages ?? [];
                //group?.groupInfo = person.group;
            }
            
            group?.persons.append(person);
            //print("load person. spell[\(spell)] count[\(group.persons.count)]");

        }
    
        return values.values.sorted(by: { (left, right) -> Bool in
            return left.persons.count > right.persons.count;
        });
    }
    
    func createGroup(num: Int16, name : String, detail: String = "") -> DAGroupInfo{
        let group = NSEntityDescription.insertNewObject(forEntityName: EntityNames.DAGroupInfo, into: self.context) as! DAGroupInfo;
        
        group.no = num;
        group.name = name;
        group.detail = detail;
        
        print("create new group. no[\(num)] name[\(name)]");
        
        return group;
    }
    
    func removeGroup(_ group: DAGroupInfo){
        self.context.delete(group);
    }
    
    func refresh(group: DAGroupInfo){
        self.context.refresh(group, mergeChanges: false);
    }    
}
