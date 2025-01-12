//
//  ColorClipboard.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
 A utility that holds a single color in memory. Provides copy/paste capabilities.
 */
class ColorClipboard {
    
    // The color held (copied) in memory that can be pasted.
    var color: NSColor? {
        
        didSet {
            
            // Inform observer of the change.
            colorChangeCallback()
        }
    }
    
    // Registers a callback to let an observer know that the color has changed.
    var colorChangeCallback: () -> Void = {}
    
    // Whether or not the clipboard currently holds a color.
    var hasColor: Bool {
        color != nil
    }
    
    // Clears the clipboard.
    func clear() {
        color = nil
    }
    
    // Stores a color that is copied.
    func copy(_ color: NSColor) {
        self.color = color
    }
}
