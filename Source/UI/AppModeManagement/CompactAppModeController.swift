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
    
    var windowMagnetism: Bool = preferences.viewPreferences.windowMagnetism.value {
        
        didSet {
            
            if windowMagnetism {
                
                for window in NSApp.windows.filter({$0 != mainWindow}) {
                    
                    let isVisible = window.isVisible
                    mainWindow?.addChildWindow(window, ordered: .above)
                    
                    if !isVisible {
                        window.hide()
                    }
                }
                
            } else {
                
                mainWindow?.childWindows?.forEach {
                    
                    let isVisible = $0.isVisible
                    
                    mainWindow?.removeChildWindow($0)
                    $0.showIf(isVisible)
                }
            }
        }
    }
    
    var isShowingPlayer: Bool {
        windowController?.isShowingPlayer ?? false
    }
    
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
    
    var isShowingWaveform: Bool {
        windowController?.isShowingWaveform ?? false
    }
    
    var isShowingTrackInfo: Bool {
        windowController?.isShowingTrackInfo ?? false
    }

    func presentMode(transitioningFromMode previousMode: AppMode?) {

        NSApp.setActivationPolicy(.regular)
        NSApp.menu = appDelegate.mainMenu
        
        windowController = CompactPlayerWindowController()
        windowController?.showWindow(self)
        
        // Build Library if not already built or building
        // Always give it a low priority (not user-interactive through any UI components).
//        libraryDelegate.buildLibraryIfNotBuilt(immediate: false)
        
        reactivateApp(previousMode: previousMode)
    }
    
    func dismissMode() {
        
        compactPlayerUIState.windowLocation = windowController?.window?.frame.origin
        
        for window in NSApp.windows {
            
            window.windowController?.destroy()
            window.close()
        }
        
        windowController = nil
    }
}
