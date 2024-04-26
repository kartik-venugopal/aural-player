//
//  SearchWindowController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class SearchWindowController: NSWindowController {
    
    override var windowNibName: String? {"SearchWindow"}
    
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var btnClose: TintedImageButton!
    
    private lazy var viewController: SearchViewController = .init()
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    /// Singleton
    static let shared: SearchWindowController = .init()
    
    override func windowDidLoad() {
        
        super.windowDidLoad()

        theWindow.contentView?.addSubview(viewController.view)
        viewController.view.anchorToSuperview()
        
        btnClose.bringToFront()
        
        theWindow.center()
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: rootContainerBox)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceiver: btnClose)
        
        messenger.subscribe(to: .Player.UI.changeCornerRadius, handler: changeWindowCornerRadius(_:))
        changeWindowCornerRadius(playerUIState.cornerRadius)
    }
    
    func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainerBox.cornerRadius = radius
    }
    
    @IBAction func closeAction(sender: NSButton) {
        close()
    }
}

extension SearchWindowController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        rootContainerBox.fillColor = systemColorScheme.backgroundColor
        btnClose.contentTintColor = systemColorScheme.buttonColor
    }
}
