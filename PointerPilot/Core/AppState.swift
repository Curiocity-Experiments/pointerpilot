import SwiftUI
import Carbon.HIToolbox

/// Main application state
struct AppState: Codable {
    var isHighlightEnabled: Bool = false
    var isClickingEnabled: Bool = false
    var targetApp: AppIdentifier? = nil
    
    // Mouse Ping settings
    var highlightSize: Double = AppConfig.Defaults.highlightSize
    var highlightDuration: Double = AppConfig.Defaults.highlightDuration
    var highlightOpacity: Double = AppConfig.Defaults.highlightOpacity
    
    // Click settings
    var clickInterval: Double = AppConfig.Defaults.clickInterval
}

/// Keyboard shortcut settings
struct ShortcutSettings: Codable {
    var toggle: KeyCombo
    var highlight: KeyCombo
    var click: KeyCombo
    var emergencyStop: KeyCombo
    
    static var `default`: ShortcutSettings {
        ShortcutSettings(
            toggle: KeyCombo(keyCode: kVK_ANSI_P, modifiers: [.control, .option]),
            highlight: KeyCombo(keyCode: kVK_ANSI_H, modifiers: [.control, .shift]),
            click: KeyCombo(keyCode: kVK_ANSI_C, modifiers: [.control, .shift]),
            emergencyStop: KeyCombo(keyCode: kVK_Escape, modifiers: [.control])
        )
    }
}

enum PermissionStatus: String {
    case unknown
    case granted
    case notGranted
}

/// Identifier for target applications
struct AppIdentifier: Codable, Equatable, Hashable {
    let bundleIdentifier: String
    let name: String
    let processId: pid_t
    
    init(bundleIdentifier: String, name: String, processId: pid_t = 0) {
        self.bundleIdentifier = bundleIdentifier
        self.name = name
        self.processId = processId
    }
    
    init?(from app: NSRunningApplication) {
        guard let bundleId = app.bundleIdentifier,
              let name = app.localizedName else { return nil }
        self.bundleIdentifier = bundleId
        self.name = name
        self.processId = app.processIdentifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(bundleIdentifier)
        hasher.combine(processId)
    }
    
    static func == (lhs: AppIdentifier, rhs: AppIdentifier) -> Bool {
        lhs.bundleIdentifier == rhs.bundleIdentifier && lhs.processId == rhs.processId
    }
} 