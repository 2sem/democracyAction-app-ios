//
//  DAExcelController+DAExcelPersonInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 20..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import CoreXLSX

extension DAExcelController{
    var congessSheet : Worksheet!{
        get{
            try! self.document.parseWorksheet(at: workSheetPaths["congressman"]!)
        }
    }
    
    func loadCongress(_ person : DAExcelPersonInfo, cells: [String : Cell]){
        guard !person.isLoaded else{
            return;
        }
        
        let fieldCell = cells[DAExcelPersonInfo.FieldNames.field]
        let mobileCells = cells[DAExcelPersonInfo.FieldNames.mobile]
        let office_asmCell = cells[DAExcelPersonInfo.FieldNames.office_asm]
        let office_areaCell = cells[DAExcelPersonInfo.FieldNames.office_area]
        let emailCell = cells[DAExcelPersonInfo.FieldNames.email]
        let twitterCell = cells[DAExcelPersonInfo.FieldNames.twitter]
        let facebookCell = cells[DAExcelPersonInfo.FieldNames.kakao]
        let kakaoCell = cells[DAExcelPersonInfo.FieldNames.kakao]
        let instagramCell = cells[DAExcelPersonInfo.FieldNames.instagram]
        let youtubeCell = cells[DAExcelPersonInfo.FieldNames.youtube]
        let webCell = cells[DAExcelPersonInfo.FieldNames.web]
        let blogCell = cells[DAExcelPersonInfo.FieldNames.blog]
        let cafeCell = cells[DAExcelPersonInfo.FieldNames.cafe]
        let cyworldCell = cells[DAExcelPersonInfo.FieldNames.cyworld]
        let assemblyCell = cells[DAExcelPersonInfo.FieldNames.assembly]
        let assemblyNoCell = cells[DAExcelPersonInfo.FieldNames.assembly_no]
        let sponsorCell = cells[DAExcelPersonInfo.FieldNames.sponsor]
        
        person.area = fieldCell?.stringValue(self.sharedStrings) ?? ""
        person.mobile = mobileCells?.stringValue(self.sharedStrings) ?? ""
        person.office_asm = office_asmCell?.stringValue(self.sharedStrings) ?? ""
        person.office_area = office_areaCell?.stringValue(self.sharedStrings) ?? ""
        person.parseNumbers();
        
        //person.sms = sms;
        person.email = emailCell?.stringValue(self.sharedStrings) ?? ""
        person.twitter = twitterCell?.stringValue(self.sharedStrings) ?? ""
        person.facebook = facebookCell?.stringValue(self.sharedStrings) ?? ""
        person.kakao = kakaoCell?.stringValue(self.sharedStrings) ?? ""
        person.instagram = instagramCell?.stringValue(self.sharedStrings) ?? ""
        person.youtube = youtubeCell?.stringValue(self.sharedStrings) ?? ""
        person.web = webCell?.stringValue(self.sharedStrings) ?? ""
        person.blog = blogCell?.stringValue(self.sharedStrings) ?? ""
        person.cafe = cafeCell?.stringValue(self.sharedStrings) ?? ""
        person.cyworld = cyworldCell?.stringValue(self.sharedStrings) ?? ""
        person.assembly = assemblyCell?.stringValue(self.sharedStrings) ?? ""
        person.assemblyNo = assemblyNoCell?.stringValue(self.sharedStrings) ?? ""
        person.sponsor = sponsorCell?.integerValue(self.sharedStrings) ?? 0
        
        debugPrint("load congress. no[\(person.assemblyNo)] name[\(person.name)]")
        
        person.isLoaded = true;
    }
    
    func loadCongresses(_ groups : [DAExcelGroupInfo] = []) -> [DAExcelPersonInfo]{
        var values : [DAExcelPersonInfo] = [];
        let sheet = self.congessSheet!
        let headers = self.loadHeaders(from: sheet)
        var i = 1;
        
        while(true){
            let row = self.headerRow.advanced(by: i)
            let cells = self.loadCells(of: row, with: headers, in: sheet)
            guard let noCell = cells[DAExcelPersonInfo.FieldNames.no],
                let nameCell = cells[DAExcelPersonInfo.FieldNames.name] else {
                break
            }
            
            let no = noCell.integerValue(self.sharedStrings) ?? 0
            let name = nameCell.stringValue(self.sharedStrings) ?? ""
            
            guard no > 0 else{
                break;
            }
            
            guard !name.isEmpty else{
                i += 1;
                continue;
            }
            
            let titleCell = cells[DAExcelPersonInfo.FieldNames.title]
            let groupIdCell = cells[DAExcelPersonInfo.FieldNames.group]
            //self.getCongressCell(column: DAExcelPersonInfo.FieldNames.group, line:i)?.stringValue() ?? "";
            
            let person = DAExcelPersonInfo();
            person.id = no;
            person.groupId = groupIdCell?.integerValue(self.sharedStrings) ?? 0;
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
            person.title = titleCell?.stringValue(self.sharedStrings) ?? ""
            
            self.loadCongress(person, cells: cells);
            
            group?.persons.append(person);
            
            values.append(person);
            
            i += 1;
        }
        
        return values;
    }
}
