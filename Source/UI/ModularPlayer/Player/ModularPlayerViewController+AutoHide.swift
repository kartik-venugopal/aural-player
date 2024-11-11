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
    
    private static let artViewLeading_Default: CGFloat = 15
    private static let artViewLeading_Hidden: CGFloat = -55
    
    private static let artViewTopPadding_Default: CGFloat = 26
    private static let artViewTopPadding_Centered: CGFloat = 46
    
    private static let infoBoxTopPadding_Default: CGFloat = 15
    private static let infoBoxTopPadding_Centered: CGFloat = 35
    
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
    
    private func autoHideControls_show() {
        
        // Show controls
        controlsBox?.show()

        artViewTopConstraint.constant = Self.artViewTopPadding_Default
        infoBoxTopConstraint.constant = Self.infoBoxTopPadding_Default
        view.layoutSubtreeIfNeeded()
    }
    
    private func autoHideControls_hide() {
        
        // Hide controls
        controlsBox?.hide()
        
        artViewTopConstraint.constant = Self.artViewTopPadding_Centered
        infoBoxTopConstraint.constant = Self.infoBoxTopPadding_Centered
        view.layoutSubtreeIfNeeded()
    }
    
    override func showOrHideAlbumArt() {
        
        artView.showIf(playerUIState.showAlbumArt)
        
        artViewLeadingConstraint.constant = playerUIState.showAlbumArt ? Self.artViewLeading_Default : Self.artViewLeading_Hidden
        view.layoutSubtreeIfNeeded()
        
        multilineTrackTextView.resized()
    }
    
    override func showOrHideMainControls() {
        
        controlsBox?.showIf(playerUIState.showControls)
        
        artViewTopConstraint.constant = playerUIState.showControls ? Self.artViewTopPadding_Default : Self.artViewTopPadding_Centered
        infoBoxTopConstraint.constant = playerUIState.showControls ? Self.infoBoxTopPadding_Default : Self.infoBoxTopPadding_Centered
        view.layoutSubtreeIfNeeded()
    }
}
