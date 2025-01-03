//
// LyricsSheetViewController.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

class LyricsSheetViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"LyricsSheetView"}
    
    @IBOutlet weak var btnClose: TintedImageButton!
    @IBOutlet weak var lyricsViewController: LyricsViewController!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.addSubview(lyricsViewController.view)
        lyricsViewController.view.anchorToSuperview()
        
        btnClose.bringToFront()
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceiver: btnClose)
    }
    
    @IBAction func closeAction(_ sender: NSButton) {
        endSheet()
    }
    
    func endSheet() {
        dismiss(self)
    }
    
    override func destroy() {
        lyricsViewController?.destroy()
    }
}

extension LyricsSheetViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        btnClose.contentTintColor = systemColorScheme.buttonColor
    }
}
