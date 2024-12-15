import Foundation
import AppKit
import os.log

/// Represents all possible errors that can occur in the application
enum PointerPilotError: LocalizedError {
    // MARK: - Error Cases
    
    // System Errors
    case accessibilityPermissionDenied
    case screenNotAvailable
    case windowCreationFailed
    
    // Animation Errors
    case animationInProgress
    case invalidAnimationParameters(String)
    case cleanupFailed(String)
    
    // Click Automation Errors
    case clickFailed(String)
    case invalidClickLocation
    case clickingNotEnabled
    
    // State Management Errors
    case invalidState(String)
    case stateTransitionFailed(String)
    
    // Resource Management Errors
    case resourceAllocationFailed(String)
    case resourceCleanupFailed(String)
    
    // MARK: - LocalizedError Implementation
    
    public var errorDescription: String? {
        switch self {
        // System Errors
        case .accessibilityPermissionDenied:
            return "Accessibility permission is required but not granted"
        case .screenNotAvailable:
            return "Unable to access the main screen"
        case .windowCreationFailed:
            return "Failed to create window for cursor highlighting"
            
        // Animation Errors
        case .animationInProgress:
            return "Cannot start new animation while another is in progress"
        case .invalidAnimationParameters(let details):
            return "Invalid animation parameters: \(details)"
        case .cleanupFailed(let details):
            return "Animation cleanup failed: \(details)"
            
        // Click Automation Errors
        case .clickFailed(let details):
            return "Failed to perform click: \(details)"
        case .invalidClickLocation:
            return "Invalid click location specified"
        case .clickingNotEnabled:
            return "Click automation is not enabled"
            
        // State Management Errors
        case .invalidState(let details):
            return "Invalid application state: \(details)"
        case .stateTransitionFailed(let details):
            return "State transition failed: \(details)"
            
        // Resource Management Errors
        case .resourceAllocationFailed(let details):
            return "Failed to allocate resources: \(details)"
        case .resourceCleanupFailed(let details):
            return "Failed to clean up resources: \(details)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .accessibilityPermissionDenied:
            return "The application needs accessibility permissions to function properly"
        case .screenNotAvailable:
            return "The main screen could not be accessed, which is required for cursor highlighting"
        case .windowCreationFailed:
            return "System resources may be constrained or permissions may be insufficient"
        case .animationInProgress:
            return "An animation is already running and must complete or be cleaned up first"
        case .invalidAnimationParameters:
            return "The provided animation parameters are outside acceptable ranges"
        case .cleanupFailed:
            return "Resources could not be properly released"
        case .clickFailed:
            return "The click operation could not be completed"
        case .invalidClickLocation:
            return "The specified click location is outside the valid screen area"
        case .clickingNotEnabled:
            return "Click automation must be enabled before performing clicks"
        case .invalidState:
            return "The application has entered an invalid state"
        case .stateTransitionFailed:
            return "The requested state transition could not be completed"
        case .resourceAllocationFailed:
            return "Required system resources could not be allocated"
        case .resourceCleanupFailed:
            return "Resources could not be properly released"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .accessibilityPermissionDenied:
            return "Open System Settings > Privacy & Security > Accessibility and grant permission to PointerPilot"
        case .screenNotAvailable:
            return "Ensure your display is properly connected and recognized by macOS"
        case .windowCreationFailed:
            return "Try restarting the application"
        case .animationInProgress:
            return "Wait for the current animation to complete or force stop it"
        case .invalidAnimationParameters:
            return "Check the animation parameters are within valid ranges"
        case .cleanupFailed:
            return "Try restarting the application to release resources"
        case .clickFailed:
            return "Ensure the target window is active and accessible"
        case .invalidClickLocation:
            return "Ensure the click location is within the visible screen area"
        case .clickingNotEnabled:
            return "Enable click automation before attempting to perform clicks"
        case .invalidState:
            return "Try restarting the application to reset its state"
        case .stateTransitionFailed:
            return "Check the application logs for more details"
        case .resourceAllocationFailed:
            return "Close other applications to free up system resources"
        case .resourceCleanupFailed:
            return "Restart the application to ensure proper resource cleanup"
        }
    }
}

// MARK: - Error Handling Extensions

extension PointerPilotError {
    /// Logs the error using the logging service
    /// - Parameter component: The component where the error occurred
    func log(from component: LoggingService.Component) {
        LoggingService.shared.logError(
            localizedDescription,
            error: self,
            component: component
        )
    }
    
    /// Creates and shows an alert for this error
    /// - Parameter window: The window to attach the alert to (optional)
    func showAlert(attachedTo window: NSWindow? = nil) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = self.localizedDescription
            alert.informativeText = [
                self.failureReason,
                "To fix this:",
                self.recoverySuggestion
            ].compactMap { $0 }.joined(separator: "\n\n")
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            
            if let window = window {
                alert.beginSheetModal(for: window)
            } else {
                alert.runModal()
            }
        }
    }
} 