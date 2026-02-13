//
//  DAExcelController.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 8..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
//set XMLDictionary/XMLDictionary.h of target membership for XlsxReaderWriter to public
import CoreXLSX
import UIKit

class DAExcelController : NSObject{
    static let localUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("democracyaction").appendingPathExtension("xlsx");
    var document : XLSXFile!;
    var workbook : Workbook!;
    var workSheetPaths: [String : String] = [:]
    var sharedStrings: SharedStrings!
    let headerRow: UInt = 2
    var infoSheet : Worksheet!{
        get{
            try! self.document.parseWorksheet(at: workSheetPaths["info"]!)
        }
    }
    
    var version : String{
        get{
            let cells = self.infoSheet.cells(atRows: [2])
            let cell = cells.last
            let value = cell?.stringValue(self.sharedStrings) ?? ""
            
            return value
        }
    }
    
    var notice : String{
        get{
            let cell = self.infoSheet.cells(atRows: [3]).last
            
            return cell?.stringValue(self.sharedStrings) ?? ""
        }
    }
    
    var updateDate : Date{
        get{
            let cell = self.infoSheet.cells(atRows: [4]).last
            return cell?.dateValue ?? Date.min;
        }
    }
    
    var patch : String{
        get{
            let cell = self.infoSheet.cells(atRows: [5]).last
            
            return cell?.stringValue(self.sharedStrings) ?? "";
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
        if #available(iOS 16.0, *) {
            self.document = .init(filepath: url.path(percentEncoded: false))
        } else {
            self.document = .init(filepath: url.path)
        }
        
        self.workbook = try! document.parseWorkbooks().first
        self.workSheetPaths = try! document.parseWorksheetPathsAndNames(workbook: workbook)
            .reduce(into: [String : String](), { dict, sheetPath in
                        dict[sheetPath.name ?? ""] = sheetPath.path
                    })
        self.sharedStrings = try! document.parseSharedStrings()
        
//        self.loadFromInfos()
    }
    
    override convenience init(){
        
        if DADefaults.DataDownloaded{
            print("DAExcelController init. localUrl: \(DAExcelController.localUrl?.absoluteString ?? "nil")")
            let downloadedExcel = DAExcelController(DAExcelController.localUrl!)
//            let downloadedExcel = XLSXFile.init(filepath: DAExcelController.localUrl!.path)!
//            let downloadedWorkbook = try! downloadedExcel.parseWorkbooks().first!
//            let downloadedWorkSheetPaths = try! downloadedExcel.parseWorksheetPathsAndNames(workbook: downloadedWorkbook)
//                .reduce(into: [String : String](), { dict, sheetPath in
//                            dict[sheetPath.name ?? ""] = sheetPath.path
//                        })
//            let downloadedSharedStrings = try! downloadedExcel.parseSharedStrings()
//            
//            let version = try! downloadedExcel
//                .parseWorksheet(at: downloadedWorkSheetPaths["info"]!)
//                .cells(atRows: [2])
//                .last?.stringValue(downloadedSharedStrings!) ?? "";
            
            if downloadedExcel.version < UIApplication.shared.version{
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
    
    func loadFromInfos() {
        let sheet = self.infoSheet!
        let headers = self.loadHeaders(from: sheet)
        
        let row = self.headerRow.advanced(by: 1)
        _ = self.loadCells(of: row, with: headers, in: sheet)
    }
    
    func loadFromFlie(){
        guard self.persons.isEmpty && self.groups.isEmpty else{
            return;
        }
        
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
    var eventCells : [String : String] = [:];

    public func loadHeaders(from sheet: Worksheet) -> [String : String] {
        guard let sharedStrings else {
            return [:]
        }
        
        return sheet.cells(atRows: [self.headerRow])
            .reduce(into: [String : String]()) { dict, cell in
                let columnId = cell.reference.column.value
                let cellValue = cell.stringValue(sharedStrings) ?? ""
                dict[columnId] = cellValue
            }
    }

    public func loadCells(of row: UInt, with headers: [String :  String], in sheet: Worksheet) -> [String : Cell] {
        return sheet.cells(atRows: [row])
            .reduce(into: [String : Cell]()) { dict, cell in
                let columnId = cell.reference.column.value
                guard let column = headers[columnId] else {
                    return
                }
                
                dict[column] = cell
            }
    }
}

