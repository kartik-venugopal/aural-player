//
//  MouseTrackingView.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A special view that is able to track when the mouse cursor enters and/or exits the view.
    This is useful for views that need to auto-hide certain subviews in response to mouse movements.
 */
class MouseTrackingView: NSView {
    
    // Flag that indicates whether or not this view is currently tracking mouse movements.
    private(set) var isTracking: Bool = false
    
    override var frame: NSRect {
        
        get {
            super.frame
        }
        
        set {
            super.frame = newValue
            startTracking()
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        startTracking()
    }
    
    // Signals the view to start tracking mouse movements.
    func startTracking() {
        
        self.removeAllTrackingAreas()
        
        isTracking = true
        self.updateTrackingAreas()
    }
    
    // Signals the view to stop tracking mouse movements.
    func stopTracking() {
        
        isTracking = false
        self.removeAllTrackingAreas()
    }
 
    override func updateTrackingAreas() {
        
        if isTracking && self.trackingAreas.isEmpty {
        
            // Create a tracking area that covers the bounds of the view. It should respond whenever the mouse enters or exits.
            addTrackingArea(NSTrackingArea(rect: self.bounds, options: [.activeAlways, .mouseEnteredAndExited, .mouseMoved], owner: self, userInfo: nil))
            
            super.updateTrackingAreas()
        }
    }
}

extension NSView {
    
    // Signals the view to start tracking mouse movements.
    @objc func startTrackingBounds() {
        
        removeAllTrackingAreas()
        
        if trackingAreas.isEmpty {
        
            // Create a tracking area that covers the bounds of the view. It should respond whenever the mouse enters or exits.
            addTrackingArea(NSTrackingArea(rect: bounds, options: [.activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil))
            
            updateTrackingAreas()
        }
    }
    
    // Signals the view to stop tracking mouse movements.
    @objc func stopTrackingBounds() {
        removeAllTrackingAreas()
    }
}
