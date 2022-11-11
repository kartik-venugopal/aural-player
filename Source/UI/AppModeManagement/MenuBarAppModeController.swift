//
//  MenuBarAppModeController.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Controller responsible for presenting / dismissing the *Menu Bar* application user interface mode.
///
/// The menu bar app mode's interace consists of a menu that drops down from the macOS menu bar.
/// The menu item that is displayed presents a view containing essential player controls and some basic
/// options to customize that view.
///
/// The menu bar app mode allows the user access to essential player functions and is intended for a
/// low level of user interaction. It will typically be used when running the application in the "background".
///
class MenuBarAppModeController: NSObject, AppModeController, NSMenuDelegate {

    var mode: AppMode {.menuBar}

    private var statusItem: NSStatusItem?
    private var viewController: MenuBarPlayerViewController!
    
    private let appIcon: NSImage = NSImage(named: "AppIcon-MenuBar")!
    
    func presentMode(transitioningFromMode previousMode: AppMode?) {
        
        viewController = MenuBarPlayerViewController()

        // Make app run in menu bar and make it active.
        NSApp.setActivationPolicy(.accessory)
        NSApp.activate(ignoringOtherApps: true)
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem?.button?.image = appIcon
        statusItem?.button?.toolTip = "Aural Player v\(NSApp.appVersion)"
        
        let menu = NSMenu()
        let menuItem = NSMenuItem(view: viewController.view)
        
        menu.addItem(menuItem)
        menu.delegate = self
        
        statusItem?.menu = menu
    }
    
    func menuDidClose(_ menu: NSMenu) {
        viewController?.menuBarMenuClosed()
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        viewController?.menuBarMenuOpened()
    }
    
    func dismissMode() {
        
        viewController?.destroy()
     
        if let statusItem = self.statusItem {
            
            statusItem.menu?.cancelTracking()
            statusItem.menu = nil
            
            NSStatusBar.system.removeStatusItem(statusItem)
            self.statusItem = nil
        }
        
        viewController = nil
    }
}
