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
    
    private let manager: WindowLayoutsManager = windowLayoutsManager
    
    func presentMode(transitioningFromMode previousMode: AppMode?) {
        
        NSApp.setActivationPolicy(.regular)
        
        manager.restore()
        
        // Build Library if not already built or building
        // Give it a higher priority if the Library window is displayed.
//        libraryDelegate.buildLibraryIfNotBuilt(immediate: manager.isShowingLibrary)
        
        // If this is not a transition from a different app mode, we don't need to execute the hack below.
        if previousMode == nil || previousMode == .modular {return}
        
        // HACK - Because of an Apple bug, the main menu will not be usable until the app loses and then regains focus.
        // The following code simulates the user action of activating another app and then activating this app after a
        // short time interval.
        NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dock").first?.activate(options: [])

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
            NSApp.activate(ignoringOtherApps: true)
        })
    }
    
    func dismissMode() {
        manager.destroy()
    }
}
