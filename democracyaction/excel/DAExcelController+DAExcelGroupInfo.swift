//
//  DAExcelController+DAGroupInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 24..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import XlsxReaderWriter

extension DAExcelController{
    var groupSheet : BRAWorksheet?{
        get{
            return self.document?.workbook.worksheetNamed("groups");
        }
    }
    
    func loadGroupFields(){
        self.groupCellNames = self.loadColumns(sheet: self.groupSheet!, line: DAExcelController.headerCellLine, beginCell: DAExcelController.beginCellColumn);
    }
    
    func getGroupCell(column : String?, line : Int) -> BRACell?{
        guard self.groupCellNames[column ?? ""] != nil else{
            return nil;
        }
        
        return self.groupSheet?.cell(forCellReference: "\(self.groupCellNames[column ?? ""] ?? "")\(line)");
    }
    
    @discardableResult
    func loadGroups(_ persons : [DAExcelPersonInfo]? = nil) -> [DAExcelGroupInfo]{
        var values : [DAExcelGroupInfo] = [];
        var i = 3;
        //let map : [String : DAExcelGroupInfo] = [:];
        //let category : DAExcelGroupInfo!;
        
        print("[start] loadGroups");
        
        while(true){
            let group = DAExcelGroupInfo();
            let no = self.getGroupCell(column: DAExcelGroupInfo.FieldNames.no, line: i)?.value ?? "";
            
            guard no.any else{
                print("finish loading groups.");
                break;
            }
            
            group.id = Int(no) ?? 0;
            let title = self.getGroupCell(column: DAExcelGroupInfo.FieldNames.title, line: i)?.stringValue() ?? "";
            let detail = self.getGroupCell(column: DAExcelGroupInfo.FieldNames.detail, line: i)?.stringValue() ?? "";
            let office = self.getGroupCell(column: DAExcelGroupInfo.FieldNames.office, line: i)?.stringValue() ?? "";
            //let email = self.getGroupCell(column: DAExcelGroupInfo.FieldNames.email, line: i)?.stringValue() ?? "";
            let twitter = self.getGroupCell(column: DAExcelGroupInfo.FieldNames.twitter, line: i)?.stringValue() ?? "";
            let facebook = self.getGroupCell(column: DAExcelGroupInfo.FieldNames.facebook, line: i)?.stringValue() ?? "";
            let kakao = self.getGroupCell(column: DAExcelGroupInfo.FieldNames.kakao, line: i)?.stringValue() ?? "";
            let instagram = self.getGroupCell(column: DAExcelGroupInfo.FieldNames.instagram, line: i)?.stringValue() ?? "";
            let youtube = self.getGroupCell(column: DAExcelGroupInfo.FieldNames.youtube, line: i)?.stringValue() ?? "";
            let web = self.getGroupCell(column: DAExcelGroupInfo.FieldNames.web, line: i)?.stringValue() ?? "";
            let blog = self.getGroupCell(column: DAExcelGroupInfo.FieldNames.blog, line: i)?.stringValue() ?? "";
            let cafe = self.getGroupCell(column: DAExcelGroupInfo.FieldNames.cafe, line: i)?.stringValue() ?? "";
            let cyworld = self.getGroupCell(column: DAExcelGroupInfo.FieldNames.cyworld, line: i)?.stringValue() ?? "";
            let image = self.getGroupCell(column: DAExcelGroupInfo.FieldNames.image, line: i)?.value ?? "";
            let sponsor = self.getGroupCell(column: DAExcelGroupInfo.FieldNames.sponsor, line: i)?.value ?? "";
            
            group.title = title;
            group.detail = detail;
            group.office = office;
            group.parseNumbers();
            
            //person.sms = sms;
            group.twitter = twitter;
            group.facebook = facebook;
            group.kakao = kakao;
            group.instagram = instagram;
            group.youtube = youtube;
            group.web = web;
            group.blog = blog;
            group.cafe = cafe;
            group.cyworld = cyworld;
            group.image = image;
            group.sponsor = sponsor;
            
            print("add new group. id[\(group.id)] title[\(group.title)]");
            values.append(group);
            if persons != nil{
                persons?.filter({ (person) -> Bool in
                    return person.id == group.id;
                }).forEach({ (person) in
                    group.persons.append(person);
                })
            }
            
            i += 1;
        }
        
        if self.groups.isEmpty{
            for group in values{
                self.groups[group.id] = group;
            }
        }
        
        print("[end] loadGroups");
        return values;
    }
    
    func groupsBySpell() -> [DAExcelGroupInfo]{
        var values : [DAExcelGroupInfo] = [];
        var i = 0;
        
        for person in self.persons{
            let firstSpell = person.name.getKoreanChoSeongs(false)?.first?.description ?? "";
            guard !firstSpell.isEmpty else{
                continue;
            }
            
            var group = values.filter({ (grp) -> Bool in
                return grp.title == firstSpell;
            }).first;
            
            if group == nil{
                group = DAExcelGroupInfo();
                group?.id = i;
                group?.title = firstSpell;
                values.append(group!);
                i += 1;
                //groupBySpell[firstSpell] = [];
            }
            
            group?.persons.append(person);
            //values[firstSpell] = group;
            
            print("add person into group. spell[\(firstSpell)] name[\(person.name)] count[\(group?.persons.count.description ?? "")]");
        }
        
        for _ in values{
            values.sort(by: { (left, right) -> Bool in
                left.title < right.title
            })
        }
        return values;
    }
    
    
}
