//
//  NSPopoverExtensions.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

extension NSPopover {
    
    convenience init(controller: NSViewController) {
        
        self.init()
        self.behavior = .semitransient
        self.contentViewController = controller
    }
}
