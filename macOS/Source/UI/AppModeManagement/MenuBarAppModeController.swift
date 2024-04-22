//
//  MenuBarAppModeController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
class MenuBarAppModeController: NSObject, AppModeController {

    var mode: AppMode {.menuBar}

    private var statusItem: NSStatusItem?
    
    private var playerViewController: MenuBarPlayerViewController!
    private lazy var playQueueViewController: MenuBarPlayQueueViewController! = .init()
    private lazy var settingsWindowController: MenuBarSettingsWindowController! = .init()
    
    private var playQueueMenuItem: NSMenuItem!
    
    private let appIcon: NSImage = NSImage(named: "AppIcon-MenuBar")!
    
    private lazy var messenger: Messenger = .init(for: self)
    
    override init() {
        
        super.init()
        
        messenger.subscribe(to: .MenuBarPlayer.showSettings, handler: showSettings)
        messenger.subscribe(to: .MenuBarPlayer.togglePlayQueue, handler: togglePlayQueue)
    }
    
    func presentMode(transitioningFromMode previousMode: AppMode?) {
        
        playerViewController = MenuBarPlayerViewController()

        // Make app run in menu bar and make it active.
        NSApp.setActivationPolicy(.accessory)
        NSApp.activate(ignoringOtherApps: true)
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem?.button?.image = appIcon
        statusItem?.button?.toolTip = "Aural Player v\(NSApp.appVersion)"
        
        let menu = NSMenu()
        statusItem?.menu = menu
        
        let playerMenuItem = NSMenuItem(view: playerViewController.view)
        menu.addItem(playerMenuItem)
        
        togglePlayQueue()
        
        menu.delegate = playerViewController
    }
    
    func dismissMode() {
        
        playerViewController?.destroy()
        playQueueViewController?.destroy()
     
        if let statusItem = self.statusItem {
            
            statusItem.menu?.cancelTracking()
            statusItem.menu = nil
            
            NSStatusBar.system.removeStatusItem(statusItem)
            self.statusItem = nil
        }
        
        playerViewController = nil
        playQueueViewController = nil
        playQueueMenuItem = nil
        settingsWindowController = nil
    }
    
    private func showSettings() {
        
        NSApp.activate(ignoringOtherApps: true)
        
        settingsWindowController.showWindow(self)
        settingsWindowController.window?.center()
        settingsWindowController.window?.makeKeyAndOrderFront(self)
    }
    
    private func togglePlayQueue() {
        
        createPlayQueueMenuItemIfRequired()
        playQueueMenuItem?.showIf(menuBarPlayerUIState.showPlayQueue)
    }
    
    private func createPlayQueueMenuItemIfRequired() {
        
        guard menuBarPlayerUIState.showPlayQueue, playQueueMenuItem == nil else {return}
        
        statusItem?.menu?.addItem(.separator())
        
        self.playQueueMenuItem = NSMenuItem(view: playQueueViewController.view)
        statusItem?.menu?.addItem(playQueueMenuItem)
    }
}
