//
//  CompactPlayQueueContainer.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class CompactPlayQueueContainer: PlayQueueContainer {
    
    override func setUpSubviewsForAutoHide() {
        
        viewsToShowOnMouseOver = [btnImportTracks, btnExport,
                                  btnRemoveTracks, btnCropTracks, btnRemoveAllTracks,
                                  btnMoveTracksUp, btnMoveTracksDown, btnMoveTracksToTop, btnMoveTracksToBottom,
                                  btnSearch, btnSortPopup]
        
        viewsToHideOnMouseOver = [lblTracksSummary, lblDurationSummary]
        
        allButtons = [btnImportTracks, btnExport,
                      btnRemoveTracks, btnCropTracks, btnRemoveAllTracks,
                      btnMoveTracksUp, btnMoveTracksDown, btnMoveTracksToTop, btnMoveTracksToBottom,
                      btnSearch, btnSortPopup]
    }
}
