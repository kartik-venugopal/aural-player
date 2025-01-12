//
//  UnifiedPlayerViewController+AutoHide.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension UnifiedPlayerViewController {
    
    private static let infoBoxDefaultPosition: NSPoint = NSPoint(x: 80, y: 55)
    private static let infoBoxCenteredPosition: NSPoint = NSPoint(x: 80, y: 35)
    private static let infoBoxCenteredPosition_noArt: NSPoint = NSPoint(x: 15, y: 35)

    private static let infoBoxDefaultWidth: CGFloat = 381
    private static let infoBoxWidth_noArt: CGFloat = 451

    private static let textViewDefaultWidth: CGFloat = 305
    private static let textViewWidth_noArt: CGFloat = 375

    private static let infoBoxDefaultPosition_noArt: NSPoint = NSPoint(x: 15, y: 85)
    
    override func mouseEntered(with event: NSEvent) {
        
        mouseOverPlayer = true

        if multilineTrackTextView.trackInfo != nil {
            functionsButton.show()
        }
        
        if !playerUIState.showControls {
            autoHideControls_show()
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        
        mouseOverPlayer = false

        if multilineTrackTextView.trackInfo != nil {
            functionsButton.hide()
        }
        
        if !playerUIState.showControls {
            autoHideControls_hide()
        }
    }
    
    private func moveInfoBoxTo(_ point: NSPoint) {
        
        infoBox.setFrameOrigin(point)
        artView.frame.origin.y = infoBox.frame.origin.y // 5 is half the difference in height between infoBox and artView
    }
    
    private func moveInfoBoxToDefaultPosition() {
        moveInfoBoxVertically(offsetFromTop: 0)
    }
    
    private func moveInfoBoxToCenteredPosition() {
        moveInfoBoxVertically(offsetFromTop: 30)
    }
    
    private func moveInfoBoxVertically(offsetFromTop: CGFloat) {
        
        infoBox.removeAllConstraintsRelatedToSuperview(attributes: [.top])
        let newTopConstraint: NSLayoutConstraint = .topTopConstraint(forItem: infoBox!, relatedTo: infoBox.superview!, offset: offsetFromTop)
        infoBox.superview?.activateAndAddConstraint(newTopConstraint)
    }
    
    private func moveInfoBoxHorizontally() {
        
        
    }
    
    private func autoHideControls_show() {
        
        // Show controls
        controlsBox?.show()
//        moveInfoBoxTo(playerUIState.showAlbumArt ? Self.infoBoxDefaultPosition : Self.infoBoxDefaultPosition_noArt)
        moveInfoBoxToDefaultPosition()
    }
    
    private func autoHideControls_hide() {
        
        // Hide controls
        controlsBox?.hide()
//        moveInfoBoxTo(playerUIState.showAlbumArt ? Self.infoBoxCenteredPosition : Self.infoBoxCenteredPosition_noArt)
        moveInfoBoxToCenteredPosition()
    }
    
    override func showOrHideAlbumArt() {
        
        artView.showIf(playerUIState.showAlbumArt)
        
        infoBox.removeAllConstraintsFromSuperview(attributes: [.leading])
        let newConstraint: NSLayoutConstraint
        
        if playerUIState.showAlbumArt {
            
            newConstraint = .leadingTrailingConstraint(forItem: infoBox!, relatedTo: artView!, offset: 10)
//            multilineTrackTextView.clipView.enclosingScrollView?.resize(width: Self.textViewDefaultWidth)
            
        } else {
            
            newConstraint = .leadingLeadingConstraint(forItem: infoBox!, relatedTo: infoBox.superview!, offset: 0)
//            multilineTrackTextView.clipView.enclosingScrollView?.resize(width: Self.textViewWidth_noArt)
        }
        
        infoBox.superview?.activateAndAddConstraint(newConstraint)
        multilineTrackTextView.resized()
    }
    
    override func showOrHideMainControls() {
        
        controlsBox?.showIf(playerUIState.showControls)
        
        // Re-position the info box, art view, and functions box
        playerUIState.showControls ? moveInfoBoxToDefaultPosition() : moveInfoBoxToCenteredPosition()
    }
}
