//
//  MouseTrackingOutlineView.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class MouseTrackingOutlineView: NSOutlineView {
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        startTrackingBounds()
    }
    
    override func mouseEntered(with event: NSEvent) {
        
        super.mouseEntered(with: event)
        let row = self.row(at: self.convert(event.locationInWindow, from: nil))
        print("\nMouse ENTERED !!! Row = \(row)")
    }
    
    override func mouseExited(with event: NSEvent) {
        
        super.mouseExited(with: event)
        print("\nMouse EXITED !!!")
    }
}
