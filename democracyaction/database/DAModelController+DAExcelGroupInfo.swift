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
        print("[start] sync excel to database");
        var excelGroups = DAExcelController.Default.groups.values;
        for excelGroup in excelGroups{
            //load groups from database
            //check if the group is already exist in database
            var modelGroup : DAGroupInfo! = DAModelController.Default.findGroup(Int16(excelGroup.id));
            if modelGroup == nil{
                //create new group
                modelGroup = DAModelController.Default.createGroup(num: Int16(excelGroup.id), name: excelGroup.title, detail: excelGroup.detail);
            }else{
                //update new group
                modelGroup.name = excelGroup.title;
                modelGroup.detail = excelGroup.detail;
            }
            
            //load person's for the groups
            for excelPerson in excelGroup.persons{
                //check if the group is already exist in database
                var modelPerson : DAPersonInfo! = DAModelController.Default.findPerson(Int16(excelPerson.id));
                
                if modelPerson == nil || modelPerson.name != excelPerson.name{
                    modelPerson = DAModelController.Default.findPerson(name: excelPerson.name, area: excelPerson.area, groupNo: Int16(excelGroup.id));
                }
                
                if modelPerson == nil{
                    //create new person
                    modelPerson = DAModelController.Default.createPerson(no: Int16(excelPerson.id), name: excelPerson.name ?? "", area: excelPerson.area ?? "");
                    
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
                if excelPerson.assembly > "0"{
                    modelPerson.assembly = Int32(excelPerson.assembly ?? "0", radix: 10)!;
                }
                
                modelPerson.syncPhones(excelPerson);
                modelPerson.syncMessageTools(excelPerson)
                modelPerson.syncWebUrls(excelPerson);
            }
        }
        
        DAModelController.Default.saveChanges();
        DADefaults.DataVersion = excel.version;
        print("[end] sync excel to database");
    }
}
