//
//  PlayQueueMenuController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayQueueMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var playSelectedTrackItem: NSMenuItem!
    
    @IBOutlet weak var importFilesItem: NSMenuItem!
    @IBOutlet weak var exportToPlaylistItem: NSMenuItem!
    
    @IBOutlet weak var removeSelectedTracksItem: NSMenuItem!
    @IBOutlet weak var cropSelectedTracksItem: NSMenuItem!
    @IBOutlet weak var removeAllTracksItem: NSMenuItem!
    
    @IBOutlet weak var selectAllTracksItem: NSMenuItem!
    @IBOutlet weak var clearSelectionItem: NSMenuItem!
    @IBOutlet weak var invertSelectionItem: NSMenuItem!
    
    @IBOutlet weak var moveSelectedTracksUpItem: NSMenuItem!
    @IBOutlet weak var moveSelectedTracksToTopItem: NSMenuItem!
    @IBOutlet weak var moveSelectedTracksDownItem: NSMenuItem!
    @IBOutlet weak var moveSelectedTracksToBottomItem: NSMenuItem!
    
    @IBOutlet weak var searchItem: NSMenuItem!
    @IBOutlet weak var sortItem: NSMenuItem!
    
    @IBOutlet weak var pageUpItem: NSMenuItem!
    @IBOutlet weak var pageDownItem: NSMenuItem!
    @IBOutlet weak var scrollToTopItem: NSMenuItem!
    @IBOutlet weak var scrollToBottomItem: NSMenuItem!
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        if appModeManager.currentMode == .unified, unifiedPlayerUIState.sidebarSelectedItem?.module != .playQueue {
            
            menu.items.forEach {$0.disable()}
            return
        }
        
        let selRows = playQueueUIState.selectedRows
        let hasSelRows = selRows.isNonEmpty
        let notBeingModified = !playQueue.isBeingModified
        
        let pqSize = playQueue.size
        let pqHasTracks = pqSize > 0
        let moreThanOneTrack = pqSize > 1
        let notAllTracksSelected = selRows.count < pqSize
        
        var playingTrackSelected = false
        if let currentTrackIndex = playQueue.currentTrackIndex, selRows.contains(currentTrackIndex) {
            playingTrackSelected = true
        }
        
        let notInGaplessMode = !player.isInGaplessPlaybackMode
        
        playSelectedTrackItem.enableIf(selRows.count == 1 && (!playingTrackSelected))
        
        importFilesItem.enableIf(notBeingModified && notInGaplessMode)
        
        [exportToPlaylistItem, selectAllTracksItem, invertSelectionItem, searchItem,
         pageUpItem, pageDownItem, scrollToTopItem, scrollToBottomItem, searchItem].forEach {
            
            $0.enableIf(pqHasTracks)
        }
        
        removeAllTracksItem.enableIf(pqHasTracks && notBeingModified)
        
        removeSelectedTracksItem.enableIf(hasSelRows && notBeingModified && notInGaplessMode)
        clearSelectionItem.enableIf(hasSelRows)
        
        [cropSelectedTracksItem, moveSelectedTracksUpItem,
         moveSelectedTracksToTopItem, moveSelectedTracksDownItem, moveSelectedTracksToBottomItem].forEach {
            
            $0.enableIf(hasSelRows && notBeingModified && moreThanOneTrack && notAllTracksSelected && notInGaplessMode)
        }
        
        sortItem.enableIf(moreThanOneTrack && notBeingModified && notInGaplessMode)
    }
    
    // Plays the selected play queue track.
    @IBAction func playSelectedTrackAction(_ sender: Any) {
        Messenger.publish(.PlayQueue.playSelectedTrack)
    }
    
    // Shows the file open dialog to let the user select files / folders / playlists (M3U) to add to the play queue.
    @IBAction func importFilesAndFoldersAction(_ sender: Any) {
        Messenger.publish(.PlayQueue.addTracks)
    }
    
    // Exports the play queue as an M3U playlist file.
    @IBAction func exportAsPlaylistFileAction(_ sender: Any) {
        Messenger.publish(.PlayQueue.exportAsPlaylistFile)
    }
    
    // Removes any selected tracks from the play queue
    @IBAction func removeSelectedTracksAction(_ sender: Any) {
        Messenger.publish(.PlayQueue.removeTracks)
    }
    
    // Crops track selection.
    @IBAction func cropSelectedTracksAction(_ sender: Any) {
        Messenger.publish(.PlayQueue.cropSelection)
    }
    
    // Removes all tracks from the play queue.
    @IBAction func removeAllTracksAction(_ sender: Any) {
        Messenger.publish(.PlayQueue.removeAllTracks)
    }
    
    @IBAction func selectAllTracksAction(_ sender: Any) {
        Messenger.publish(.PlayQueue.selectAllTracks)
    }
    
    // Clears the play queue table view selection.
    @IBAction func clearSelectionAction(_ sender: Any) {
        Messenger.publish(.PlayQueue.clearSelection)
    }
    
    // Inverts the play queue table view selection.
    @IBAction func invertSelectionAction(_ sender: Any) {
        Messenger.publish(.PlayQueue.invertSelection)
    }
    
    // Moves any selected tracks up one row in the play queue
    @IBAction func moveTracksUpAction(_ sender: Any) {
        Messenger.publish(.PlayQueue.moveTracksUp)
    }
    
    // Moves the selected playlist item up one row in the play queue
    @IBAction func moveTracksToTopAction(_ sender: Any) {
        Messenger.publish(.PlayQueue.moveTracksToTop)
    }
    
    // Moves any selected tracks down one row in the play queue
    @IBAction func moveTracksDownAction(_ sender: Any) {
        Messenger.publish(.PlayQueue.moveTracksDown)
    }
    
    // Moves the selected playlist item up one row in the play queue
    @IBAction func moveTracksToBottomAction(_ sender: Any) {
        Messenger.publish(.PlayQueue.moveTracksToBottom)
    }
    
    // Scrolls the current playlist view to the very top.
    @IBAction func scrollToTopAction(_ sender: Any) {
        Messenger.publish(.PlayQueue.scrollToTop)
    }
    
    // Scrolls the current playlist view to the very bottom.
    @IBAction func scrollToBottomAction(_ sender: Any) {
        Messenger.publish(.PlayQueue.scrollToBottom)
    }
    
    @IBAction func pageUpAction(_ sender: Any) {
        Messenger.publish(.PlayQueue.pageUp)
    }
    
    @IBAction func pageDownAction(_ sender: Any) {
        Messenger.publish(.PlayQueue.pageDown)
    }
    
    @IBAction func searchAction(_ sender: Any) {
        Messenger.publish(.PlayQueue.search)
    }
}
