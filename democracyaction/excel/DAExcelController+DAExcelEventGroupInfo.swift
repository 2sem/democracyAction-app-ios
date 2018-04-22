//
//  DAExcelController+DAExcelEventGroupInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 20..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import XlsxReaderWriter

extension DAExcelController{    
    var eventSheet : BRAWorksheet?{
        get{
            return self.document?.workbook.worksheetNamed("events");
        }
    }
    
    func getEventCell(column : String?, line : Int) -> BRACell?{
        return self.getCell(sheet: self.eventSheet, column: column, cells: self.eventCells, line: line);
    }
    
    func loadEventFields(){
        self.eventCells = self.loadColumns(sheet: self.eventSheet!, line: DAExcelController.headerCellLine, beginCell: DAExcelController.beginCellColumn);
    }
    
    func loadEventGroups() -> [DAExcelEventGroupInfo]{
        var values : [DAExcelEventGroupInfo] = [];
        var i = 3;
        
        print("[start] load event groups");
        while(true){
            let event = DAExcelEventGroupInfo();
            let no = self.getEventCell(column: DAExcelEventGroupInfo.FieldNames.no, line: i)?.value ?? "";
            
            guard no.any else{
                break;
            }
            
            event.no = Int(no) ?? 0;
            let name = self.getEventCell(column: DAExcelEventGroupInfo.FieldNames.name, line: i)?.stringValue() ?? "";
            let sheet = self.getEventCell(column: DAExcelEventGroupInfo.FieldNames.sheet, line: i)?.stringValue() ?? "";
            let detail = self.getGroupCell(column: DAExcelEventGroupInfo.FieldNames.detail, line: i)?.stringValue() ?? "";
            
            event.name = name;
            event.sheet = sheet;
            event.detail = detail;
            
            event.events = self.loadEvents(sheetName: event.sheet);
            
            print("append event group. name[\(name)] sheet[\(sheet)] detail[\(detail)]");
            values.append(event);
            //load event
            
            i += 1;
        }
        
        print("[end] load event groups");
        return values;
    }
    
    
}
