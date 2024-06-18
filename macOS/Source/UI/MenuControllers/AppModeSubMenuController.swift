//
//  AppModeSubMenuController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class AppModeSubMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var modularModeMenuItem: NSMenuItem!
    @IBOutlet weak var unifiedModeMenuItem: NSMenuItem!
    @IBOutlet weak var compactModeMenuItem: NSMenuItem!
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        [modularModeMenuItem, unifiedModeMenuItem, compactModeMenuItem].forEach {$0?.off()}
        
        switch appModeManager.currentMode {
            
        case .modular:
            modularModeMenuItem?.on()
            
        case .unified:
            unifiedModeMenuItem?.on()
            
        case .compact:
            compactModeMenuItem?.on()
            
        default:
            break
        }
    }
    
    @IBAction func modularModeAction(_ sender: NSMenuItem) {
        appModeManager.presentMode(.modular)
    }
    
    @IBAction func unifiedModeAction(_ sender: NSMenuItem) {
        appModeManager.presentMode(.unified)
    }
    
    @IBAction func compactModeAction(_ sender: NSMenuItem) {
        appModeManager.presentMode(.compact)
    }
    
    @IBAction func menuBarModeAction(_ sender: NSMenuItem) {
        appModeManager.presentMode(.menuBar)
    }
    
    @IBAction func widgetModeAction(_ sender: NSMenuItem) {
        appModeManager.presentMode(.widget)
    }
}
