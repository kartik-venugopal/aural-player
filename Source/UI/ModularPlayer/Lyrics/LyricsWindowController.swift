//
// LyricsWindowController.swift
// Aural
// 
// Copyright © 2024 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit
import LyricsCore

class LyricsWindowController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {"LyricsWindow"}
    
    @IBOutlet weak var btnClose: TintedImageButton!
    private lazy var btnCloseConstraints: LayoutConstraintsManager = LayoutConstraintsManager(for: btnClose)
    
    private var viewController: LyricsViewController = .init()
    
    private lazy var messenger = Messenger(for: self)
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        theWindow.contentView?.addSubview(viewController.view)
        viewController.view.anchorToSuperview()
        theWindow.isMovableByWindowBackground = true
        
        btnClose.bringToFront()
        btnCloseConstraints.setWidth(10)
        btnCloseConstraints.setHeight(10)
        btnCloseConstraints.setLeading(relatedToLeadingOf: btnClose.superview!, offset: 10)
        btnCloseConstraints.setTop(relatedToTopOf: btnClose.superview!, offset: 15)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceiver: btnClose)
        
        changeWindowCornerRadius(playerUIState.cornerRadius)
        
        DispatchQueue.main.async {
            self.theWindow.showCenteredOnScreen()
        }
    }
    
    func changeWindowCornerRadius(_ radius: CGFloat) {
        viewController.changeCornerRadius(radius)
    }
}

extension LyricsWindowController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        btnClose.contentTintColor = systemColorScheme.buttonColor
    }
}
