//
//  PointerPilotUITestsLaunchTests.swift
//  PointerPilotUITests
//
//  Created by Randall Noval on 12/1/24.
//

import XCTest

final class PointerPilotUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()

        print("Waiting for window to appear...")
        let windowsQuery = app.windows
        let startTime = Date()
        let timeout: TimeInterval = 10
        
        while windowsQuery.count == 0 && Date().timeIntervalSince(startTime) < timeout {
            print("Current window count: \(windowsQuery.count)")
            print("Available windows: \(windowsQuery.debugDescription)")
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        }
        
        // Verify window exists
        XCTAssertTrue(windowsQuery.count > 0, "Window should exist after launch")
        
        let window = windowsQuery.firstMatch
        print("Found window: \(window.debugDescription)")
        XCTAssertTrue(window.exists, "Window should be accessible")

        // Take a screenshot
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
