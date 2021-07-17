//
//  ControlBarAppModeController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Controller responsible for presenting / dismissing the *Control Bar* application user interface mode.
///
/// The control bar app mode presents a minimalistic user interface consisting of a single compact "floating"
/// window containing only player controls, playing track info, and some options to change the displayed info
/// and appearance (theme).
///
/// The control bar app mode allows the user access to essential player functions and is intended for a
/// low level of user interaction. It will typically be used when running the application in the "background".
///
class ControlBarAppModeController: NSObject, AppModeController, NSMenuDelegate {

    var mode: AppMode {.controlBar}

    private var windowController: ControlBarPlayerWindowController?
    
    func presentMode(transitioningFromMode previousMode: AppMode?) {

        NSApp.setActivationPolicy(.regular)
        NSApp.menu = nil
        
        windowController = ControlBarPlayerWindowController()
        windowController?.showWindow(self)
    }
    
    func dismissMode() {
        
        windowController?.destroy()
        windowController = nil
    }
}
