//
//  DAExcelController+DAExcelEventGroupInfo.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 20..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import CoreXLSX

extension DAExcelController{    
    var eventSheet : Worksheet!{
        get{
            try! self.document.parseWorksheet(at: workSheetPaths["events"]!)
        }
    }
    
    func loadEventGroups() -> [DAExcelEventGroupInfo]{
        print("[start] load event groups");
        let sheet = self.eventSheet!
        let headers = self.loadHeaders(from: sheet)
        var i = 1;
        while(true){
            let row = self.headerRow.advanced(by: i)
            let cells = self.loadCells(of: row, with: headers, in: sheet)
            guard let noCell = cells[DAExcelEventGroupInfo.FieldNames.no] else {
                break
            }
            
            let nameCell = cells[DAExcelEventGroupInfo.FieldNames.name]
            let sheetCell = cells[DAExcelEventGroupInfo.FieldNames.sheet]
            let detailCell = cells[DAExcelEventGroupInfo.FieldNames.detail]
            
            let group = DAExcelEventGroupInfo()
            let no = noCell.integerValue(self.sharedStrings) ?? 0;
            
            guard no > 0 else{
                break;
            }
            
            group.no = no
            group.name = nameCell?.stringValue(self.sharedStrings) ?? ""
            group.sheet = sheetCell?.stringValue(self.sharedStrings) ?? ""
            group.detail = detailCell?.stringValue(self.sharedStrings) ?? ""
            
            group.events = self.loadEvents(sheetName: group.sheet);
            
            print("append event group. name[\(group.name)] sheet[\(group.sheet)] detail[\(group.detail)]");
            eventGroups.append(group);
            
            i += 1;
        }
        
        print("[end] load event groups");
        return eventGroups;
    }
    
    
}
