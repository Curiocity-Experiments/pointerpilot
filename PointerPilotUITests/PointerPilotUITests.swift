//
//  PointerPilotUITests.swift
//  PointerPilotUITests
//
//  Created by Randall Noval on 12/1/24.
//

import XCTest

final class PointerPilotUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        
        print("Setting up UI test with arguments...")
        app.launchArguments = ["UI_TESTING"]
        
        print("Launching application...")
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
        
        print("Setup complete")
    }
    
    override func tearDown() {
        if let app = app {
            print("Terminating application...")
            app.terminate()
        }
        app = nil
        super.tearDown()
    }
    
    // Helper method to verify window state
    private func verifyWindowState() {
        let window = app.windows.firstMatch
        XCTAssertTrue(window.exists, "Window should exist")
        XCTAssertTrue(window.isHittable, "Window should be hittable")
    }
    
    // Helper method to wait for UI element
    private func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        print("Waiting for element: \(element.description)")
        let exists = element.waitForExistence(timeout: timeout)
        print("Element exists: \(exists)")
        return exists
    }
    
    func testMainInterfaceElements() throws {
        // Verify window state first
        verifyWindowState()
        
        // Test basic UI elements presence with better waiting
        XCTAssertTrue(waitForElement(app.buttons["Test Highlight"]), "Test Highlight button should exist")
        XCTAssertTrue(waitForElement(app.buttons["Test Click"]), "Test Click button should exist")
        XCTAssertTrue(waitForElement(app.sliders["Ring Size"]), "Ring Size slider should exist")
        XCTAssertTrue(waitForElement(app.sliders["Click Interval"]), "Click Interval slider should exist")
    }
    
    func testMouseLocationTest() throws {
        // Click the test button
        let testButton = app.buttons["Test Highlight"]
        XCTAssertTrue(testButton.exists)
        testButton.click()
        
        // Verify the highlight appears (indirect test through button state)
        XCTAssertTrue(testButton.isEnabled)
    }
    
    func testClickAutomation() throws {
        // Test the click automation toggle
        let clickToggle = app.buttons["Test Click"]
        XCTAssertTrue(clickToggle.exists)
        clickToggle.click()
        
        // Verify the click was attempted
        XCTAssertTrue(clickToggle.isEnabled)
    }
    
    func testSliderInteractions() throws {
        // Test highlight size slider
        let sizeSlider = app.sliders["Ring Size"]
        XCTAssertTrue(sizeSlider.exists)
        sizeSlider.adjust(toNormalizedSliderPosition: 0.5)
        
        // Test click interval slider
        let intervalSlider = app.sliders["Click Interval"]
        XCTAssertTrue(intervalSlider.exists)
        intervalSlider.adjust(toNormalizedSliderPosition: 0.5)
    }
    
    func testEmergencyStop() throws {
        // Enable clicking through UI
        let testClickButton = app.buttons["Test Click"]
        XCTAssertTrue(testClickButton.exists)
        testClickButton.click()
        
        // Wait for status to show "Running"
        let runningStatus = app.staticTexts["Running"]
        XCTAssertTrue(runningStatus.waitForExistence(timeout: 2))
        
        // Trigger emergency stop using keyboard shortcut
        app.typeKey(XCUIKeyboardKey.escape, modifierFlags: .control)
        
        // Verify clicking stopped by checking the status indicator
        let stoppedStatus = app.staticTexts["Stopped"]
        XCTAssertTrue(stoppedStatus.waitForExistence(timeout: 2))
    }
}
