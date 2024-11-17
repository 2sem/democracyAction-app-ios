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
        let sheet = try! self.document.parseWorksheet(at: workSheetPaths[sheetName]!)
        let headers = self.loadHeaders(from: sheet)
        var event = DAExcelEventInfo();
        event.no = -1;
        
        print("[start] load events");
        while(true){
            let row = self.headerRow.advanced(by: i)
            let cells = self.loadCells(of: row, with: headers, in: sheet)
            guard let noCell = cells[DAExcelEventInfo.FieldNames.no] else {
                break
            }
            
            let no = noCell.integerValue(self.sharedStrings) ?? 0;
            
            guard no > 0 else{
                break;
            }
            
            let memberIdCell = cells[DAExcelEventInfo.FieldNames.memberId]
            let memberId = memberIdCell?.integerValue(self.sharedStrings) ?? 0
            
            guard no != event.no else{
                print("load excel event. name[\(event.title)] member[\(memberId)]");
                event.persons.append(memberId);
                i += 1;
                continue;
            }
            
            let titleCell = cells[DAExcelEventInfo.FieldNames.title]
            let detailCell = cells[DAExcelEventInfo.FieldNames.detail]
            let webCell = cells[DAExcelEventInfo.FieldNames.web]
            
            event = DAExcelEventInfo()
            event.no = no
            let title = titleCell?.stringValue(self.sharedStrings) ?? "";
            //var sheet = self.getCell(sheet: sheet, column: DAExcelEventInfo.FieldNames.sheet, cells: cells, line: i)?.stringValue() ?? "";
            let detail = detailCell?.stringValue(self.sharedStrings) ?? "";
            let web = webCell?.stringValue(self.sharedStrings) ?? "";
            
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
