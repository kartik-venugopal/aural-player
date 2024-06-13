//
//  CompactAppModeController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CompactAppModeController: AppModeController {

    var mode: AppMode {.compact}

    private var windowController: CompactPlayerWindowController?
    
    var mainWindow: NSWindow? {windowController?.window}
    
    func presentMode(transitioningFromMode previousMode: AppMode?) {

        NSApp.setActivationPolicy(.regular)
        NSApp.menu = nil
        
        windowController = CompactPlayerWindowController()
        windowController?.showWindow(self)
        
        // Build Library if not already built or building
        // Always give it a low priority (not user-interactive through any UI components).
//        libraryDelegate.buildLibraryIfNotBuilt(immediate: false)
    }
    
    func dismissMode() {
        
        compactPlayerUIState.windowLocation = windowController?.window?.frame.origin
        windowController?.destroy()
        windowController = nil
    }
}
