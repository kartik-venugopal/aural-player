//
//  TintableTextField.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension NSTextField: ColorSchemePropertyChangeReceiver {
    
    func colorChanged(_ newColor: NSColor) {
        textColor = newColor
    }
}

//extension NSTextField: FontSchemeObserver {
//    
//    func fontChanged(to newFont: NSFont, forProperty property: KeyPath<FontScheme, NSFont>) {
//        font = newFont
//    }
//}

extension NSTextView {
    
    func setBackgroundColor(_ newColor: NSColor) {
        
        backgroundColor = newColor
        enclosingScrollView?.backgroundColor = newColor
        enclosingScrollView?.contentView.backgroundColor = newColor
    }
}
