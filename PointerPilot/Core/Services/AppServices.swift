import Foundation
import AppKit
import Carbon.HIToolbox
import os.log

class AppServices {
    private let logger = Logger(subsystem: "com.pointerpilot", category: "AppServices")
    private var monitors: [String: Any] = [:]
    private var handlers: [String: () -> Void] = [:]
    
    init() {}
    
    // For testing
    init(testing: Bool) {}
    
    // MARK: - Mouse Control
    
    func getCurrentMouseLocation() -> CGPoint {
        NSEvent.mouseLocation
    }
    
    func performClick(at location: CGPoint) throws {
        guard let clickDown = CGEvent(mouseEventSource: nil,
                                    mouseType: .leftMouseDown,
                                    mouseCursorPosition: location,
                                    mouseButton: .left) else {
            throw ServiceError.eventCreationFailed
        }
        
        guard let clickUp = CGEvent(mouseEventSource: nil,
                                  mouseType: .leftMouseUp,
                                  mouseCursorPosition: location,
                                  mouseButton: .left) else {
            throw ServiceError.eventCreationFailed
        }
        
        clickDown.flags = .maskNonCoalesced
        clickUp.flags = .maskNonCoalesced
        
        clickDown.post(tap: .cghidEventTap)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            clickUp.post(tap: .cghidEventTap)
        }
    }
    
    // MARK: - Application Management
    
    func getRunningApplications() -> [AppIdentifier] {
        NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .compactMap(AppIdentifier.init)
            .sorted { $0.name < $1.name }
    }
    
    // MARK: - Storage
    
    func save<T: Encodable>(_ value: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(value)
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func load<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try JSONDecoder().decode(type, from: data)
    }
    
    // MARK: - Accessibility
    
    func getElementAtLocation(_ location: CGPoint) -> AXUIElement? {
        let systemWide = AXUIElementCreateSystemWide()
        var element: AXUIElement?
        
        AXUIElementCopyElementAtPosition(systemWide, Float(location.x), Float(location.y), &element)
        return element
    }
    
    func getElementRole(_ element: AXUIElement) -> String {
        var value: AnyObject?
        AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &value)
        return (value as? String) ?? ""
    }
    
    func getElementTitle(_ element: AXUIElement) -> String {
        var value: AnyObject?
        AXUIElementCopyAttributeValue(element, kAXTitleAttribute as CFString, &value)
        return (value as? String) ?? ""
    }
    
    // MARK: - Shortcuts
    
    func registerShortcut(id: String, keyCombo: KeyCombo, handler: @escaping () -> Void) {
        // Remove existing monitors
        removeMonitors(for: id)
        
        // Store handler
        handlers[id] = handler
        
        // Create local monitor first to intercept and prevent system beep
        let localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }
            
            if self.matchesKeyCombo(event, keyCombo) {
                DispatchQueue.main.async {
                    self.handlers[id]?()
                }
                return nil // Consume the event to prevent system beep
            }
            return event
        }
        
        if let localMonitor = localMonitor {
            monitors[id + "_local"] = localMonitor
        }
        
        // Create global monitor for when app is not active
        let globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return }
            
            if self.matchesKeyCombo(event, keyCombo) {
                DispatchQueue.main.async {
                    self.handlers[id]?()
                }
            }
        }
        
        if let globalMonitor = globalMonitor {
            monitors[id] = globalMonitor
        }
    }
    
    private func matchesKeyCombo(_ event: NSEvent, _ keyCombo: KeyCombo) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        return event.keyCode == UInt16(keyCombo.keyCode) && flags == keyCombo.modifiers
    }
    
    private func removeMonitors(for id: String) {
        if let monitor = monitors[id] {
            NSEvent.removeMonitor(monitor)
            monitors.removeValue(forKey: id)
        }
        
        if let localMonitor = monitors[id + "_local"] {
            NSEvent.removeMonitor(localMonitor)
            monitors.removeValue(forKey: id + "_local")
        }
        
        handlers.removeValue(forKey: id)
    }
    
    deinit {
        for monitor in monitors.values {
            NSEvent.removeMonitor(monitor)
        }
        monitors.removeAll()
        handlers.removeAll()
    }
}

enum ServiceError: Error {
    case eventCreationFailed
    case storageError(String)
} 