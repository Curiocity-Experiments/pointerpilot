import Cocoa

class ClickAutomator {
    private var clickTimer: Timer?
    private var isAutomating = false
    private var onClickCallback: (() -> Void)?
    
    func performClick() {
        let currentLocation = NSEvent.mouseLocation
        let clickDown = CGEvent(mouseEventSource: nil, 
                              mouseType: .leftMouseDown,
                              mouseCursorPosition: currentLocation,
                              mouseButton: .left)
        
        let clickUp = CGEvent(mouseEventSource: nil,
                            mouseType: .leftMouseUp,
                            mouseCursorPosition: currentLocation,
                            mouseButton: .left)
        
        clickDown?.post(tap: .cghidEventTap)
        
        // Add slight delay between down and up events
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            clickUp?.post(tap: .cghidEventTap)
            self.onClickCallback?()
        }
    }
    
    func startAutomatedClicks(interval: TimeInterval, onClick: (() -> Void)? = nil) {
        guard !isAutomating else { return }
        isAutomating = true
        onClickCallback = onClick
        
        clickTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.performClick()
        }
    }
    
    func stopAutomatedClicks() {
        clickTimer?.invalidate()
        clickTimer = nil
        isAutomating = false
        onClickCallback = nil
    }
    
    deinit {
        stopAutomatedClicks()
    }
} 