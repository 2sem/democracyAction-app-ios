//
//  DAModelController+DAExcelGroupInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 26..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import CoreData

extension DAModelController{
    func sync(_ excel : DAExcelController){
        print("[start] sync excel groups to database");

        excel.loadFromFlie();
        
        self.removeMissimgPersons(excel);
        self.syncGroups(excel);
        //shared();

        self.syncEvents(excel);
        
        DAModelController.shared.saveChanges();
        DADefaults.DataVersion = excel.version;
        print("[end] sync excel to database");
    }
    
    func removeMissimgPersons(_ excel : DAExcelController){
        print("[start] sync excel persons to database");
        let excelPersons = excel.persons; //load from excel
        var modelPersons =  self.loadPersons(); //load from database
        for excelPerson in excelPersons{
            //find person by excel id
            guard let modelPerson = self.findPerson(Int16(excelPerson.id)) else{
                continue;
            }
            
            //find 
            if let index = modelPersons.index(of: modelPerson){
                modelPersons.remove(at: index);
            }
        }
        
        for modelPerson in modelPersons{
            self.removePerson(modelPerson);
        }
        
        self.saveChanges();
        
        print("[end] sync excel persons to database");
    }
    
    func syncGroups(_ excel : DAExcelController){
        print("[start] sync excel groups to database");
        let excelGroups = excel.groups.values;
        for excelGroup in excelGroups{
            //load groups from database
            //check if the group is already exist in database
            var modelGroup : DAGroupInfo! = DAModelController.shared.findGroup(Int16(excelGroup.id));
            if modelGroup == nil{
                //create new group
                modelGroup = DAModelController.shared.createGroup(num: Int16(excelGroup.id), name: excelGroup.title, detail: excelGroup.detail);
            }else{
                //update new group
                modelGroup.name = excelGroup.title;
                modelGroup.detail = excelGroup.detail;
                print("update group. no[\(modelGroup.no.description)] name[\(modelGroup.name ?? "")]");
            }
            
            modelGroup.sponsor = Int32(excelGroup.sponsor) ?? 0;
            modelGroup.syncPhones(excelGroup);
            modelGroup.syncMessageTools(excelGroup);
            modelGroup.syncWebUrls(excelGroup);
            
            //load person's for the groups
            for excelPerson in excelGroup.persons{
                //check if the group is already exist in database
                var modelPerson : DAPersonInfo! = DAModelController.shared.findPerson(Int16(excelPerson.id));
                
                if modelPerson == nil || modelPerson.name != excelPerson.name{
                    modelPerson = DAModelController.shared.findPerson(name: excelPerson.name, area: excelPerson.area, groupNo: Int16(excelGroup.id));
                }
                
                if modelPerson == nil{
                    //create new person
                    modelPerson = DAModelController.shared.createPerson(no: Int16(excelPerson.id), name: excelPerson.name, area: excelPerson.area);
                    
                    modelGroup.addToPersons(modelPerson);
                    modelPerson.group = modelGroup;
                }else{
                    //update person
                    modelPerson.personName = excelPerson.name;
                    modelPerson.personArea = excelPerson.area;
                    
                    if modelPerson.group?.no != Int16(excelGroup.id){
                        //move to new group
                        modelPerson.group?.removeFromPersons(modelPerson);
                        modelGroup.addToPersons(modelPerson);
                        modelPerson.group = modelGroup;
                    }
                    
                    //fix excel person, bug caused by the typing mistake
                    if modelPerson.no != Int16(excelPerson.id){
                        modelPerson.no = Int16(excelPerson.id);
                    }
                }
                
                //sync other datas
                modelPerson.job  = excelPerson.title;
                modelPerson.email = excelPerson.email;
                modelPerson.sponsor = Int32(excelPerson.sponsor);
                
                if excelPerson.assembly > "0"{
                    modelPerson.assembly = Int32(excelPerson.assembly, radix: 10)!;
                }
                
                modelPerson.syncPhones(excelPerson);
                modelPerson.syncMessageTools(excelPerson);
                modelPerson.syncWebUrls(excelPerson);
            }
        }
        
        print("[end] sync excel groups to database");
    }
    
    func syncEvents(_ excel : DAExcelController){
        print("[start] sync excel events to database");
        let excelGroups = excel.eventGroups;
        for excelGroup in excelGroups{
            //load groups from database
            //check if the group is already exist in database
            var modelGroup : DAEventGroupInfo! = DAModelController.shared.findEventGroup(Int16(excelGroup.no));
            if modelGroup == nil{
                //create new group
                modelGroup = DAModelController.shared.createEventGroup(no: Int16(excelGroup.no), name: excelGroup.name, detail: excelGroup.detail);
            }else{
                //update new group
                modelGroup.name = excelGroup.name;
                modelGroup.detail = excelGroup.detail;
                print("update event group. no[\(modelGroup.no.description)] name[\(modelGroup.name ?? "")]");
            }
            
            //load event's for the event group
            for excelEvent in excelGroup.events{
                //check if the event is already exist in database
                var modelEvent : DAEventInfo! = modelGroup.findEvent(excelEvent.no);
                
                if modelEvent == nil{
                    //create new event
                    modelEvent = modelGroup.createEvent(no: Int32(excelEvent.no), name: excelEvent.title, detail: excelEvent.detail);
                }else{
                    //update event
                    modelEvent.name = excelEvent.title;
                    modelEvent.detail = excelEvent.detail;
                    print("update event. no[\(modelEvent.no.description)] name[\(modelEvent.name ?? "")]");
                }
                
                modelEvent.syncMembers(excelEvent);
                //DAModelController.shared.saveChanges();
                modelEvent.syncWebUrls(excelEvent);
            }
        }
        
        print("[end] sync excel events to database");
    }
}
