import SwiftUI
import Carbon.HIToolbox

class MenuBarManager: NSObject {
    private weak var viewModel: AppViewModel?
    private static weak var sharedViewModel: AppViewModel?
    
    init(viewModel: AppViewModel) {
        self.viewModel = viewModel
        super.init()
        MenuBarManager.sharedViewModel = viewModel
    }
    
    func createMainMenu() -> NSMenu {
        let mainMenu = NSMenu()
        
        // App menu
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "About PointerPilot", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Preferences...", action: #selector(showPreferences), keyEquivalent: ",")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit PointerPilot", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        
        let appMenuItem = NSMenuItem()
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)
        
        // View menu
        let viewMenu = NSMenu(title: "View")
        viewMenu.addItem(withTitle: "Show/Hide Window", action: #selector(toggleWindow), keyEquivalent: "p")
        
        let viewMenuItem = NSMenuItem()
        viewMenuItem.submenu = viewMenu
        mainMenu.addItem(viewMenuItem)
        
        return mainMenu
    }
    
    @objc private func showPreferences() {
        toggleWindow()
    }
    
    @objc static func toggleWindow() {
        if let window = NSApplication.shared.windows.first(where: { $0.title == "PointerPilot" }) {
            if window.isVisible {
                // Save position before hiding
                UserDefaults.standard.set(NSStringFromPoint(window.frame.origin), forKey: "windowPosition")
                window.orderOut(nil)
            } else {
                // Restore position or center
                if let savedPosition = UserDefaults.standard.string(forKey: "windowPosition") {
                    let point = NSPointFromString(savedPosition)
                    // Ensure the point is on screen and the titlebar is accessible
                    if let screen = NSScreen.main {
                        let safeFrame = screen.visibleFrame
                        let windowFrame = NSRect(origin: point, size: window.frame.size)
                        
                        // Ensure at least 22 points (title bar height) is visible from the top
                        let minY = safeFrame.minY
                        let maxY = safeFrame.maxY - windowFrame.height
                        let safeY = max(minY, min(maxY, point.y))
                        
                        // Ensure window is horizontally within screen bounds
                        let minX = safeFrame.minX
                        let maxX = safeFrame.maxX - windowFrame.width
                        let safeX = max(minX, min(maxX, point.x))
                        
                        window.setFrameOrigin(NSPoint(x: safeX, y: safeY))
                    } else {
                        Self.centerWindowOnMainScreen(window)
                    }
                } else {
                    Self.centerWindowOnMainScreen(window)
                }
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    @objc private func toggleWindow() {
        Self.toggleWindow()
    }
    
    private static func centerWindowOnMainScreen(_ window: NSWindow) {
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let windowFrame = window.frame
            let centerX = screenFrame.midX - windowFrame.width / 2
            let centerY = screenFrame.midY - windowFrame.height / 2
            window.setFrameOrigin(NSPoint(x: centerX, y: centerY))
        } else {
            window.center()
        }
    }
} 