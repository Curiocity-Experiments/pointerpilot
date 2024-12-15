import Foundation
import SwiftUI

/// Application configuration and constants
enum AppConfig {
    /// Storage keys for UserDefaults
    enum Storage {
        /// Key for storing application state
        static let stateKey = "com.pointerpilot.state"
        
        /// Key for storing window position
        static let windowPositionKey = "com.pointerpilot.windowPosition"
    }
    
    /// Default values
    enum Defaults {
        /// Default click interval in seconds
        static let clickInterval: Double = 1.0
        
        /// Default highlight size in points
        static let highlightSize: Double = 200.0
        
        /// Default highlight opacity (0-1)
        static let highlightOpacity: Double = 0.8
        
        /// Default highlight duration in seconds
        static let highlightDuration: Double = 1.6
    }
    
    /// Application identifiers
    enum Identifiers {
        /// Bundle identifier
        static let bundleId = "com.pointerpilot"
        
        /// Application name
        static let appName = "PointerPilot"
    }
    
    /// UI configuration
    enum UI {
        /// Default padding for views
        static let defaultPadding: CGFloat = 16
        
        /// Corner radius for rounded elements
        static let cornerRadius: CGFloat = 12
        
        /// Default animation duration
        static let animationDuration: Double = 0.3
        
        /// Shadow configuration
        enum Shadow {
            static let color = Color.black.opacity(0.1)
            static let radius: CGFloat = 1
            static let x: CGFloat = 0
            static let y: CGFloat = 1
        }
        
        /// Colors
        enum Colors {
            static let accent = Color.blue
            static let background = Color(.windowBackgroundColor)
            static let secondaryBackground = Color(.controlBackgroundColor)
            static let text = Color(.labelColor)
            static let secondaryText = Color(.secondaryLabelColor)
        }
        
        /// Font sizes
        enum FontSize {
            static let small: CGFloat = 12
            static let regular: CGFloat = 14
            static let large: CGFloat = 16
            static let title: CGFloat = 20
        }
        
        /// Layout
        enum Layout {
            static let minWindowWidth: CGFloat = 300
            static let maxWindowWidth: CGFloat = 400
            static let minWindowHeight: CGFloat = 400
            static let maxWindowHeight: CGFloat = 600
            
            static let buttonHeight: CGFloat = 32
            static let iconSize: CGFloat = 20
            static let spacing: CGFloat = 8
        }
    }
} 