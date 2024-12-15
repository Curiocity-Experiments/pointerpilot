//
//  PointerPilotApp.swift
//  PointerPilot
//
//  Created by Randall Noval on 12/1/24.
//

import SwiftUI
import AppKit

// Window controller to manage window and delegate
private class WindowController: NSObject, NSWindowDelegate {
    static let shared = WindowController()
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // Allow normal window closing behavior
        return true
    }
    
    func windowWillMiniaturize(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            UserDefaults.standard.set(NSStringFromPoint(window.frame.origin), 
                                    forKey: AppConfig.Storage.windowPositionKey)
        }
    }
    
    func setupWindow(_ window: NSWindow) {
        window.delegate = self
        window.title = "Mouse Ping"
        
        // Configure window style
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.titlebarAppearsTransparent = false
        window.titleVisibility = .visible
        window.isMovableByWindowBackground = false
        
        // Set window frame
        let frame = NSRect(
            x: 0,
            y: 0,
            width: AppConfig.UI.Layout.minWindowWidth,
            height: AppConfig.UI.Layout.minWindowHeight
        )
        window.setFrame(frame, display: true)
        
        // Set min/max sizes
        window.minSize = NSSize(
            width: AppConfig.UI.Layout.minWindowWidth,
            height: AppConfig.UI.Layout.minWindowHeight
        )
        window.maxSize = NSSize(
            width: AppConfig.UI.Layout.maxWindowWidth,
            height: AppConfig.UI.Layout.maxWindowHeight
        )
        
        // Center window by default
        window.center()
        
        // Ensure window is interactive
        window.ignoresMouseEvents = false
        window.acceptsMouseMovedEvents = true
    }
    
    func restoreWindowPosition(_ window: NSWindow, savedPosition: String?) {
        if let savedPosition = savedPosition {
            let point = NSPointFromString(savedPosition)
            if NSScreen.screens.first(where: { $0.frame.contains(point) }) != nil {
                window.setFrameOrigin(point)
            } else {
                window.center()
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var menuBarManager: MenuBarManager?
    var viewModel: AppViewModel? {
        didSet {
            if let viewModel = viewModel {
                setupMenuBar(with: viewModel)
            }
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // First ensure the window is properly set up and interactive
        NSApp.setActivationPolicy(.regular)
        
        if let window = NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
            NSApp.activate(ignoringOtherApps: true)
        }
        
        // Delay accessibility check to ensure window is fully functional first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.checkAccessibilityPermissions()
        }
    }
    
    private func checkAccessibilityPermissions() {
        // Check without prompting first
        if !AXIsProcessTrusted() {
            // Show a non-modal alert that doesn't block window interaction
            let alert = NSAlert()
            alert.messageText = "Accessibility Permissions Required"
            alert.informativeText = "Some features require accessibility permissions to function. You can continue using basic features, but highlighting and clicking won't work until permissions are granted."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Later")
            
            // Show the alert as a sheet on the main window
            if let window = NSApp.windows.first {
                alert.beginSheetModal(for: window) { response in
                    if response == .alertFirstButtonReturn {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                }
            }
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if let window = NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
        return true
    }
    
    func setupMenuBar(with viewModel: AppViewModel) {
        // Create menu bar manager
        menuBarManager = MenuBarManager(viewModel: viewModel)
        
        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "cursorarrow.rays", accessibilityDescription: "Mouse Ping")
            button.target = menuBarManager
            button.action = #selector(MenuBarManager.toggleWindow)
        }
        
        // Set up menu
        let menu = NSMenu()
        
        // Show/Hide Window
        let toggleItem = NSMenuItem(title: "Show/Hide Window", 
                                  action: #selector(MenuBarManager.toggleWindow), 
                                  keyEquivalent: "p")
        toggleItem.target = menuBarManager
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // About
        let aboutItem = NSMenuItem(title: "About Mouse Ping",
                                 action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
                                 keyEquivalent: "")
        aboutItem.target = NSApp
        menu.addItem(aboutItem)
        
        // Quit - Using the application's terminate action
        let quitItem = NSMenuItem(title: "Quit Mouse Ping",
                                action: #selector(NSApplication.terminate(_:)),
                                keyEquivalent: "q")
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
        
        // Set up main menu if needed
        if NSApp.mainMenu == nil {
            let mainMenu = NSMenu()
            
            // Application Menu
            let appMenu = NSMenu()
            let appMenuItem = NSMenuItem(title: "Mouse Ping", action: nil, keyEquivalent: "")
            appMenuItem.submenu = appMenu
            
            // About Item
            let mainAboutItem = NSMenuItem(title: "About Mouse Ping",
                                         action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
                                         keyEquivalent: "")
            mainAboutItem.target = NSApp
            appMenu.addItem(mainAboutItem)
            
            appMenu.addItem(NSMenuItem.separator())
            
            // Quit Item - Using the application's terminate action
            let mainQuitItem = NSMenuItem(title: "Quit Mouse Ping",
                                        action: #selector(NSApplication.terminate(_:)),
                                        keyEquivalent: "q")
            appMenu.addItem(mainQuitItem)
            
            mainMenu.addItem(appMenuItem)
            NSApp.mainMenu = mainMenu
        }
    }
}

@main
struct PointerPilotApp: App {
    @StateObject private var viewModel: AppViewModel
    @AppStorage(AppConfig.Storage.windowPositionKey) private var windowPosition: String?
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        let services = AppServices()
        _viewModel = StateObject(wrappedValue: AppViewModel(services: services))
        // Configure default window style
        NSWindow.allowsAutomaticWindowTabbing = false
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .frame(
                    minWidth: AppConfig.UI.Layout.minWindowWidth,
                    maxWidth: AppConfig.UI.Layout.maxWindowWidth,
                    minHeight: AppConfig.UI.Layout.minWindowHeight,
                    maxHeight: AppConfig.UI.Layout.maxWindowHeight
                )
                .onAppear {
                    setupWindow()
                    // Share the view model with the app delegate
                    appDelegate.viewModel = viewModel
                }
                .onDisappear {
                    if let window = NSApplication.shared.windows.first {
                        windowPosition = NSStringFromPoint(window.frame.origin)
                    }
                }
        }
        .defaultSize(width: 300, height: 400)
        .commands {
            CommandGroup(replacing: .windowSize) {}
            CommandGroup(replacing: .windowArrangement) {}
        }
    }
    
    private func setupWindow() {
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                WindowController.shared.setupWindow(window)
                WindowController.shared.restoreWindowPosition(window, savedPosition: windowPosition)
                
                // Ensure window is properly activated
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}
