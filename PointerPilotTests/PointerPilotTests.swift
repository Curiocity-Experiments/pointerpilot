//
//  PointerPilotTests.swift
//  PointerPilotTests
//
//  Created by Randall Noval on 12/1/24.
//

import XCTest
@testable import PointerPilot

final class PointerPilotTests: XCTestCase {
    var viewModel: AppViewModel!
    var mockServices: MockAppServices!
    
    override func setUpWithError() throws {
        mockServices = MockAppServices(testing: true)
        viewModel = AppViewModel(services: mockServices)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockServices = nil
    }
    
    // MARK: - Click Tests
    
    func testStartClicking() {
        // Start clicking
        viewModel.startClicking()
        
        // Verify state
        XCTAssertTrue(viewModel.state.isClickingEnabled)
        
        // Stop clicking
        viewModel.stopClicking()
        
        // Verify state
        XCTAssertFalse(viewModel.state.isClickingEnabled)
    }
    
    func testClickInterval() {
        // Set interval
        viewModel.updateClickInterval(2.0)
        
        // Verify interval
        XCTAssertEqual(viewModel.state.clickInterval, 2.0)
    }
    
    // MARK: - Highlight Tests
    
    func testHighlightSize() {
        // Set size
        viewModel.updateHighlightSize(150)
        
        // Verify size
        XCTAssertEqual(viewModel.state.highlightSize, 150)
    }
    
    func testHighlightOpacity() {
        // Set opacity
        viewModel.updateHighlightOpacity(0.8)
        
        // Verify opacity
        XCTAssertEqual(viewModel.state.highlightOpacity, 0.8)
    }
}

// MARK: - Mock Services

class MockAppServices: AppServices {
    var mouseLocation: CGPoint = .zero
    var clickLocations: [CGPoint] = []
    var registeredShortcuts: [(id: String, keyCombo: KeyCombo, handler: () -> Void)] = []
    var savedData: [String: Data] = [:]
    
    override init(testing: Bool = true) {
        super.init(testing: true)
    }
    
    override func getCurrentMouseLocation() -> CGPoint {
        mouseLocation
    }
    
    override func performClick(at location: CGPoint) throws {
        clickLocations.append(location)
    }
    
    override func registerShortcut(id: String, keyCombo: KeyCombo, handler: @escaping () -> Void) {
        registeredShortcuts.append((id: id, keyCombo: keyCombo, handler: handler))
    }
    
    override func save<T: Encodable>(_ value: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(value)
        savedData[key] = data
    }
    
    override func load<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = savedData[key] else { return nil }
        return try JSONDecoder().decode(type, from: data)
    }
    
    override func getElementAtLocation(_ location: CGPoint) -> AXUIElement? {
        nil
    }
    
    override func getElementRole(_ element: AXUIElement) -> String {
        ""
    }
    
    override func getElementTitle(_ element: AXUIElement) -> String {
        ""
    }
}
