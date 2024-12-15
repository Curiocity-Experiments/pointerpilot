import SwiftUI
import AppKit
import QuartzCore

class CursorHighlighter {
    private var overlayWindow: NSWindow?
    private var animationLayers: [CAShapeLayer] = []
    private var cleanupWorkItem: DispatchWorkItem?
    
    deinit {
        cleanupWorkItem?.cancel()
        cleanup()
    }
    
    func showEchoRings(at location: CGPoint, size: CGFloat, color: NSColor, opacity: CGFloat) {
        cleanupWorkItem?.cancel()
        cleanup()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Find the screen containing the cursor
            let screens = NSScreen.screens
            let screenContainingCursor = screens.first { NSMouseInRect(location, $0.frame, false) } ?? NSScreen.main
            
            guard let screen = screenContainingCursor else { return }
            
            self.createAndShowAnimation(at: location, onScreen: screen, size: size, color: color, opacity: opacity)
        }
    }
    
    private func createAndShowAnimation(at location: CGPoint, onScreen screen: NSScreen, size: CGFloat, color: NSColor, opacity: CGFloat) {
        // Create overlay window matching the screen
        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: true
        )
        window.level = .floating
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.stationary, .canJoinAllSpaces, .ignoresCycle]
        
        // Create hosting view
        let hostingView = NSView(frame: screen.frame)
        hostingView.wantsLayer = true
        window.contentView = hostingView
        
        // Convert global coordinates to window coordinates
        let windowLocation = CGPoint(
            x: location.x - screen.frame.minX,
            y: location.y - screen.frame.minY
        )
        
        // Create outer glow ring
        let glowRing = createRingLayer(at: windowLocation, size: size * 1.2)
        glowRing.strokeColor = color.withAlphaComponent(0.3).cgColor
        glowRing.lineWidth = 6
        glowRing.shadowColor = color.cgColor
        glowRing.shadowRadius = 8
        glowRing.shadowOpacity = 0.5
        hostingView.layer?.addSublayer(glowRing)
        
        // Create main ring
        let mainRing = createRingLayer(at: windowLocation, size: size)
        mainRing.strokeColor = color.cgColor
        mainRing.lineWidth = 3
        hostingView.layer?.addSublayer(mainRing)
        
        // Create inner ring
        let innerRing = createRingLayer(at: windowLocation, size: size * 0.8)
        innerRing.strokeColor = color.withAlphaComponent(0.7).cgColor
        innerRing.lineWidth = 2
        hostingView.layer?.addSublayer(innerRing)
        
        // Store layers for cleanup
        animationLayers = [glowRing, mainRing, innerRing]
        
        // Add animations
        let duration: CFTimeInterval = 0.8
        
        // Glow ring animation
        let glowGroup = createAnimationGroup(fromScale: 0.3, toScale: 1.4, opacity: opacity, duration: duration)
        glowRing.add(glowGroup, forKey: "glow")
        
        // Main ring animation
        let mainGroup = createAnimationGroup(fromScale: 0.3, toScale: 1.2, opacity: opacity, duration: duration)
        mainRing.add(mainGroup, forKey: "main")
        
        // Inner ring animation
        let innerGroup = createAnimationGroup(fromScale: 0.3, toScale: 1.0, opacity: opacity, duration: duration)
        innerRing.add(innerGroup, forKey: "inner")
        
        // Show window
        self.overlayWindow = window
        window.orderFront(nil)
        
        // Schedule cleanup
        let cleanupItem = DispatchWorkItem { [weak self] in
            DispatchQueue.main.async {
                self?.cleanup()
            }
        }
        self.cleanupWorkItem = cleanupItem
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: cleanupItem)
    }
    
    private func createRingLayer(at location: CGPoint, size: CGFloat) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let path = CGMutablePath()
        path.addEllipse(in: CGRect(x: -size/2, y: -size/2, width: size, height: size))
        
        layer.path = path
        layer.position = location
        layer.fillColor = nil
        layer.lineCap = .round
        
        return layer
    }
    
    private func createAnimationGroup(fromScale: CGFloat, toScale: CGFloat, opacity: CGFloat, duration: CFTimeInterval) -> CAAnimationGroup {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = fromScale
        scaleAnimation.toValue = toScale
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = opacity
        opacityAnimation.toValue = 0.0
        
        let group = CAAnimationGroup()
        group.animations = [scaleAnimation, opacityAnimation]
        group.duration = duration
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        
        return group
    }
    
    private func cleanup() {
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.cleanup()
            }
            return
        }
        
        cleanupWorkItem?.cancel()
        cleanupWorkItem = nil
        
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()
        
        overlayWindow?.orderOut(nil)
        overlayWindow?.contentView = nil
        overlayWindow = nil
    }
} 