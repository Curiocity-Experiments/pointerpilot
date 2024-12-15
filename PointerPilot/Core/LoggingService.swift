import Foundation
import os.log

/// A centralized logging service for the application.
///
/// This service provides standardized logging functionality across the application,
/// with support for different log levels, subsystems, and categories.
///
/// Usage:
/// ```swift
/// let logger = LoggingService.shared.logger(for: .cursorHighlighter)
/// logger.debug("Cursor position updated")
/// ```
public final class LoggingService {
    // MARK: - Types
    
    /// Represents different components of the application for logging purposes
    public enum Component: String {
        case cursorHighlighter = "CursorHighlighter"
        case menuBar = "MenuBar"
        case clickAutomator = "ClickAutomator"
        case shortcutManager = "ShortcutManager"
        case appViewModel = "AppViewModel"
        
        var category: String { rawValue }
    }
    
    /// Represents different types of metrics that can be logged
    public enum MetricType {
        case animationDuration
        case clickCount
        case memoryUsage
        case cpuUsage
        
        var name: String {
            switch self {
            case .animationDuration: return "animation_duration"
            case .clickCount: return "click_count"
            case .memoryUsage: return "memory_usage"
            case .cpuUsage: return "cpu_usage"
            }
        }
    }
    
    // MARK: - Properties
    
    /// The shared instance of the logging service
    public static let shared = LoggingService()
    
    /// The subsystem identifier for all loggers
    private let subsystem = "com.curiocity.PointerPilot"
    
    /// Cache of loggers for different components
    private var loggers: [Component: Logger] = [:]
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Gets or creates a logger for the specified component
    /// - Parameter component: The component requiring logging
    /// - Returns: A configured Logger instance
    public func logger(for component: Component) -> Logger {
        if let existingLogger = loggers[component] {
            return existingLogger
        }
        
        let logger = Logger(subsystem: subsystem, category: component.category)
        loggers[component] = logger
        return logger
    }
    
    /// Logs a metric value
    /// - Parameters:
    ///   - type: The type of metric being logged
    ///   - value: The metric value
    ///   - component: The component the metric is associated with
    public func logMetric(_ type: MetricType, value: Double, component: Component) {
        let logger = self.logger(for: component)
        logger.debug("\(type.name): \(value, privacy: .public)")
    }
    
    /// Logs the start of a significant operation
    /// - Parameters:
    ///   - operation: The name of the operation
    ///   - component: The component performing the operation
    public func logOperationStart(_ operation: String, component: Component) {
        let logger = self.logger(for: component)
        logger.debug("⏳ Starting: \(operation, privacy: .public)")
    }
    
    /// Logs the end of a significant operation
    /// - Parameters:
    ///   - operation: The name of the operation
    ///   - component: The component that performed the operation
    ///   - duration: Optional duration of the operation in seconds
    public func logOperationEnd(_ operation: String, component: Component, duration: TimeInterval? = nil) {
        let logger = self.logger(for: component)
        if let duration = duration {
            logger.debug("✅ Completed: \(operation, privacy: .public) (took \(duration, privacy: .public)s)")
        } else {
            logger.debug("✅ Completed: \(operation, privacy: .public)")
        }
    }
    
    /// Logs an error with optional underlying error details
    /// - Parameters:
    ///   - message: The error message
    ///   - error: Optional underlying error
    ///   - component: The component where the error occurred
    public func logError(_ message: String, error: Error? = nil, component: Component) {
        let logger = self.logger(for: component)
        if let error = error {
            logger.error("❌ \(message, privacy: .public): \(error as NSError, privacy: .public)")
        } else {
            logger.error("❌ \(message, privacy: .public)")
        }
    }
}

// MARK: - Convenience Extensions

extension Logger {
    /// Logs a debug message with a timestamp
    /// - Parameter message: The message to log
    func debugWithTime(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        debug("[\(timestamp)] \(message, privacy: .public)")
    }
} 