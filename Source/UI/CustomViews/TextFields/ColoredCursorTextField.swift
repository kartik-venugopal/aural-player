//
//  ColoredCursorTextField.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Customizes the color of the cursor of a text field
 */
class ColoredCursorTextField: NSTextField {
    
    override func viewDidMoveToWindow() {
        
        // Change the cursor color
        
        if let fieldEditor = self.window?.fieldEditor(true, for: self) as? NSTextView {
            fieldEditor.insertionPointColor = .textFieldCursorColor
        }
    }
}
