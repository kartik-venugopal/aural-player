//
//  InfoPopupViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    View controller for the popover that displays a brief information message when a track is added to or removed from the Favorites list
 */
import Cocoa

class InfoPopupViewController: SingletonPopoverViewController {
    
    static let autoHideIntervalSeconds: TimeInterval = 1.5
    
    // The label that displays informational messages
    @IBOutlet weak var lblInfo: NSTextField!
    
    // Timer used to auto-hide the popover once it is shown
    private var viewHidingTimer: Timer?
    
    override var nibName: NSNib.Name? {"InfoPopup"}
    
    // Shows a message and then auto-hides the view.
    func showMessage(_ message: String, _ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        
        lblInfo.stringValue = message
        showAndAutoHide(relativeToView, preferredEdge)
    }
    
    // Shows the popover and initiates a timer to auto-hide the popover after a preset time interval
    private func showAndAutoHide(_ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        
        show(relativeToView, preferredEdge)
        
        // Invalidate previously activated timer, if there is one
        viewHidingTimer?.invalidate()
        
        // Activate a new timer task to auto-hide the popover
        viewHidingTimer = .scheduledTimer(timeInterval: Self.autoHideIntervalSeconds, target: self,
                                          selector: #selector(self.close), userInfo: nil, repeats: false)
    }
    
    // Shows the popover
    private func show(_ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        
        if !isShown {
            popover.show(relativeTo: positioningRect, of: relativeToView, preferredEdge: preferredEdge)
        }
    }
    
    // Closes the popover
    @objc override func close() {
        super.close()
    }
}
