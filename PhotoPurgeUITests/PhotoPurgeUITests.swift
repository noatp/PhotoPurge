//
//  PhotoPurgeUITests.swift
//  PhotoPurgeUITests
//
//  Created by Toan Pham on 1/12/25.
//

import XCTest

final class PhotoPurgeUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // Handle location prompt if shown
        let allowButton = app.alerts.buttons["Allow Full Access"]
        
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: allowButton, handler: nil)
                waitForExpectations(timeout: 5, handler: nil)
        
        if allowButton.exists {
            allowButton.tap()
        }
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        snapshot("0Launch")
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
