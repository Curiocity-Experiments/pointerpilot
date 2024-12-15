import SwiftUI
import os

private let logger = Logger(subsystem: "com.pointerpilot", category: "AppViewModel")

class AppViewModel: ObservableObject {
    static let toggleWindowNotification = NSNotification.Name("ToggleWindow")
    
    @Published private(set) var state: AppState {
        didSet {
            saveState()
        }
    }
    @Published private(set) var permissionStatus: PermissionStatus = .unknown
    
    private let services: AppServices
    private var clickTimer: Timer?
    private let cursorHighlighter: CursorHighlighter
    private var isAppActive: Bool = false
    
    init(services: AppServices) {
        self.services = services
        self.cursorHighlighter = CursorHighlighter()
        
        if let savedState = try? services.load(AppState.self, forKey: AppConfig.Storage.stateKey) {
            self.state = savedState
        } else {
            self.state = AppState()
        }
        
        setupNotifications()
        setupShortcuts()
        startPermissionMonitoring()
    }
    
    // MARK: - Permissions
    
    private func startPermissionMonitoring() {
        // Check permissions status periodically
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updatePermissionStatus()
            }
        }
    }
    
    private func updatePermissionStatus() {
        let newStatus: PermissionStatus = AXIsProcessTrusted() ? .granted : .notGranted
        if newStatus != permissionStatus {
            permissionStatus = newStatus
        }
    }
    
    func openAccessibilitySettings() {
        // Use the built-in system prompt
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
        
        // After a short delay, if permissions weren't granted, open System Settings
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if !AXIsProcessTrusted() {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }
    
    // MARK: - Cursor Actions
    
    func testMouseLocation() -> Bool {
        guard checkAndHandlePermissions() else {
            return false
        }
        
        let mouseLocation = NSEvent.mouseLocation
        logger.info("Testing highlight at location: x=\(mouseLocation.x, privacy: .public), y=\(mouseLocation.y, privacy: .public)")
        showHighlight(at: mouseLocation)
        return true
    }
    
    func testClick() -> Bool {
        guard checkAndHandlePermissions() else {
            return false
        }
        
        guard isSafeToClick() else {
            logger.error("Unsafe to click at current location")
            return false
        }
        
        do {
            let location = services.getCurrentMouseLocation()
            try services.performClick(at: location)
            showHighlight(at: location)
            return true
        } catch {
            logger.error("Test click failed: \(error.localizedDescription)")
            return false
        }
    }
    
    private func checkAndHandlePermissions() -> Bool {
        if !AXIsProcessTrusted() {
            NotificationCenter.default.post(
                name: NSNotification.Name("ShowPermissionsNeeded"),
                object: nil
            )
            return false
        }
        return true
    }
    
    // MARK: - Cursor Actions
    
    func startClicking() {
        if !AXIsProcessTrusted() {
            return
        }
        
        guard !self.state.isClickingEnabled else { return }
        
        updateState { state in
            state.isClickingEnabled = true
        }
        
        clickTimer = Timer.scheduledTimer(withTimeInterval: self.state.clickInterval, repeats: true) { [weak self] _ in
            self?.performClick()
        }
        
        logger.info("Auto-clicking started with interval: \(self.state.clickInterval)")
    }
    
    private func performClick() {
        if !AXIsProcessTrusted() {
            stopClicking()
            return
        }
        
        guard isSafeToClick() else {
            logger.warning("Skipping click - unsafe location")
            return
        }
        
        do {
            let location = services.getCurrentMouseLocation()
            try services.performClick(at: location)
            showHighlight(at: location)
        } catch {
            logger.error("Click failed: \(error.localizedDescription)")
            stopClicking()
        }
    }
    
    // MARK: - State Updates
    
    func updateState(_ update: (inout AppState) -> Void) {
        update(&state)
    }
    
    // MARK: - Auto-Clicking
    
    func toggleClicking() {
        if self.state.isClickingEnabled {
            stopClicking()
        } else {
            startClicking()
        }
    }
    
    func stopClicking() {
        updateState { state in
            state.isClickingEnabled = false
        }
        
        clickTimer?.invalidate()
        clickTimer = nil
        
        logger.info("Auto-clicking stopped")
    }
    
    // MARK: - Safety Checks
    
    private func isSafeToClick() -> Bool {
        let location = services.getCurrentMouseLocation()
        
        if let element = services.getElementAtLocation(location) {
            let role = services.getElementRole(element)
            let title = services.getElementTitle(element)
            
            let sensitiveRoles = ["AXButton", "AXMenuItem"]
            let sensitiveTitles = ["Delete", "Remove", "Close", "Quit", "Exit"]
            
            if sensitiveRoles.contains(role) && sensitiveTitles.contains(title) {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Settings
    
    func updateClickInterval(_ interval: Double) {
        updateState { state in
            state.clickInterval = interval
        }
        
        if self.state.isClickingEnabled {
            stopClicking()
            startClicking()
        }
    }
    
    func updateHighlightSize(_ size: Double) {
        updateState { state in
            state.highlightSize = size
        }
    }
    
    func updateHighlightOpacity(_ opacity: Double) {
        updateState { state in
            state.highlightOpacity = opacity
        }
    }
    
    func updateHighlightDuration(_ duration: Double) {
        updateState { state in
            state.highlightDuration = duration
        }
    }
    
    // MARK: - Window Management
    
    func toggleWindow() {
        NotificationCenter.default.post(name: AppViewModel.toggleWindowNotification, object: nil)
    }
    
    // MARK: - Private Methods
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isAppActive = false
            self?.stopClicking()  // Always stop clicking when losing focus
        }
        
        NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isAppActive = true
        }
    }
    
    private func setupShortcuts() {
        let shortcuts = ShortcutSettings.default
        
        // Register click shortcut
        services.registerShortcut(
            id: "click",
            keyCombo: shortcuts.click,
            handler: { [weak self] in
                DispatchQueue.main.async {
                    self?.toggleClicking()
                }
            }
        )
        
        // Register highlight shortcut
        services.registerShortcut(
            id: "highlight",
            keyCombo: shortcuts.highlight,
            handler: { [weak self] in
                DispatchQueue.main.async {
                    if let self = self, !self.testMouseLocation() {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("ShowPermissionsNeeded"),
                            object: nil
                        )
                    }
                }
            }
        )
        
        // Register window toggle shortcut
        services.registerShortcut(
            id: "toggle",
            keyCombo: shortcuts.toggle,
            handler: { [weak self] in
                DispatchQueue.main.async {
                    self?.toggleWindow()
                }
            }
        )
        
        // Register emergency stop shortcut
        services.registerShortcut(
            id: "emergency_stop",
            keyCombo: shortcuts.emergencyStop,
            handler: { [weak self] in
                DispatchQueue.main.async {
                    self?.stopClicking()
                }
            }
        )
    }
    
    private func saveState() {
        do {
            try services.save(state, forKey: AppConfig.Storage.stateKey)
        } catch {
            logger.error("Failed to save state: \(error.localizedDescription)")
        }
    }
    
    private func showHighlight(at location: CGPoint) {
        cursorHighlighter.showEchoRings(
            at: location,
            size: CGFloat(self.state.highlightSize),
            color: .systemBlue,
            opacity: CGFloat(self.state.highlightOpacity)
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopClicking()
    }
} 