//
//  PresentationModeSetupViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PresentationModeSetupViewController: NSViewController {
    
    override var nibName: String? {"PresentationModeSetup"}
    
    @IBOutlet weak var btnModularMode: NSButton!
    @IBOutlet weak var btnUnifiedMode: NSButton!
    @IBOutlet weak var btnCompactMode: NSButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        modularModeAction(self)
    }
    
    @IBAction func modularModeAction(_ sender: Any) {
        
        btnModularMode.state = .on
        btnUnifiedMode.state = .off
        btnCompactMode.state = .off
        
        appSetup.presentationMode = .modular
        
        print("Set presentation mode to: \(appSetup.presentationMode.rawValue)")
    }
    
    @IBAction func unifiedModeAction(_ sender: Any) {

        btnUnifiedMode.state = .on
        btnModularMode.state = .off
        btnCompactMode.state = .off
        
        appSetup.presentationMode = .unified
        
        print("Set presentation mode to: \(appSetup.presentationMode.rawValue)")
    }
    
    @IBAction func compactModeAction(_ sender: Any) {

        btnCompactMode.state = .on
        btnUnifiedMode.state = .off
        btnModularMode.state = .off
        
        appSetup.presentationMode = .compact
        
        print("Set presentation mode to: \(appSetup.presentationMode.rawValue)")
    }
}
