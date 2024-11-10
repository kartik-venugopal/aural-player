//
//  ModularPlayerViewController+AutoHide.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension ModularPlayerViewController {
    
    private static let infoBoxDefaultPosition: NSPoint = NSPoint(x: 85, y: 85)
    private static let infoBoxCenteredPosition: NSPoint = NSPoint(x: 85, y: 65)
    private static let infoBoxCenteredPosition_noArt: NSPoint = NSPoint(x: 15, y: 65)

    private static let infoBoxDefaultWidth: CGFloat = 381
    private static let infoBoxWidth_noArt: CGFloat = 451

    private static let textViewDefaultWidth: CGFloat = 305
    private static let textViewWidth_noArt: CGFloat = 375

    private static let infoBoxDefaultPosition_noArt: NSPoint = NSPoint(x: 15, y: 85)
    
    override func mouseEntered(with event: NSEvent) {

        if multilineTrackTextView.trackInfo != nil {
            btnFunctionsMenu.show()
        }
        
        if !playerUIState.showControls {
            autoHideControls_show()
        }
    }
    
    override func mouseExited(with event: NSEvent) {

        if multilineTrackTextView.trackInfo != nil {
            btnFunctionsMenu.hide()
        }
        
        if !playerUIState.showControls {
            autoHideControls_hide()
        }
    }
    
    private func moveInfoBoxTo(_ point: NSPoint) {
        
//        infoBox.setFrameOrigin(point)
        artView.frame.origin.y = infoBox.frame.origin.y + 2 // 5 is half the difference in height between infoBox and artView
    }
    
    private func autoHideControls_show() {
        
        // Show controls
        controlsBox?.show()
//        moveInfoBoxTo(playerUIState.showAlbumArt ? Self.infoBoxDefaultPosition : Self.infoBoxDefaultPosition_noArt)
        artViewTopConstraint.constant = 26
        infoBoxTopConstraint.constant = 15
    }
    
    private func autoHideControls_hide() {
        
        // Hide controls
        controlsBox?.hide()
//        moveInfoBoxTo(playerUIState.showAlbumArt ? Self.infoBoxCenteredPosition : Self.infoBoxCenteredPosition_noArt)
        artViewTopConstraint.constant = 46
        infoBoxTopConstraint.constant = 35
    }
    
    private func resizeAndRepositionInfoBox() {
        
        if playerUIState.showAlbumArt {
            
            moveInfoBoxTo(playerUIState.showControls ? Self.infoBoxDefaultPosition : Self.infoBoxCenteredPosition)
            infoBox.resize(Self.infoBoxDefaultWidth, infoBox.height)
            
            multilineTrackTextView.clipView.enclosingScrollView?.resize(width: Self.textViewDefaultWidth)
            
        } else {
            
            moveInfoBoxTo(playerUIState.showControls ? Self.infoBoxDefaultPosition_noArt : Self.infoBoxCenteredPosition_noArt)
            infoBox.resize(Self.infoBoxWidth_noArt, infoBox.height)
            
            multilineTrackTextView.clipView.enclosingScrollView?.resize(width: Self.textViewWidth_noArt)
        }
        
        multilineTrackTextView.resized()
    }
    
    override func showOrHideAlbumArt() {
        
        artView.showIf(playerUIState.showAlbumArt)
//        resizeAndRepositionInfoBox()
        artViewLeadingConstraint.constant = playerUIState.showAlbumArt ? 15 : -55
        print("SV: \(multilineTrackTextView.clipView.enclosingScrollView!.frame.width)")
        multilineTrackTextView.resized()
    }
    
    override func showOrHideMainControls() {
        
        controlsBox?.showIf(playerUIState.showControls)
        
        artViewTopConstraint.constant = playerUIState.showControls ? 26 : 46
        infoBoxTopConstraint.constant = playerUIState.showControls ? 15 : 35
        
        // Re-position the info box, art view, and functions box
        
//        if playerUIState.showAlbumArt {
//            
//            artViewLeadingConstraint.constant = 15
////            moveInfoBoxTo(playerUIState.showControls ? Self.infoBoxDefaultPosition : Self.infoBoxCenteredPosition)
//        } else {
//            
//            artViewLeadingConstraint.constant = -55
////            moveInfoBoxTo(playerUIState.showControls ? Self.infoBoxDefaultPosition_noArt : Self.infoBoxCenteredPosition_noArt)
//        }
    }
}
