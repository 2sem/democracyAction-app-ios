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
