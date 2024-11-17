//
//  DAModelController+DAEventInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 20..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation

extension DAModelController{
    func loadEvents(_ group : DAEventGroupInfo, isAscending : Bool = true, name : String = "", area : String = "") -> [DAPersonGroup]{
        var values : [Int : DAPersonGroup] = [:];
        
        let nameCho = name.getKoreanChoSeongs() ?? "";
        let nameKors = (name.getKoreanParts() ?? "").trim();
        
        let areaCho = area.getKoreanChoSeongs() ?? "";
        let areaKors = (area.getKoreanParts() ?? "").trim();
        
        //var predicate_name_area : NSPredicate! = self.createPredicateWithNameAreaForEvents(name, area: area);
        let events = group.groupEvents;
        
        for event in events{
            let personGroup = DAPersonGroup();
            personGroup.id = Int(event.no);
            personGroup.name = event.name ?? "";
            personGroup.detail = event.detail ?? "";
            personGroup.webs = event.eventWebs;
            
            for member in event.eventMembers{
                var filter = false;
                
                if name.isEmpty && area.isEmpty{
                    filter = true;
                }
                
                guard !filter else{
                    if let person = member.person{
                        personGroup.persons.append(person);
                    }
                    continue;
                }
                
                guard let person = member.person,
                    let nameFirstCharacters = person.nameFirstCharacters,
                    let nameCharacters = person.nameCharacters,
                    let areaFirstCharacters = person.areaFirstCharacters,
                    let areaCharacters = person.areaFirstCharacters else{
                        continue;
                }
                
                if name == nameCho, let person = member.person{
                    filter = nameFirstCharacters.contains(nameCho);
                }else if !name.isEmpty{
                    filter = name.contains(nameCho);
                    if !filter && !nameKors.isEmpty, let person = member.person{
                        filter = nameCharacters.contains(nameKors);
                    }
                }
                
                guard !filter else{
                    if let person = member.person{
                        personGroup.persons.append(person);
                    }
                    continue;
                }
                
                if area == areaCho{
                    filter = areaFirstCharacters.contains(areaCho);
                }else if !name.isEmpty{
                    filter = area.contains(areaCho);
                    if !filter && !areaKors.isEmpty{
                        filter = areaCharacters.contains(areaKors);
                    }
                }
                
                if filter{
                    personGroup.persons.append(person);
                }
                //print("load person. spell[\(spell)] count[\(group.persons.count)]");
            }
            
            guard !personGroup.persons.isEmpty else{
                continue;
            }
            
            print("filter event members. event[\(personGroup.name)] total[\(event.eventMembers.count)] filtered[\(personGroup.persons.count)]");
            
            personGroup.persons = personGroup.persons.sorted(by: { (left, right) -> Bool in
                guard let leftName = left.name, let rightName = right.name else{
                    return true;
                }
                
                return (isAscending && leftName.compare(rightName) == .orderedAscending)
                    || (!isAscending && leftName.compare(rightName) == .orderedDescending);
            });
            values[personGroup.id] = personGroup;
        }
        
        return values.values.sorted(by: { (left, right) -> Bool in
            return left.persons.count > right.persons.count ;
        });
    }
    
    func createPredicateWithNameAreaForEvents(_ name : String, area: String  = "") -> NSPredicate?{
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
            values.append(NSPredicate(format: "ANY %@ IN members.nameFirstCharacters", nameCho));
        }else if !name.isEmpty{
            values.append(NSPredicate(format: "ANY %@ IN members.name", name));
            if !nameKors.isEmpty{
                values.append(NSPredicate(format: "ANY %@ IN members.nameCharacters", nameKors))
            }
        }
        
        if area == areaCho{
            values.append(NSPredicate(format: "ANY %@ IN members.areaFirstCharacters", areaCho));
        }else if !area.isEmpty{
            values.append(NSPredicate(format: "ANY %@ IN members.area", area));
            if !areaKors.isEmpty{
                values.append(NSPredicate(format: "ANY %@ IN members.areaCharacters", areaKors));
            }
        }
        
        return NSCompoundPredicate(orPredicateWithSubpredicates: values);
    }
}
