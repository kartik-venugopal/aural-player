//
//  NoTitleBarWindow.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class NoTitleBarWindow: NSWindow {
    
    override func awakeFromNib() {
        
        titlebarAppearsTransparent = true
        styleMask = styleMask.union(.miniaturizable)
    }
    
    override var canBecomeKey: Bool {true}
}

class NoTitleBarPanel: NSPanel {
    
//    override func awakeFromNib() {
//        self.titlebarAppearsTransparent = true
//    }
}
