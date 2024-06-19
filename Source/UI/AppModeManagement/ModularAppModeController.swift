//
//  ModularAppModeController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Controller responsible for presenting / dismissing the *Modular* application user interface mode.
///
/// The modular app mode's interace consists of several windows representing different application
/// modules - player, playlist, effects, chapters list, and several dialogs and utilities panels.
///
/// The modular app mode is the default app mode and the one that will be presented upon the first
/// app startup or when no prior app state is available. It allows the user access to all of the application's
/// features and is intended for a high level of user interaction.
///
class ModularAppModeController: AppModeController {
    
    var mode: AppMode {.modular}
    
    var isShowingPlayer: Bool {true}
    
    var isShowingPlayQueue: Bool {
        windowLayoutsManager.isShowingWindow(withId: .playQueue)
    }
    
    var isShowingEffects: Bool {
        windowLayoutsManager.isShowingWindow(withId: .effects)
    }
    
    var isShowingChaptersList: Bool {
        windowLayoutsManager.isShowingWindow(withId: .chaptersList)
    }
    
    var isShowingVisualizer: Bool {
        windowLayoutsManager.isShowingWindow(withId: .visualizer)
    }
    
    var isShowingTrackInfo: Bool {
        windowLayoutsManager.isShowingWindow(withId: .trackInfo)
    }
    
    var mainWindow: NSWindow? {windowLayoutsManager.mainWindow}
    
    func presentMode(transitioningFromMode previousMode: AppMode?) {
        
        NSApp.setActivationPolicy(.regular)
        NSApp.menu = appDelegate.mainMenu
        
        windowLayoutsManager.restore()
        
        // Build Library if not already built or building
        // Give it a higher priority if the Library window is displayed.
//        libraryDelegate.buildLibraryIfNotBuilt(immediate: manager.isShowingLibrary)
        
        reactivateApp(previousMode: previousMode)
    }
    
    func dismissMode() {
        windowLayoutsManager.destroy()
    }
}
