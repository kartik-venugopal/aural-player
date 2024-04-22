//
//  PlayQueueTabButton.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

@IBDesignable
class TrackListTabButton: NSButton {
    
    var isSelected: Bool = false {
        
        didSet {
            redraw()
        }
    }
    
    func select() {
        isSelected = true
    }
    
    func unSelect() {
        isSelected = false
    }
}
