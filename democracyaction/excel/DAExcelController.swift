//
//  DAExcelController.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 8..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
//set XMLDictionary/XMLDictionary.h of target membership for XlsxReaderWriter to public
import XlsxReaderWriter

class DAExcelController : NSObject{
    var document : BRAOfficeDocumentPackage?;
    var infoSheet : BRAWorksheet?{
        get{
            return self.document?.workbook.worksheetNamed("info");
        }
    }
    
    var congessSheet : BRAWorksheet?{
        get{
            return self.document?.workbook.worksheetNamed("congressman");
        }
    }
    
    var groupSheet : BRAWorksheet?{
        get{
            return self.document?.workbook.worksheetNamed("groups");
        }
    }
    
    var version : String{
        get{
            var cell = self.infoSheet?.cell(forCellReference: "C2");

            return cell?.stringValue() ?? "";
        }
    }
    
    var notice : String{
        get{
            var cell = self.infoSheet?.cell(forCellReference: "C3");
            
            return cell?.stringValue() ?? "";
        }
    }
    
    var noticeDate : Date{
        get{
            var cell = self.infoSheet?.cell(forCellReference: "C4");
            return (cell?.stringValue() ?? "").toDate("MM/dd/yy")!;
        }
    }
    
    var patch : String{
        get{
            var cell = self.infoSheet?.cell(forCellReference: "C5");
            
            return cell?.stringValue() ?? "";
        }
    }
    
    var needToUpdate : Bool{
        get{
            return DADefaults.DataVersion < self.version;
        }
    }
    
    static let Default = DAExcelController();
    
    var groups : [Int : DAExcelGroupInfo] = [:];
    var persons : [DAExcelPersonInfo] = [];
    
    override init(){
        guard let excel_path = Bundle.main.url(forResource: "direct_democracy", withExtension: "xlsx") else{
            fatalError("Can not find Excel File");
        }
        print("excel : \(excel_path)");
        self.document = BRAOfficeDocumentPackage.open(excel_path.path);
        //        var cell = sheet?.cell(forCellReference: "A2");
        //        print("\(cell?.columnName()) - \(cell?.columnIndex()) => \(cell?.stringValue())");
    }
    
    func loadFromFlie(){
        guard self.persons.isEmpty && self.groups.isEmpty else{
            return;
        }
        
        self.loadPersonFields();
        self.loadGroups();
        /*var groups = self.loadGroups();
        for group in groups{
            self.groups[group.id] = group;
        }*/
        self.persons = self.loadCongresses(Array(self.groups.values));
    }
    
    static let headerCellLine = 2;
    static let beginCellColumn = "B";
    
    static let beginCell = Character("A");
    private(set) var headerCells : [String : String] = [:];
    
    func loadPersonFields(){
        var line = DAExcelController.headerCellLine;
        var i = 0;
        
        var ch = Character(DAExcelController.beginCellColumn);
        //.unicodeScalars.first!.value;
        
        while(true){
            i += 1;
            ch = DAExcelController.beginCell.increase(UInt32(i));
            var cell = self.congessSheet?.cell(forCellReference: "\(ch)\(line)");
            guard !(cell?.stringValue() ?? "").isEmpty else{
                break;
            }
            
            self.headerCells[cell?.stringValue() ?? ""] = "\(ch)";
        }
    }
    
    func loadGroups(_ persons : [DAExcelPersonInfo]? = nil) -> [DAExcelGroupInfo]{
        var values : [DAExcelGroupInfo] = [];
        var i = 3;
        var map : [String : DAExcelGroupInfo] = [:];
        var category : DAExcelGroupInfo!;
        
        /*if categories?.isEmpty == false{
            categories?.forEach({ (c) in
                c.toasts.removeAll();
                map[c.name] = c;
            })
        }*/
        
        while(true){
            var group = DAExcelGroupInfo();
            var cell = self.groupSheet?.cell(forCellReference: "B\(i)");
            
            guard !(cell?.value ?? "").isEmpty else{
                break;
            }
            
            group.id = Int(cell?.value ?? "") ?? 0;
            cell = self.groupSheet?.cell(forCellReference: "C\(i)");
            if cell?.stringValue() != nil{
                group.title = cell?.stringValue() ?? "";
            }
            
            cell = self.groupSheet?.cell(forCellReference: "D\(i)");
            if cell?.stringValue() != nil{
                group.detail = cell?.stringValue() ?? "";
            }
            
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
        
        return values;
    }
    
    static let congressStartRow = 3;
    
    func getCongressCell(column : String?, line : Int) -> BRACell?{
        guard self.headerCells[column ?? ""] != nil else{
            return nil;
        }
        
        return self.congessSheet?.cell(forCellReference: "\(self.headerCells[column ?? ""] ?? "")\(line)");
    }
    func loadCongress(_ person : DAExcelPersonInfo, row : Int? = nil){
        var i = row ?? (person.id - 1 + DAExcelController.congressStartRow);
        
        guard !person.isLoaded else{
            return;
        }
        
        var field = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.field, line: i)?.stringValue() ?? "";
        var mobile = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.mobile, line: i)?.stringValue() ?? "";
        var office_asm = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.office_asm, line: i)?.stringValue() ?? "";
        var office_area = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.office_area, line: i)?.stringValue() ?? "";
        var email = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.email, line: i)?.stringValue() ?? "";
        var twitter = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.twitter, line: i)?.stringValue() ?? "";
        var facebook = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.facebook, line: i)?.stringValue() ?? "";
        var kakao = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.kakao, line: i)?.stringValue() ?? "";
        var instagram = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.instagram, line: i)?.stringValue() ?? "";
        var youtube = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.youtube, line: i)?.stringValue() ?? "";
        var web = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.web, line: i)?.stringValue() ?? "";
        var blog = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.blog, line: i)?.stringValue() ?? "";
        var cafe = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.cafe, line: i)?.stringValue() ?? "";
        var cyworld = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.cyworld, line: i)?.stringValue() ?? "";
        var assembly = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.assembly, line: i)?.value ?? "";
        
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
        
        person.isLoaded = true;
    }
    
    func loadCongresses(_ groups : [DAExcelGroupInfo] = []) -> [DAExcelPersonInfo]{
        var values : [DAExcelPersonInfo] = [];
        var i = DAExcelController.congressStartRow;
        
        while(true){
            var no = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.no, line: i)?.stringValue() ?? "";
            var name = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.name, line: i)?.stringValue() ?? "";
            var title = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.title, line: i)?.stringValue() ?? "";
            var groupId = self.getCongressCell(column: DAExcelPersonInfo.FieldNames.group, line:i)?.stringValue() ?? "";
            
            guard !no.isEmpty else{
                break;
            }
            
            guard !name.isEmpty else{
                i += 1;
                continue;
            }
            
            var person = DAExcelPersonInfo();
            person.id = Int(no) ?? 0;
            person.groupId = Int(groupId) ?? 0;
            var group = groups.filter({ (group) -> Bool in
                return group.id == person.groupId
            }).first;
            
            guard groups.isEmpty || group != nil else{
                i += 1;
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
    
    func groupsBySpell() -> [DAExcelGroupInfo]{
        var values : [DAExcelGroupInfo] = [];
        var i = 0;

        for person in DAExcelController.Default.persons{
            var firstSpell = person.name.getKoreanChoSeongs(false)?.characters.first?.description ?? "";
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
            
            print("add person into group. spell[\(firstSpell)] name[\(person.name)] count[\(group?.persons.count)]");
        }
        
        for group in values{
            values.sort(by: { (left, right) -> Bool in
                left.title < right.title
            })
        }
        return values;
    }
    
    /*func loadFollowToasts(withCategory category : LCToastCategory) -> [LCToast]{
        //        var value : [LCToast] = category.toasts;
        var i = 2;
        var space = 1;
        
        while(true){
            var first = self.followSheet?.cell(forCellReference: "A\(i)")?.stringValue() ?? "";
            var second = self.followSheet?.cell(forCellReference: "B\(i)")?.stringValue() ?? "";
            var contents = self.followSheet?.cell(forCellReference: "C\(i)")?.stringValue() ?? "";
            //            var category_name = self.congessSheet?.cell(forCellReference: "D\(i)")?.stringValue() ?? "";
            
            guard !first.isEmpty else{
                if space >= 0{
                    space -= 1;
                    i += 1;
                    continue;
                }
                break;
            }
            
            var title = "(선)\(first) (후)\(second)";
            
            var toast = LCToast();
            toast.title = title;
            //            toast.contents = contents.isEmpty ? contents : "의미 : \(contents)";
            toast.contents = contents
            
            category.toasts.append(toast);
            
            i += 1;
        }
        
        return category.toasts;
    }
    
    func findToast(_ title : String, withCategory categoryName : String = "") -> LCToast?{
        var value : LCToast?;
        var categories = categoryName.isEmpty ? self.categories : self.categories.filter({ (c) -> Bool in
            return c.name == categoryName;
        });
        
        for cg in categories{
            for toast in cg.toasts{
                if toast.title == title{
                    value = toast;
                    break;
                }
            }
        }
        
        return value;
    }
    
    func randomToast(_ category : String = "") -> LCToast{
        var value : LCToast;
        var toasts : [LCToast] = [];
        var categories = category.isEmpty ? self.categories : self.categories.filter { (cg) -> Bool in
            return cg.name == category;
        }
        for cg in categories{
            toasts.append(contentsOf: cg.toasts);
        }
        
        var cnt = UInt32(toasts.count);
        value = toasts[Int(arc4random_uniform(cnt - 1))];
        
        return value;
    }*/
}

