//
//  DAExcelController+DAExcelEventInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 20..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation

extension DAExcelController{
    func loadEvents(sheetName : String) -> [DAExcelEventInfo]{
        var values : [DAExcelEventInfo] = [];
        var i = 3;
        let sheet = self.document?.workbook.worksheetNamed(sheetName);
        let cells = self.loadColumns(sheet: sheet!);
        var event = DAExcelEventInfo();
        event.no = -1;
        
        print("[start] load events");
        while(true){
            let noString = self.getCell(sheet: sheet, column: DAExcelEventInfo.FieldNames.no, cells: cells, line: i)?.value ?? "";
            
            guard noString.any else{
                break;
            }
            
            let no = Int(noString ) ?? 0;
            let memberidString = self.getCell(sheet: sheet, column: DAExcelEventInfo.FieldNames.memberId, cells: cells, line: i)?.stringValue() ?? "";
            let memberId = Int(memberidString) ?? 0;
            
            guard no != event.no else{
                print("load excel event. name[\(event.title)] member[\(memberId)]");
                event.persons.append(memberId);
                i += 1;
                continue;
            }
            
            event = DAExcelEventInfo();
            event.no = no;
            let title = self.getCell(sheet: sheet, column: DAExcelEventInfo.FieldNames.title, cells: cells, line: i)?.stringValue() ?? "";
            //var sheet = self.getCell(sheet: sheet, column: DAExcelEventInfo.FieldNames.sheet, cells: cells, line: i)?.stringValue() ?? "";
            let detail = self.getCell(sheet: sheet, column: DAExcelEventInfo.FieldNames.detail, cells: cells, line: i)?.stringValue() ?? "";
            let web = self.getCell(sheet: sheet, column: DAExcelEventInfo.FieldNames.web, cells: cells, line: i)?.stringValue() ?? "";
            
            event.title = title;
            //event.sheet = sheet;
            event.detail = detail;
            event.web = web;
            print("load event. no[\(event.no)] title[\(event.title)]");
            values.append(event);
            event.persons.append(memberId);

            //values.append(event);
            //load event
            
            i += 1;
        }
        
        print("[end] load events");
        return values;
    }
}
