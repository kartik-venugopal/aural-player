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

class ControlBarAppModeController: NSObject, AppModeController, NSMenuDelegate, NotificationSubscriber {

    var mode: AppMode {.controlBar}

    private var controller: ControlBarPlayerWindowController?
    
    func presentMode(transitioningFromMode previousMode: AppMode?) {

        NSApp.setActivationPolicy(.regular)
        NSApp.menu = nil
        
        controller = ControlBarPlayerWindowController()
        controller?.showWindow(self)
    }
    
    func dismissMode() {
        
        controller?.destroy()
        controller = nil
    }
}
