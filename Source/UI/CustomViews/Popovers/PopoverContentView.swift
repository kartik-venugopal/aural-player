//
//  PopoverContentView.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    Custom view for popovers. This is needed in order to set their background color.
 */

import Cocoa

class PopoverContentView: NSView {
    
    private var backgroundView: PopoverBackgroundView?
    
    override func viewDidMoveToWindow() {
        
        super.viewDidMoveToWindow()
        
        if backgroundView == nil,
           let frameView = self.window?.contentView?.superview {
            
            backgroundView = PopoverBackgroundView(frame: frameView.bounds)
            backgroundView!.autoresizingMask = [.width, .height]
            frameView.addSubview(backgroundView!, positioned: .below, relativeTo: frameView)
        }
    }
}

// Sets the background color for the popover
class PopoverBackgroundView: NSView {
    
    override func draw(_ dirtyRect: NSRect) {
        self.bounds.fill(withColor: .popoverBackgroundColor)
    }
}
