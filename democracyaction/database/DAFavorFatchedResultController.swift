//
//  DAFavorFatchedResultController.swift
//  democracyaction
//
//  Created by 영준 이 on 2018. 5. 25..
//  Copyright © 2018년 leesam. All rights reserved.
//

import Foundation
import CoreData

class DAFavorFatchedResultController : NSFetchedResultsController<DAFavoriteInfo>{
    init(managedObjectContext context: NSManagedObjectContext, delegate: NSFetchedResultsControllerDelegate) {
        let request = NSFetchRequest<DAFavoriteInfo>.init(entityName: "DAFavoriteInfo");
        request.sortDescriptors = [NSSortDescriptor.init(key: "person.name", ascending: true)];
        super.init(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil);
        self.delegate = delegate;
    }
    
    func query(_ isAscending : Bool = true, ByName name : String = "", ByArea area : String = ""){
        //var values : [DAFavoriteInfo] = [];
        //let i = 0;
        
        let validPersonPredicate = NSPredicate.init(format: "person.#no > 0");
        if let predicate = self.createPredicateWithNameAreaForFavorites(name, area: area) {
            self.fetchRequest.predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [validPersonPredicate, predicate]);
        }else{
            self.fetchRequest.predicate = validPersonPredicate;
        }
        
        self.fetchRequest.sortDescriptors = self.sortDescriptors(isAscending);
        //self.fetchRequest = isAscending;
        
        do{
            try self.performFetch();
        }catch let error{
            assertionFailure("Can not fetch for favorites");
        }
    }
    
    private func sortDescriptors(_ isAscending : Bool = true) -> [NSSortDescriptor]{
        return [NSSortDescriptor.init(key: "person.name", ascending: isAscending)];
    }
    
    func fetch(indexPath : IndexPath) -> DAFavoriteInfo?{
        return self.object(at: indexPath);
    }
    
    func count(section : Int) -> Int{
        return self.sections?[section].numberOfObjects ?? 0;
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
}
