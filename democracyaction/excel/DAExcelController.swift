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
    static let localUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("democracyaction").appendingPathExtension("xlsx");
    var document : BRAOfficeDocumentPackage?;
    var infoSheet : BRAWorksheet?{
        get{
            return self.document?.workbook.worksheetNamed("info");
        }
    }
    
    var version : String{
        get{
            let cell = self.infoSheet?.cell(forCellReference: "C2");

            return cell?.stringValue() ?? "";
        }
    }
    
    var notice : String{
        get{
            let cell = self.infoSheet?.cell(forCellReference: "C3");
            
            return cell?.stringValue() ?? "";
        }
    }
    
    var noticeDate : Date{
        get{
            let cell = self.infoSheet?.cell(forCellReference: "C4");
            return (cell?.stringValue() ?? "").toDate("MM/dd/yy")!;
        }
    }
    
    var patch : String{
        get{
            let cell = self.infoSheet?.cell(forCellReference: "C5");
            
            return cell?.stringValue() ?? "";
        }
    }
    
    var needToUpdate : Bool{
        get{
            return DADefaults.DataVersion < self.version;
        }
    }
    
    internal static var shared = DAExcelController();
    
    var groups : [Int : DAExcelGroupInfo] = [:];
    var persons : [DAExcelPersonInfo] = [];
    var eventGroups : [DAExcelEventGroupInfo] = [];
    
    init(_ url : URL) {
        super.init();
        print("excel : \(url)");
        self.document = BRAOfficeDocumentPackage.open(url.path);
    }
    
    override convenience init(){
        if DADefaults.DataDownloaded{
            let version = BRAOfficeDocumentPackage.open(DAExcelController.localUrl!.path)?
                .workbook.worksheetNamed("info")
                .cell(forCellReference: "C2").stringValue() ?? "";
            if version < UIApplication.shared.version{
                self.init(Bundle.main.url(forResource: "direct_democracy", withExtension: "xlsx")!);
            }else{
                self.init(DAExcelController.localUrl!);
            }
        }else{
            self.init(Bundle.main.url(forResource: "direct_democracy", withExtension: "xlsx")!);
        }
        /*guard let excel_path =  else{
            fatalError("Can not find Excel File");
        }
        print("excel : \(excel_path)");
        self.document = BRAOfficeDocumentPackage.open(excel_path.path);*/
        //        var cell = sheet?.cell(forCellReference: "A2");
        //        print("\(cell?.columnName()) - \(cell?.columnIndex()) => \(cell?.stringValue())");
    }
    
    func loadFromFlie(){
        guard self.persons.isEmpty && self.groups.isEmpty else{
            return;
        }
        
        self.loadPersonFields();
        self.loadGroupFields();
        self.loadEventFields();
        
        self.loadGroups();
        self.eventGroups = self.loadEventGroups();
        /*var groups = self.loadGroups();
        for group in groups{
            self.groups[group.id] = group;
        }*/
        self.persons = self.loadCongresses(Array(self.groups.values));
    }
    
    static let headerCellLine = 2;
    static let beginCellColumn = "B";
    
    static let congressStartRow = 3;

    static let beginCell = Character("A");
    internal(set) var personCellNames : [String : String] = [:];
    internal(set) var groupCellNames : [String : String] = [:];
    internal(set) var eventCells : [String : String] = [:];

    func getCell(sheet: BRAWorksheet?, column : String?, cells : [String : String], line : Int) -> BRACell?{
        guard cells[column ?? ""] != nil else{
            return nil;
        }
        
        return sheet?.cell(forCellReference: "\(cells[column ?? ""] ?? "")\(line)");
    }
    
    func loadColumns(sheet : BRAWorksheet, line : Int = DAExcelController.headerCellLine, beginCell : String = DAExcelController.beginCellColumn) -> [String : String]{
        var values : [String : String] = [:];
        var i = 0;
        
        var ch = Character(beginCell).increase(UInt32(i));

        //.unicodeScalars.first!.value;
        
        while(true){
            ch = Character(beginCell).increase(UInt32(i));
            let cell = sheet.cell(forCellReference: "\(ch)\(line)");
            guard !(cell?.stringValue() ?? "").isEmpty else{
                break;
            }
            
            values[cell?.stringValue() ?? ""] = "\(ch)";
            i += 1;
        }
        
        return values;
    }
}

