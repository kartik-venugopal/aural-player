//
//  MenuBarPlayQueueContainer.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class MenuBarPlayQueueContainer: PlayQueueContainer {
    
    @IBOutlet weak var btnSort: NSButton!
    @IBOutlet weak var sortOptionsBox: NSBox!
    
    override func setUpSubviewsForAutoHide() {
        
        viewsToShowOnMouseOver = [btnImportTracks, btnExport,
                                  btnRemoveTracks, btnCropTracks, btnRemoveAllTracks,
                                  btnMoveTracksUp, btnMoveTracksDown, btnMoveTracksToTop, btnMoveTracksToBottom,
                                  btnSort]
        
        viewsToHideOnMouseOver = [lblTracksSummary, lblDurationSummary]
        
        allButtons = [btnImportTracks, btnExport,
                      btnRemoveTracks, btnCropTracks, btnRemoveAllTracks,
                      btnMoveTracksUp, btnMoveTracksDown, btnMoveTracksToTop, btnMoveTracksToBottom,
                      btnSort]
    }
    
    override func mouseExited(with event: NSEvent) {
        
        super.mouseExited(with: event)
        
        if sortOptionsBox.isShown {
            sortOptionsBox.hide()
        }
    }
}
