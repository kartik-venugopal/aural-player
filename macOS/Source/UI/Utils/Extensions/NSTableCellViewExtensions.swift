//
//  NSTableCellViewExtensions.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

extension NSTableCellView {
    
    var text: String? {
        
        get {textField?.stringValue}
        set {textField?.stringValue = newValue ?? ""}
    }
    
    var attributedText: NSAttributedString? {
        
        get {textField?.attributedStringValue}
        set {textField?.attributedStringValue = newValue ?? NSAttributedString(string: "")}
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
    
    var imageColor: NSColor? {
        
        get {imageView?.contentTintColor}
        set {imageView?.contentTintColor = newValue}
    }
}
