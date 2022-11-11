//
//  NSTableCellViewExtensions.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

extension NSTableCellView {
    
    var text: String? {
        
        get {textField?.stringValue}
        
        set {
            
            if let theText = newValue {
                textField?.stringValue = theText
            }
        }
    }
    
    var textFont: NSFont? {

        get {textField?.font}
        set {textField?.font = newValue}
    }

    var textColor: NSColor? {

        get {textField?.textColor}
        set {textField?.textColor = newValue}
    }
    
    var image: NSImage? {
        
        get {imageView?.image}
        set {imageView?.image = newValue}
    }
}
