//
//  EffectsSheetViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class EffectsSheetViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"EffectsSheetView"}
    
    @IBOutlet weak var btnClose: TintedImageButton!
    @IBOutlet weak var effectsViewController: EffectsContainerViewController!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.addSubview(effectsViewController.view)
        
        btnClose.bringToFront()
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceiver: btnClose)
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        effectsViewController.showTab(.master)
    }
    
    @IBAction func closeAction(_ sender: NSButton) {
        endSheet()
    }
    
    func endSheet() {
        
        dismiss(self)
        Messenger.publish(.Effects.sheetDismissed)
    }
    
    override func destroy() {
        effectsViewController?.destroy()
    }
}

extension EffectsSheetViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        btnClose.contentTintColor = systemColorScheme.buttonColor
    }
}
