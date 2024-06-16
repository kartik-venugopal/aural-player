//
//  PlayQueueMenuController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayQueueMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var playSelectedTrackItem: NSMenuItem!
    
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
    
    private lazy var alertDialog: AlertWindowController = .instance
    
    private let playQueue: PlayQueueDelegateProtocol = playQueueDelegate
    
    private lazy var messenger = Messenger(for: self)
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        if appModeManager.currentMode == .unified, unifiedPlayerUIState.sidebarSelectedItem?.module != .playQueue {
            
            menu.items.forEach {$0.disable()}
            return
        }
        
        let selRows = playQueueUIState.selectedRows
        let hasSelRows = selRows.isNonEmpty
        
        let pqSize = playQueueDelegate.size
        let pqHasTracks = pqSize > 0
        let moreThanOneTrack = pqSize > 1
        let notAllTracksSelected = selRows.count < pqSize
        
        var playingTrackSelected = false
        if let currentTrackIndex = playQueue.currentTrackIndex, selRows.contains(currentTrackIndex) {
            playingTrackSelected = true
        }
        
        playSelectedTrackItem.enableIf(selRows.count == 1 && (!playingTrackSelected))
        
        [exportToPlaylistItem, removeAllTracksItem, selectAllTracksItem, invertSelectionItem, searchItem,
         pageUpItem, pageDownItem, scrollToTopItem, scrollToBottomItem, searchItem].forEach {
            
            $0.enableIf(pqHasTracks)
        }
        
        [removeSelectedTracksItem, clearSelectionItem].forEach {
            $0.enableIf(hasSelRows)
        }
        
        [cropSelectedTracksItem, moveSelectedTracksUpItem,
         moveSelectedTracksToTopItem, moveSelectedTracksDownItem, moveSelectedTracksToBottomItem].forEach {
            
            $0.enableIf(hasSelRows && moreThanOneTrack && notAllTracksSelected)
        }
        
        sortItem.enableIf(pqSize >= 2)
    }
    
    // Plays the selected play queue track.
    @IBAction func playSelectedTrackAction(_ sender: Any) {
        messenger.publish(.PlayQueue.playSelectedTrack)
    }
    
    // Shows the file open dialog to let the user select files / folders / playlists (M3U) to add to the play queue.
    @IBAction func importFilesAndFoldersAction(_ sender: Any) {
        messenger.publish(.PlayQueue.addTracks)
    }
    
    // Exports the play queue as an M3U playlist file.
    @IBAction func exportAsPlaylistFileAction(_ sender: Any) {
        messenger.publish(.PlayQueue.exportAsPlaylistFile)
    }
    
    // Removes any selected tracks from the play queue
    @IBAction func removeSelectedTracksAction(_ sender: Any) {
        
        if !checkIfPlayQueueIsBeingModified() {
            messenger.publish(.PlayQueue.removeTracks)
        }
    }
    
    // Crops track selection.
    @IBAction func cropSelectedTracksAction(_ sender: Any) {
        
        if !checkIfPlayQueueIsBeingModified() {
            messenger.publish(.PlayQueue.cropSelection)
        }
    }
    
    // Removes all tracks from the play queue.
    @IBAction func removeAllTracksAction(_ sender: Any) {
        
        if !checkIfPlayQueueIsBeingModified() {
            messenger.publish(.PlayQueue.removeAllTracks)
        }
    }
    
    @IBAction func selectAllTracksAction(_ sender: Any) {
        messenger.publish(.PlayQueue.selectAllTracks)
    }
    
    // Clears the play queue table view selection.
    @IBAction func clearSelectionAction(_ sender: Any) {
        messenger.publish(.PlayQueue.clearSelection)
    }
    
    // Inverts the play queue table view selection.
    @IBAction func invertSelectionAction(_ sender: Any) {
        messenger.publish(.PlayQueue.invertSelection)
    }
    
    // Moves any selected tracks up one row in the play queue
    @IBAction func moveTracksUpAction(_ sender: Any) {
        
        if !checkIfPlayQueueIsBeingModified() {
            messenger.publish(.PlayQueue.moveTracksUp)
        }
    }
    
    // Moves the selected playlist item up one row in the play queue
    @IBAction func moveTracksToTopAction(_ sender: Any) {
        
        if !checkIfPlayQueueIsBeingModified() {
            messenger.publish(.PlayQueue.moveTracksToTop)
        }
    }
    
    // Moves any selected tracks down one row in the play queue
    @IBAction func moveTracksDownAction(_ sender: Any) {
        
        if !checkIfPlayQueueIsBeingModified() {
            messenger.publish(.PlayQueue.moveTracksDown)
        }
    }
    
    // Moves the selected playlist item up one row in the play queue
    @IBAction func moveTracksToBottomAction(_ sender: Any) {
        
        if !checkIfPlayQueueIsBeingModified() {
            messenger.publish(.PlayQueue.moveTracksToBottom)
        }
    }
    
    // Scrolls the current playlist view to the very top.
    @IBAction func scrollToTopAction(_ sender: Any) {
        messenger.publish(.PlayQueue.scrollToTop)
    }
    
    // Scrolls the current playlist view to the very bottom.
    @IBAction func scrollToBottomAction(_ sender: Any) {
        messenger.publish(.PlayQueue.scrollToBottom)
    }
    
    @IBAction func pageUpAction(_ sender: Any) {
        messenger.publish(.PlayQueue.pageUp)
    }
    
    @IBAction func pageDownAction(_ sender: Any) {
        messenger.publish(.PlayQueue.pageDown)
    }
    
    @IBAction func searchAction(_ sender: Any) {
        messenger.publish(.PlayQueue.search)
    }
    
    private func checkIfPlayQueueIsBeingModified() -> Bool {
        
        let playQueueBeingModified = playQueue.isBeingModified
        
        if playQueueBeingModified {
            alertDialog.showAlert(.error, "Play Queue not modified", "The Play Queue cannot be modified while tracks are being added", "Please wait till the Play Queue is done adding tracks ...")
        }
        
        return playQueueBeingModified
    }
}
