//
//  DAModelController+DAFavoriteInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 28..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import CoreData

extension DAModelController{
    func loadFavorites(predicate : NSPredicate? = nil, sortWays: [NSSortDescriptor]? = [], completion: (([DAFavoriteInfo], NSError?) -> Void)? = nil, onlyOne : Bool = false) -> [DAFavoriteInfo]{
        //        self.waitInit();
        print("begin to load from \(self.classForCoder)");
        var values : [DAFavoriteInfo] = [];
        
        let requester = NSFetchRequest<NSFetchRequestResult>(entityName: EntityNames.DAFavoriteInfo);
        requester.predicate = predicate;
        requester.sortDescriptors = sortWays;
        if onlyOne{
            requester.fetchLimit = 1;
        }
        
        //        requester.predicate = NSPredicate(format: "name == %@", "Local");
        
        do{
            values = try self.context.fetch(requester) as! [DAFavoriteInfo];
            print("fetch persons with predicate[\(predicate.debugDescription)] count[\(values.count)]");
            completion?(values, nil);
        } catch{
            fatalError("Can not load persons from DB");
        }
        
        return values;
    }
    
    func createPredicateWithNameAreaForFavorites(_ name : String, area: String  = "") -> NSPredicate?{
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
            values.append(NSPredicate(format: "ANY %@ IN person.nameFirstCharacters", nameCho));
        }else if !name.isEmpty{
            values.append(NSPredicate(format: "ANY %@ IN person.name", name));
            if !nameKors.isEmpty{
                values.append(NSPredicate(format: "ANY %@ IN person.nameCharacters", nameKors))
            }
        }
        
        if area == areaCho{
            values.append(NSPredicate(format: "ANY %@ IN person.areaFirstCharacters", areaCho));
        }else if !area.isEmpty{
            values.append(NSPredicate(format: "ANY %@ IN person.area", area));
            if !areaKors.isEmpty{
                values.append(NSPredicate(format: "ANY %@ IN person.areaCharacters", areaKors));
            }
        }
        
        return NSCompoundPredicate(orPredicateWithSubpredicates: values);
    }
    
    func loadFavoritesByName(_ isAscending : Bool = true, name : String = "", area : String = "") -> [DAFavoriteInfo]{
        //var values : [DAFavoriteInfo] = [];
        //let i = 0;
        
        let predicate_name_area : NSPredicate! = self.createPredicateWithNameAreaForFavorites(name, area: area);
        
        let favorites = self.loadFavorites(predicate: predicate_name_area, sortWays: [NSSortDescriptor.init(key: "person.name", ascending: isAscending)], completion: nil);
    
        return favorites;
    }
    
    func isExistFavorite(_ person : DAPersonInfo) -> Bool{
        let predicate = NSPredicate(format: "person == %@", person.objectID);
        return !self.loadFavorites(predicate: predicate, sortWays: nil, onlyOne: true).isEmpty;
    }
    
    func findFavorite(_ person : DAPersonInfo) -> DAFavoriteInfo?{
        let predicate = NSPredicate(format: "person == %@", person.objectID);
        return self.loadFavorites(predicate: predicate, sortWays: nil, onlyOne: true).first;
    }
    
    @discardableResult
    func createFavorite(person: DAPersonInfo) -> DAFavoriteInfo{
        let favorite = NSEntityDescription.insertNewObject(forEntityName: EntityNames.DAFavoriteInfo, into: self.context) as! DAFavoriteInfo;
        
        favorite.person = person;
        
        return favorite;
    }
    
    func removeFavorite(_ favorite: DAFavoriteInfo){
        self.context.delete(favorite);
    }
    
    func refresh(favorite: DAFavoriteInfo){
        self.context.refresh(favorite, mergeChanges: false);
    }
}
