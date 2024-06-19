//
//  ControlsContainerView.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class ControlsContainerView: MouseTrackingView {
    
    var viewsToShowOnMouseOver: [NSView] = []
    var viewsToHideOnMouseOver: [NSView] = []
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        startTracking()
    }
    
    override func setFrameSize(_ newSize: NSSize) {
        
        super.setFrameSize(newSize)
        
        removeAllTrackingAreas()
        updateTrackingAreas()

        viewsToShowOnMouseOver.forEach {$0.hide()}
        viewsToHideOnMouseOver.forEach {$0.show()}
    }
    
    override func mouseEntered(with event: NSEvent) {
        
        viewsToShowOnMouseOver.forEach {$0.show()}
        viewsToHideOnMouseOver.forEach {$0.hide()}
    }
    
    override func mouseExited(with event: NSEvent) {
        
        viewsToShowOnMouseOver.forEach {$0.hide()}
        viewsToHideOnMouseOver.forEach {$0.show()}
    }
}
