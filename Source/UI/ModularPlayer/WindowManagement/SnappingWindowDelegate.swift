//
//  SnappingWindowDelegate.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class SnappingWindowDelegate: NSObject, NSWindowDelegate {
    
    private unowned var window: SnappingWindow!
    private lazy var viewPreferences: ViewPreferences = preferences.viewPreferences
    
    init(window: SnappingWindow) {
        
        self.window = window
        super.init()
        
        self.window.delegate = self
    }
    
    func windowDidMove(_ notification: Notification) {
        
        // Only respond if movement was user-initiated (flag on window).
        guard window.userMovingWindow else {return}
        
        // Main window cannot be snapped to other windows because all other windows move with the main window.
        if !window.isTheMainWindow, checkForSnapToWindows() {
            return
        }
        
        // If window doesn't need to be snapped to another window, check if it needs to be snapped to the visible frame
        checkForSnapToScreen()
    }
    
    private func checkForSnapToWindows() -> Bool {
        
        guard viewPreferences.snapToWindows.value else {return false}

        // This window can be snapped to all visible windows except itself.
        let snapCandidates = NSApp.windows.compactMap {$0 as? SnappingWindow}.filter {$0.isVisible && $0.identifier != self.window.identifier}

        // Check if window can be snapped to another app window
        return snapCandidates.contains(where: {window.checkForSnap(to: $0)})
    }
    
    private func checkForSnapToScreen() {
        
        if viewPreferences.snapToScreen.value {
            window.checkForSnapToVisibleFrame()
        }
    }
}
