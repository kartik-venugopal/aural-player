//
//  ValidatedLabelCell.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class ValidatedLabelCell: NSTextFieldCell {
    
    var errorState: Bool = false
    
    func markError(_ errorString: String) {
        
        errorState = true
        textColor = .red
        stringValue = errorString
    }
    
    func clearError() {
        
        errorState = false
        stringValue = ""
        textColor = .boxTextColor
    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        super.draw(withFrame: cellFrame, in: controlView)
        
        if errorState {
            
            // Draw a red rectangular border around the cell, indicating an error state
            
            let rect = NSBezierPath(rect: cellFrame)
            rect.stroke(withColor: .red, lineWidth: 3)
        }
    }
}
