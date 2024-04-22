//
//  CompactPlayQueueViewController+Actions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

extension CompactPlayQueueViewController {
    
    @IBAction func removeSelectedTracksAction(_ sender: Any) {
        removeSelectedTracks()
    }
    
    func removeSelectedTracks() {
        
        let selectedRows = self.selectedRows
        
        // Check for at least 1 row (and also get the minimum index).
        guard let firstRemovedRow = selectedRows.min() else {return}
        
        _ = playQueueDelegate.removeTracks(at: selectedRows)
        clearSelection()
        
        // Update all rows from the first (i.e. smallest index) removed row, down to the end of the track list.
        let lastRowAfterRemove = playQueueDelegate.size - 1
        
        // Tell the playlist view that the number of rows has changed (should result in removal of rows)
        noteNumberOfRowsChanged()
        
        // This will be true unless a contiguous block of tracks was removed from the bottom of the track list.
        if firstRemovedRow <= lastRowAfterRemove {
            reloadTableRows(firstRemovedRow...lastRowAfterRemove)
        }
        
        updateSummary()
    }
    
    @IBAction func searchAction(_ sender: Any) {
        messenger.publish(.CompactPlayer.showSearch)
    }
}
