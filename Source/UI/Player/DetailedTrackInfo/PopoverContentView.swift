//
//  PopoverContentView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
        
        if let frameView = self.window?.contentView?.superview {
            
            if backgroundView == nil {
                
                backgroundView = PopoverBackgroundView(frame: frameView.bounds)
                backgroundView!.autoresizingMask = NSView.AutoresizingMask([NSView.AutoresizingMask.width, NSView.AutoresizingMask.height]);
                frameView.addSubview(backgroundView!, positioned: .below, relativeTo: frameView)
            }
        }
    }
}

// Sets the background color for the popover
class PopoverBackgroundView: NSView {
    
    override func draw(_ dirtyRect: NSRect) {
        
        Colors.popoverBackgroundColor.setFill()
        self.bounds.fill()
    }
}

/*
    Exposes high-level operations performed on the popover view, and is used to provide abstraction.
 */
protocol PopoverViewDelegate {
    
    // Shows the popover view
    func show(_ track: Track, _ relativeToView: NSView, _ preferredEdge: NSRectEdge)
    
    // Checks if the popover view is shown
    var isShown: Bool {get}
    
    // Closes the popover view
    func close()
    
    // Toggles the popover view (show/close)
    func toggle(_ track: Track, _ relativeToView: NSView, _ preferredEdge: NSRectEdge)
    
    // Refreshes the track info in the popover view
    func refresh(_ track: Track)
}
