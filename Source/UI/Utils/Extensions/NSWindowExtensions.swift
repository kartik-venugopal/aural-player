//
//  NSWindowExtensions.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

extension NSWindow {
    
    var windowID: WindowID? {
        
        if let idStr = identifier?.rawValue {
            return WindowID(rawValue: idStr)
        }
        
        return nil
    }
    
    var origin: NSPoint {frame.origin}
    
    var width: CGFloat {frame.width}
    
    var height: CGFloat {frame.height}
    
    var size: NSSize {frame.size}
    
    func resize(_ newWidth: CGFloat, _ newHeight: CGFloat) {
        
        var newFrame = self.frame
        newFrame.size = NSSize(width: newWidth, height: newHeight)
        setFrame(newFrame, display: true)
    }
    
    // X co-ordinate of location
    var x: CGFloat {
        self.frame.origin.x
    }
    
    // Y co-ordinate of location
    var y: CGFloat {
        self.frame.origin.y
    }
    
    var maxX: CGFloat {
        self.frame.maxX
    }
    
    var maxY: CGFloat {
        self.frame.maxY
    }
    
    func show() {
        setIsVisible(true)
    }
    
    func hide() {
        setIsVisible(false)
    }
    
    func showIf(_ condition: Bool) {
        condition ? show() : hide()
    }
    
    func showCentered(relativeTo parent: NSWindow) {
        
        let posX = parent.x + ((parent.width - width) / 2)
        let posY = parent.y + ((parent.height - height) / 2)
        
        setFrameOrigin(NSPoint(x: posX, y: posY))
        setIsVisible(true)
    }
    
    // Centers this window with respect to the screen and shows it.
    func showCenteredOnScreen() {
        
        center()
        setIsVisible(true)
        
        if canBecomeKey {
            makeKeyAndOrderFront(self)
        }
    }
    
    func moveTo(_ point: NSPoint, ensureVisible: Bool = true) {
        
        setFrameOrigin(point)
        
        if ensureVisible {
            self.ensureVisible()
        }
    }
    
    func ensureVisible() {
        
        let screens = NSScreen.screens
        
        for screen in screens {
            
            if CGRectContainsRect(screen.visibleFrame, self.frame) {
                return
            }
        }
        
        showCenteredOnScreen()
    }
}

extension NSViewController: Destroyable {
    @objc func destroy() {}
}

extension NSWindowController: Destroyable {
    
    var theWindow: NSWindow {self.window!}
    
    func forceLoadingOfWindow() {
        
        if !self.isWindowLoaded {
            _ = self.window
        }
    }
    
    var attachedSheetViewController: NSViewController? {
        window?.attachedSheet?.contentViewController
    }
    
    func dismissAttachedSheet() {
        attachedSheetViewController?.dismiss(self)
    }
    
    @objc func destroy() {}
}
