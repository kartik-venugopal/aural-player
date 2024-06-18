//
//  TrackInfoSheetViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class TrackInfoSheetViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"TrackInfoSheetView"}
    
    @IBOutlet weak var btnClose: TintedImageButton!
    @IBOutlet weak var trackInfoViewController: TrackInfoViewController!
    
    private lazy var messenger: Messenger = .init(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.addSubview(trackInfoViewController.view)
        trackInfoViewController.view.anchorToSuperview()
        
        btnClose.bringToFront()
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceiver: btnClose)
    }
    
    @IBAction func closeAction(_ sender: NSButton) {
        endSheet()
    }
    
    func endSheet() {
        
        dismiss(self)
//        messenger.publish(.Effects.sheetDismissed)
    }
}

extension TrackInfoSheetViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        btnClose.contentTintColor = systemColorScheme.buttonColor
    }
}

