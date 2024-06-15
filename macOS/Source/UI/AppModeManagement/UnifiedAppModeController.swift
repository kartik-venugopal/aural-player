//
//  UnifiedAppModeController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class UnifiedAppModeController: AppModeController {
    
    var mode: AppMode {.unified}
    
    private var windowController: UnifiedPlayerWindowController?
    
    var mainWindow: NSWindow? {windowController?.window}
    
    var isShowingPlayer: Bool {true}
    
    var isShowingPlayQueue: Bool {
        windowController?.isShowingPlayQueue ?? false
    }
    
    var isShowingEffects: Bool {
        windowController?.isShowingEffects ?? false
    }
    
    var isShowingChaptersList: Bool {
        windowController?.isShowingChaptersList ?? false
    }
    
    var isShowingVisualizer: Bool {
        windowController?.isShowingVisualizer ?? false
    }
    
    var isShowingTrackInfo: Bool {
        windowController?.isShowingTrackInfo ?? false
    }

    func presentMode(transitioningFromMode previousMode: AppMode?) {

        NSApp.setActivationPolicy(.regular)
        NSApp.menu = (NSApp.delegate as? AppDelegate)?.mainMenu
        
        windowController = UnifiedPlayerWindowController()
        
        if let frame = unifiedPlayerUIState.windowFrame {
            windowController?.window?.setFrame(frame, display: true)
        }
        
        windowController?.showWindow(self)
        
        reactivateApp(previousMode: previousMode)
        
        // Build Library if not already built or building
        // Always give it a high priority.
//        libraryDelegate.buildLibraryIfNotBuilt(immediate: true)
    }
    
    func dismissMode() {

        unifiedPlayerUIState.windowFrame = windowController?.window?.frame
        windowController?.destroy()
        windowController = nil
    }
}
