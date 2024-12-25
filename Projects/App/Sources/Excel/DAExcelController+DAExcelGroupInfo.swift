//
//  DAExcelController+DAGroupInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 24..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import CoreXLSX

extension DAExcelController{
    var groupSheet : Worksheet!{
        get{
            try! self.document.parseWorksheet(at: workSheetPaths["groups"]!)
        }
    }
    
    @discardableResult
    func loadGroups(_ persons : [DAExcelPersonInfo]? = nil) -> [DAExcelGroupInfo]{
        var values : [DAExcelGroupInfo] = [];
        let sheet = self.groupSheet!
        let headers = self.loadHeaders(from: sheet)
        var i = 1;
        //let map : [String : DAExcelGroupInfo] = [:];
        //let category : DAExcelGroupInfo!;
        
        print("[start] loadGroups");
        
        while(true){
            let row = self.headerRow.advanced(by: i)
            let cells = self.loadCells(of: row, with: headers, in: sheet)
            guard let noCell = cells[DAExcelGroupInfo.FieldNames.no] else {
                break
            }
            let group = DAExcelGroupInfo();
            let no = noCell.integerValue(self.sharedStrings) ?? 0;
            
            guard no > 0 else{
                print("finish loading groups.");
                break;
            }
            
            group.id = no;
            let titleCell = cells[DAExcelGroupInfo.FieldNames.title]
            let detailCell = cells[DAExcelGroupInfo.FieldNames.detail]
            let officeCell = cells[DAExcelGroupInfo.FieldNames.office]
            let twitterCell = cells[DAExcelGroupInfo.FieldNames.twitter]
            let facebookCell = cells[DAExcelGroupInfo.FieldNames.facebook]
            let kakaoCell = cells[DAExcelGroupInfo.FieldNames.kakao]
            let instagramCell = cells[DAExcelGroupInfo.FieldNames.instagram]
            let youtubeCell = cells[DAExcelGroupInfo.FieldNames.youtube]
            let webCell = cells[DAExcelGroupInfo.FieldNames.web]
            let blogCell = cells[DAExcelGroupInfo.FieldNames.blog]
            let cafeCell = cells[DAExcelGroupInfo.FieldNames.cafe]
            let cyworldCell = cells[DAExcelGroupInfo.FieldNames.cyworld]
            let imageCell = cells[DAExcelGroupInfo.FieldNames.image]
            let sponsorCell = cells[DAExcelGroupInfo.FieldNames.sponsor]
            
            group.title = titleCell?.stringValue(self.sharedStrings) ?? ""
            group.detail = detailCell?.stringValue(self.sharedStrings) ?? ""
            group.office = officeCell?.stringValue(self.sharedStrings) ?? ""
            group.twitter = twitterCell?.stringValue(self.sharedStrings) ?? ""
            group.facebook = facebookCell?.stringValue(self.sharedStrings) ?? ""
            group.kakao = kakaoCell?.stringValue(self.sharedStrings) ?? ""
            group.instagram = instagramCell?.stringValue(self.sharedStrings) ?? ""
            group.youtube = youtubeCell?.stringValue(self.sharedStrings) ?? ""
            group.web = webCell?.stringValue(self.sharedStrings) ?? ""
            group.blog = blogCell?.stringValue(self.sharedStrings) ?? ""
            group.cafe = cafeCell?.stringValue(self.sharedStrings) ?? ""
            group.cyworld = cyworldCell?.stringValue(self.sharedStrings) ?? ""
            group.image = imageCell?.stringValue(self.sharedStrings) ?? ""
            group.parseNumbers();
            
            //person.sms = sms;
            group.twitter = twitterCell?.stringValue(self.sharedStrings) ?? ""
            group.facebook = facebookCell?.stringValue(self.sharedStrings) ?? ""
            group.kakao = kakaoCell?.stringValue(self.sharedStrings) ?? ""
            group.instagram = instagramCell?.stringValue(self.sharedStrings) ?? ""
            group.youtube = youtubeCell?.stringValue(self.sharedStrings) ?? ""
            group.web = webCell?.stringValue(self.sharedStrings) ?? ""
            group.blog = blogCell?.stringValue(self.sharedStrings) ?? ""
            group.cafe = cafeCell?.stringValue(self.sharedStrings) ?? ""
            group.cyworld = cyworldCell?.stringValue(self.sharedStrings) ?? ""
            group.image = imageCell?.stringValue(self.sharedStrings) ?? ""
            
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
