//
//  TrackInfoViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the "Detailed Track Info" popover
*/
class TrackInfoWindowController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {"TrackInfoWindow"}
    
    @IBOutlet weak var btnClose: NSButton!
    private lazy var btnCloseConstraints: LayoutConstraintsManager = LayoutConstraintsManager(for: btnClose)
    
    private lazy var messenger = Messenger(for: self)
    
    private let viewController = TrackInfoViewController()
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        window?.contentView?.addSubview(viewController.view)
        viewController.view.anchorToSuperview()
        
        // Bring the 'X' (Close) button to the front and constrain it.
        btnClose.bringToFront()
        
        btnCloseConstraints.setWidth(10)
        btnCloseConstraints.setHeight(10)
        btnCloseConstraints.setLeading(relatedToLeadingOf: btnClose.superview!, offset: 10)
        btnCloseConstraints.setTop(relatedToTopOf: btnClose.superview!, offset: 15)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceiver: btnClose)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        close()
    }
}

extension TrackInfoWindowController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        btnClose.contentTintColor = systemColorScheme.buttonColor
    }
}
