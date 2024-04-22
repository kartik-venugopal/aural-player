//
//  TrackInfoViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the "Detailed Track Info" popover
*/
class TrackInfoWindowController: NSWindowController {
    
    override var windowNibName: String? {"TrackInfoWindow"}
    
    @IBOutlet weak var btnClose: NSButton!
    
    private lazy var messenger = Messenger(for: self)
    
    private let viewController = TrackInfoViewController()
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        window?.contentView?.addSubview(viewController.view)
        btnClose.bringToFront()
        
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
