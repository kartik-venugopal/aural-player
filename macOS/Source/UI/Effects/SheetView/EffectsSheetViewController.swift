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
    
    private lazy var messenger: Messenger = .init(for: self)
    
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
        
        let mainAppWindowID: String = appModeManager.currentMode == .compact ? "compactPlayer" : "unifiedPlayer"

        // Close AU editor and Filter band editor dialogs
        for window in NSApp.windows.filter({$0.isVisible}) {
            
            let windowID = window.identifier?.rawValue
            
            if windowID != mainAppWindowID {
                window.close()
            }
        }
        
        messenger.publish(.Effects.sheetDismissed)
    }
}

extension EffectsSheetViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        btnClose.contentTintColor = systemColorScheme.buttonColor
    }
}
