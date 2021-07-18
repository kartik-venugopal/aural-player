//
//  WindowedAppModeController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Controller responsible for presenting / dismissing the *Windowed* application user interface mode.
///
/// The windowed app mode's interace consists of several windows representing different application
/// modules - player, playlist, effects, chapters list, and several dialogs and utilities panels.
///
/// The windowed app mode is the default app mode and the one that will be presented upon the first
/// app startup or when no prior app state is available. It allows the user access to all of the application's
/// features and is intended for a high level of user interaction.
///
class WindowedAppModeController: AppModeController {
    
    var mode: AppMode {.windowed}
    
    private let manager: WindowLayoutsManager = objectGraph.windowLayoutsManager
    
    func presentMode(transitioningFromMode previousMode: AppMode?) {
        
        NSApp.setActivationPolicy(.regular)
        
        manager.restore()
        
        // If this is not a transition from a different app mode, we don't need to execute the hack below.
        if previousMode == nil || previousMode == .windowed {return}
        
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
