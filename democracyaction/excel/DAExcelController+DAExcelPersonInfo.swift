//
//  DAExcelController+DAExcelPersonInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 20..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import XlsxReaderWriter

extension DAExcelController{
    var congessSheet : BRAWorksheet?{
        get{
            return self.document?.workbook.worksheetNamed("congressman");
        }
    }
    
    func loadPersonFields(){
        self.personCellNames = self.loadColumns(sheet: self.congessSheet!, line: DAExcelController.headerCellLine, beginCell: DAExcelController.beginCellColumn);
    }
    
    func getCongressCell(column : String?, line : Int) -> BRACell?{
        guard self.personCellNames[column ?? ""] != nil else{
            return nil;
        }
        
        return self.congessSheet?.cell(forCellReference: "\(self.personCellNames[column ?? ""] ?? "")\(line)");
    }
    func loadCongress(_ person : DAExcelPersonInfo, row : Int? = nil){
        let i = row ?? (person.id - 1 + DAExcelController.congressStartRow);
        
        guard !person.isLoaded else{
            return;
        }
        
        let field = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.field, line: i)?.stringValue() ?? "";
        let mobile = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.mobile, line: i)?.stringValue() ?? "";
        let office_asm = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.office_asm, line: i)?.stringValue() ?? "";
        let office_area = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.office_area, line: i)?.stringValue() ?? "";
        let email = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.email, line: i)?.stringValue() ?? "";
        let twitter = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.twitter, line: i)?.stringValue() ?? "";
        let facebook = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.facebook, line: i)?.stringValue() ?? "";
        let kakao = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.kakao, line: i)?.stringValue() ?? "";
        let instagram = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.instagram, line: i)?.stringValue() ?? "";
        let youtube = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.youtube, line: i)?.stringValue() ?? "";
        let web = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.web, line: i)?.stringValue() ?? "";
        let blog = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.blog, line: i)?.stringValue() ?? "";
        let cafe = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.cafe, line: i)?.stringValue() ?? "";
        let cyworld = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.cyworld, line: i)?.stringValue() ?? "";
        let assembly = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.assembly, line: i)?.value ?? "";
        let sponsor = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.sponsor, line: i)?.value ?? "";
        
        person.area = field;
        person.mobile = mobile;
        person.office_asm = office_asm;
        person.office_area = office_area;
        person.parseNumbers();
        
        //person.sms = sms;
        person.email = email;
        person.twitter = twitter;
        person.facebook = facebook;
        person.kakao = kakao;
        person.instagram = instagram;
        person.youtube = youtube;
        person.web = web;
        person.blog = blog;
        person.cafe = cafe;
        person.cyworld = cyworld;
        person.assembly = assembly;
        person.sponsor = Int(sponsor) ?? 0;
        
        person.isLoaded = true;
    }
    
    func loadCongresses(_ groups : [DAExcelGroupInfo] = []) -> [DAExcelPersonInfo]{
        var values : [DAExcelPersonInfo] = [];
        var i = DAExcelController.congressStartRow;
        
        while(true){
            let no = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.no, line: i)?.stringValue() ?? "";
            let name = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.name, line: i)?.stringValue() ?? "";
            let title = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.title, line: i)?.stringValue() ?? "";
            let groupId = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.group, line:i)?.stringValue() ?? "";
            
            guard !no.isEmpty else{
                break;
            }
            
            guard !name.isEmpty else{
                i += 1;
                continue;
            }
            
            let person = DAExcelPersonInfo();
            person.id = Int(no) ?? 0;
            person.groupId = Int(groupId) ?? 0;
            let group = groups.filter({ (group) -> Bool in
                return group.id == person.groupId
            }).first;
            
            guard groups.isEmpty || group != nil else{
                i += 1;
                continue;
            }
            
            guard person.id > 0 else{
                continue;
            }
            
            person.name = name;
            person.title = title;
            person.groupId = Int(groupId) ?? 0;
            
            self.loadCongress(person, row : i);
            
            group?.persons.append(person);
            
            values.append(person);
            
            i += 1;
        }
        
        return values;
    }
}
