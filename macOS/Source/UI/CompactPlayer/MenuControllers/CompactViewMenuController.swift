//
//  CompactViewMenuController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CompactViewMenuController: NSObject, NSMenuDelegate {
    
    private lazy var messenger: Messenger = .init(for: self)
    
//    @IBAction func modularModeAction(_ sender: AnyObject) {
//        messenger.publish(.CompactPlayer.switchToModularMode)
//    }
//    
//    @IBAction func unifiedModeAction(_ sender: AnyObject) {
//        messenger.publish(.CompactPlayer.switchToUnifiedMode)
//    }
//    
//    @IBAction func menuBarModeAction(_ sender: AnyObject) {
//        messenger.publish(.CompactPlayer.switchToMenuBarMode)
//    }
//    
//    @IBAction func widgetModeAction(_ sender: AnyObject) {
//        messenger.publish(.CompactPlayer.switchToWidgetMode)
//    }
}
