//
//  EffectsWindowController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
 View controller for the Effects panel containing controls that alter the sound output (i.e. controls that affect the audio graph)
 */

import Cocoa

class EffectsWindowController: NSWindowController {
    
    override var windowNibName: String? {"EffectsWindow"}
    
    // ------------------------------------------------------------------------
    
    @IBOutlet weak var btnClose: TintedImageButton!
    
    private lazy var containerViewController: EffectsContainerViewController = .init()
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties

    private lazy var messenger = Messenger(for: self)
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle

    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        theWindow.contentView?.addSubview(containerViewController.view)
        containerViewController.view.anchorToSuperview()
        theWindow.isMovableByWindowBackground = true
        
        btnClose.bringToFront()
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceiver: btnClose)
        
        initSubscriptions()
    }
    
    override func destroy() {

        close()
        messenger.unsubscribeFromAll()
        containerViewController.destroy()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions

    @IBAction func closeWindowAction(_ sender: AnyObject) {
        windowLayoutsManager.hideWindow(withId: .effects)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    private func initSubscriptions() {
        messenger.subscribe(to: .Player.UI.changeCornerRadius, handler: changeWindowCornerRadius(_:))
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    func changeWindowCornerRadius(_ radius: CGFloat) {
        containerViewController.rootContainerBox.cornerRadius = radius
    }
}

extension EffectsWindowController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        btnClose.contentTintColor = systemColorScheme.buttonColor
    }
}
