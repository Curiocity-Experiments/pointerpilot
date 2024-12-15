import SwiftUI
import Carbon.HIToolbox

/// Keyboard shortcut combination
struct KeyCombo: Codable, Equatable {
    let keyCode: Int
    let modifiers: NSEvent.ModifierFlags
    
    enum CodingKeys: String, CodingKey {
        case keyCode, modifiers
    }
    
    init(keyCode: Int, modifiers: NSEvent.ModifierFlags) {
        self.keyCode = keyCode
        self.modifiers = modifiers
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        keyCode = try container.decode(Int.self, forKey: .keyCode)
        let rawValue = try container.decode(UInt.self, forKey: .modifiers)
        modifiers = NSEvent.ModifierFlags(rawValue: rawValue)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(keyCode, forKey: .keyCode)
        try container.encode(modifiers.rawValue, forKey: .modifiers)
    }
    
    var carbonModifiers: UInt32 {
        var carbonFlags: UInt32 = 0
        if modifiers.contains(.command) { carbonFlags |= UInt32(cmdKey) }
        if modifiers.contains(.option) { carbonFlags |= UInt32(optionKey) }
        if modifiers.contains(.control) { carbonFlags |= UInt32(controlKey) }
        if modifiers.contains(.shift) { carbonFlags |= UInt32(shiftKey) }
        return carbonFlags
    }
} 