//
//  AppModeController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import AppKit

///
/// A contract for a controller that is responsible for presenting / dismissing a
/// particular application user interface mode.
///
protocol AppModeController {
    
    var mode: AppMode {get}
    
    var mainWindow: NSWindow? {get}
    
    func presentMode(transitioningFromMode previousMode: AppMode?)
    
    func dismissMode()
}

extension AppModeController {
    
    var mainWindow: NSWindow? {nil}
    
    func reactivateApp(previousMode: AppMode?) {
        
        // If this is not a transition from a different app mode, we don't need to execute the hack below.
        guard let previousMode = previousMode, previousMode.equalsOneOf(.menuBar, .widget) else {return}
        
        // HACK - Because of an Apple bug, the main menu will not be usable until the app loses and then regains focus.
        // The following code simulates the user action of activating another app and then activating this app after a
        // short time interval.
        NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dock").first?.activate(options: [])

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
            NSApp.activate(ignoringOtherApps: true)
        })
    }
}
