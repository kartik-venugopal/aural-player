//
//  ModularPlayerWindowController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Window controller for the main application window.
 */
class ModularPlayerWindowController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {"ModularPlayerWindow"}
    
    @IBOutlet weak var logoImage: TintedImageView!
    
    // The box that encloses the Now Playing info section
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var containerBox: NSBox!
    
    private let playerViewController: ModularPlayerViewController = ModularPlayerViewController()
    
    @IBOutlet weak var btnQuit: TintedImageButton!
    @IBOutlet weak var btnMinimize: TintedImageButton!
    @IBOutlet weak var presentationModeMenuItem: TintedIconMenuItem!
    
    @IBOutlet weak var btnSettingsMenu: NSPopUpButton!
    
    @IBOutlet weak var settingsMenuIconItem: TintedIconMenuItem!
    
    var eventMonitor: EventMonitor! = EventMonitor()
    
    let controlsPreferences: GesturesControlsPreferences = preferences.controlsPreferences.gestures
    
    lazy var buttonColorChangeReceivers: [ColorSchemePropertyChangeReceiver] = [btnQuit, btnMinimize, presentationModeMenuItem, settingsMenuIconItem]
    
    lazy var messenger = Messenger(for: self)
    
    // MARK: Setup
    
    // One-time setup
    override func windowDidLoad() {
        
        theWindow.isMovableByWindowBackground = true
        
        // TODO: Clean this up
        theWindow.setIsVisible(false)
        initWindow()
        theWindow.setIsVisible(false)
        
        setUpEventHandling()
        initSubscriptions()
        
        super.windowDidLoad()
    }
    
    // Set window properties
    private func initWindow() {
        
        theWindow.makeKeyAndOrderFront(self)
        
        containerBox.addSubview(playerViewController.view)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: logoImage)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: rootContainerBox)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceivers: buttonColorChangeReceivers)
        
        changeWindowCornerRadius(playerUIState.cornerRadius)
    }
    
    private func initSubscriptions() {
        messenger.subscribe(to: .Player.UI.changeCornerRadius, handler: changeWindowCornerRadius(_:))
    }
    
    override func destroy() {
        
        close()
        
        eventMonitor.stopMonitoring()
        eventMonitor = nil
        
        playerViewController.destroy()
        messenger.unsubscribeFromAll()
        
        SingletonPopoverViewController.destroy()
        StringInputPopoverViewController.destroy()
        SingletonWindowController.destroy()
    }
    
    // MARK: Actions -----------------------------------------------------------
    
    // Quits the app
    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    // Minimizes the window (and any child windows)
    @IBAction func minimizeAction(_ sender: AnyObject) {
        theWindow.miniaturize(self)
    }
    
    @IBAction func unifiedModeAction(_ sender: AnyObject) {
        appModeManager.presentMode(.unified)
    }
    
    @IBAction func menuBarModeAction(_ sender: AnyObject) {
        appModeManager.presentMode(.menuBar)
    }
    
    @IBAction func compactModeAction(_ sender: AnyObject) {
        appModeManager.presentMode(.compact)
    }
    
    @IBAction func widgetModeAction(_ sender: AnyObject) {
        appModeManager.presentMode(.widget)
    }
    
    // MARK: Message handling -----------------------------------------------------------
    
    func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainerBox.cornerRadius = radius
    }
}

extension ModularPlayerWindowController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        logoImage.contentTintColor = systemColorScheme.captionTextColor
        rootContainerBox.fillColor = systemColorScheme.backgroundColor
        
        buttonColorChangeReceivers.forEach {
            $0.colorChanged(systemColorScheme.buttonColor)
        }
    }
}
