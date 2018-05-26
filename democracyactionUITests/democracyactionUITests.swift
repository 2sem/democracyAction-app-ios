//
//  democracyactionUITests.swift
//  democracyactionUITests
//
//  Created by 영준 이 on 2018. 5. 25..
//  Copyright © 2018년 leesam. All rights reserved.
//

import XCTest

class democracyactionUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testSwipeFavorToggle(){
        let app = XCUIApplication();
        let tablesQuery = app.tables;
        let cells = app.tables.cells;
        let predicate = NSPredicate.init(format: "count > 0");
        var expectation = self.expectation(for: predicate, evaluatedWith: cells, handler: nil);
        self.wait(for: [expectation], timeout: 30);
        
        for cell in tablesQuery.cells.allElementsBoundByIndex{
            cell.tap();
            if cell.buttons["icon favor on"].exists{
                let onButton = cell.buttons["icon favor on"];
                onButton.tap();
            }else if cell.buttons["icon favor off"].exists{
                let offButton = cell.buttons["icon favor off"];
                offButton.tap();
            }
        }
    }
}
