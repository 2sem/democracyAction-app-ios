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
            //load from database
            var modelGroup : DAGroupInfo! = DAModelController.Default.findGroup(Int16(excelGroup.id));
            if modelGroup == nil{
                modelGroup = DAModelController.Default.createGroup(no: Int16(excelGroup.id), name: excelGroup.title, detail: excelGroup.detail);
            }else{
                modelGroup.name = excelGroup.title;
                modelGroup.detail = excelGroup.detail;
            }
            
            for excelPerson in excelGroup.persons{
                //load from database
                var modelPerson : DAPersonInfo! = DAModelController.Default.findPerson(no: Int16(excelPerson.id), groupNo: Int16(excelGroup.id));
                if modelPerson == nil{
                    modelPerson = DAModelController.Default.createPerson(no: Int16(excelGroup.id), name: excelPerson.name ?? "", area: excelPerson.area ?? "");
                    
                    modelGroup.addToPersons(modelPerson)
                    modelPerson.group = modelGroup;
                }else{
                    modelPerson.personName = excelPerson.name;
                    modelPerson.personArea = excelPerson.area;
                }
                
                modelPerson.job  = excelPerson.title;
                modelPerson.email = excelPerson.email;
                
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
