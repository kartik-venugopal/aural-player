//
//  PlayQueueContainerViewController+Actions.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension PlayQueueContainerViewController {
    
    // Switches the tab group to a particular tab
    @IBAction func tabViewAction(_ sender: TrackListTabButton) {
        doSelectTab(at: sender.tag)
    }
    
    func doSelectTab(at tabIndex: Int) {
        
        tabButtons.forEach {$0.unSelect()}
        tabButtons.first(where: {$0.tag == tabIndex})?.select()
        
        // Button tag is the tab index
        playQueueTabGroup.selectTabViewItem(at: tabIndex)
        playQueueUIState.currentView = PlayQueueView(rawValue: tabIndex)!
    }
    
    @IBAction func importFilesAndFoldersAction(_ sender: NSButton) {
        importFilesAndFolders()
    }
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    func importFilesAndFolders() {
        currentViewController.importFilesAndFoldersAction(self)
    }
    
    @IBAction func removeTracksAction(_ sender: Any) {
        removeTracks()
    }
    
    func removeTracks() {
        
        if checkForGaplessMode(actionText: "Removing Play Queue tracks") {return}
        
        // Check for at least 1 row (and also get the minimum index).
        guard let firstRemovedRow = currentViewController.selectedRows.min() else {return}
        
        currentViewController.removeTracks()
        
        controllers.forEach {
            $0.tracksRemoved(firstRemovedRow: firstRemovedRow)
        }
        
        updateSummary()
    }
    
    @IBAction func cropSelectionAction(_ sender: Any) {
        
        if checkForGaplessMode(actionText: "Reodering of Play Queue tracks") {return}
        cropSelection()
    }
    
    func cropSelection() {
        
        let tracksToDelete: IndexSet = currentViewController.invertedSelection
        
        guard tracksToDelete.isNonEmpty else {return}
        
        _ = playQueueDelegate.removeTracks(at: tracksToDelete)
        
        controllers.forEach {
            $0.reloadTable()
        }
        
        updateSummary()
    }
    
    @IBAction func removeAllTracksAction(_ sender: NSButton) {
        
        playQueueDelegate.removeAllTracks()
        controllers.forEach {$0.reloadTable()}
        updateSummary()
    }
    
    @IBAction func moveTracksUpAction(_ sender: Any) {
        
        if checkForGaplessMode(actionText: "Reodering of Play Queue tracks") {return}
        moveTracksUp()
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    func moveTracksUp() {

        guard currentViewController.atLeastTwoRowsAndNotAllSelected else {return}

        let selectedRows = currentViewController.selectedRows
        let results = playQueueDelegate.moveTracksUp(from: selectedRows)
        
        controllers.forEach {
            $0.moveAndReloadItems(results.sorted(by: <))
        }
        
        updateSummary()
        
        if let minRow = selectedRows.min() {
            currentViewController.scrollRowToVisible(minRow)
        }
    }
    
    @IBAction func moveTracksDownAction(_ sender: Any) {
        
        if checkForGaplessMode(actionText: "Reodering of Play Queue tracks") {return}
        moveTracksDown()
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    func moveTracksDown() {

        guard currentViewController.atLeastTwoRowsAndNotAllSelected else {return}

        let selectedRows = currentViewController.selectedRows
        let results = playQueueDelegate.moveTracksDown(from: selectedRows)
        
        controllers.forEach {
            $0.moveAndReloadItems(results.sorted(by: >))
        }
        
        updateSummary()
        
        if let minRow = selectedRows.min() {
            currentViewController.scrollRowToVisible(minRow)
        }
    }
    
    @IBAction func moveTracksToTopAction(_ sender: Any) {
        
        if checkForGaplessMode(actionText: "Reodering of Play Queue tracks") {return}
        moveTracksToTop()
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    func moveTracksToTop() {

        guard currentViewController.atLeastTwoRowsAndNotAllSelected else {return}
        
        let selectedRows = currentViewController.selectedRows
        let selectedRowCount = currentViewController.selectedRowCount
        let results = playQueueDelegate.moveTracksToTop(from: selectedRows)
        
        // Move the rows
        controllers.forEach {
            
            $0.removeAndInsertItems(results.sorted(by: <))
            
            // Refresh the relevant rows
            if let maxSelectedRow = selectedRows.max() {
                $0.reloadTableRows(0...maxSelectedRow)
            }
        }
        
        // Select all the same rows but now at the top
        currentViewController.scrollToTop()
        currentViewController.selectRows(0..<selectedRowCount)
        
        updateSummary()
    }

    @IBAction func moveTracksToBottomAction(_ sender: Any) {
        
        if checkForGaplessMode(actionText: "Reodering of Play Queue tracks") {return}
        moveTracksToBottom()
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    func moveTracksToBottom() {

        guard currentViewController.atLeastTwoRowsAndNotAllSelected else {return}
        
        let selectedRows = currentViewController.selectedRows
        let selectedRowCount = currentViewController.selectedRowCount
        let results = playQueueDelegate.moveTracksToBottom(from: selectedRows)
        let lastRow = currentViewController.lastRow
        
        controllers.forEach {
            
            // Move the rows
            $0.removeAndInsertItems(results.sorted(by: >))
            
            if let minSelectedRow = selectedRows.min() {
            
                // Refresh the relevant rows
                $0.reloadTableRows(minSelectedRow...lastRow)
            }
        }
        
        // Select all the same items but now at the bottom
        let firstSelectedRow = lastRow - selectedRowCount + 1
        currentViewController.selectRows(firstSelectedRow...lastRow)
        currentViewController.scrollToBottom()
        
        updateSummary()
    }
    
    private func checkForGaplessMode(actionText: String) -> Bool {
        
        if playbackDelegate.isInGaplessPlaybackMode {
            
            DispatchQueue.main.async {
                
                NSAlert.showInfo(withTitle: "Function unavailable",
                                 andText: "\(actionText) is not possible while in gapless playback mode.")
            }
            
            return true
        }
        
        return false
    }
    
    @IBAction func clearSelectionAction(_ sender: NSButton) {
        currentViewController.clearSelection()
    }
    
    @IBAction func invertSelectionAction(_ sender: NSButton) {
        currentViewController.invertSelection()
    }
    
    @IBAction func exportToPlaylistFileAction(_ sender: NSButton) {
        exportToPlaylistFile()
    }
    
    // Invokes the Save file dialog, to allow the user to save all playlist items to a playlist file
    func exportToPlaylistFile() {
        
        // Make sure there is at least one track to save.
        guard playQueueDelegate.size > 0, !checkIfPlayQueueIsBeingModified() else {return}

        if saveDialog.runModal() == .OK,
           let playlistFile = saveDialog.url {
            
            playQueueDelegate.exportToFile(playlistFile)
        }
    }
    
    // TODO: Can this func be put somewhere common / shared ???
    private func checkIfPlayQueueIsBeingModified() -> Bool {
        
        let playQueueBeingModified = playQueueDelegate.isBeingModified

        if playQueueBeingModified {

            alertDialog.showAlert(.error, "Play Queue not modified",
                                  "The Play Queue cannot be modified while tracks are being added",
                                  "Please wait till the Play Queue is done adding tracks ...")
        }

        return playQueueBeingModified
    }
    
    @IBAction func searchAction(_ sender: NSButton) {
        search()
    }
    
    @IBAction func sortByTrackNameAction(_ sender: NSMenuItem) {
        doSort(by: [.name])
    }
    
    @IBAction func sortByArtistAlbumDiscTrackNumberAction(_ sender: NSMenuItem) {
        doSort(by: [.artist, .album, .discNumberAndTrackNumber])
    }
    
    @IBAction func sortByArtistAlbumTrackNameAction(_ sender: NSMenuItem) {
        doSort(by: [.artist, .album, .name])
    }
    
    @IBAction func sortByArtistTrackNameAction(_ sender: NSMenuItem) {
        doSort(by: [.artist, .name])
    }
    
    @IBAction func sortByAlbumDiscTrackNumberAction(_ sender: NSMenuItem) {
        doSort(by: [.album, .discNumberAndTrackNumber])
    }
    
    @IBAction func sortByAlbumTrackNameAction(_ sender: NSMenuItem) {
        doSort(by: [.album, .name])
    }
    
    @IBAction func sortByDurationAction(_ sender: NSMenuItem) {
        doSort(by: [.duration])
    }
    
    private func doSort(by fields: [TrackSortField]) {
        
        currentViewController.sort(by: fields, order: sortOrderMenuItemView.sortOrder)
        updateSummary()
    }
    
    @IBAction func pageUpAction(_ sender: NSButton) {
        currentViewController.pageUp()
    }
    
    @IBAction func pageDownAction(_ sender: NSButton) {
        currentViewController.pageDown()
    }
    
    @IBAction func scrollToTopAction(_ sender: NSButton) {
        currentViewController.scrollToTop()
    }
    
    @IBAction func scrollToBottomAction(_ sender: NSButton) {
        currentViewController.scrollToBottom()
    }
    
    func playNext() {
        
        let destRows = playQueueDelegate.moveTracksToPlayNext(from: currentViewController.selectedRows)
        
        controllers.forEach {
            $0.tableView.reloadData()
        }
        
        // The current playing track index may have changed as a result of this operation.
        updateSummary()
        
        // Re-select the tracks that were moved.
        currentViewController.tableView.selectRows(destRows)
        
        if let minSelRow = destRows.min() {
            currentViewController.tableView.scrollRowToVisible(minSelRow)
        }
    }
    
//    func enqueueAndPlayNow(_ command: EnqueueAndPlayNowCommand) {
//        
//        let indices = playQueueDelegate.enqueueToPlayNow(tracks: command.tracks, clearQueue: command.clearPlayQueue)
//        
//        if indices.isNonEmpty, !command.clearPlayQueue {
//            
//            controllers.forEach {
//                $0.noteNumberOfRowsChanged()
//            }
//            
//        } else {
//            
//            controllers.forEach {
//                $0.reloadTable()
//            }
//        }
//        
//        if let firstTrack = command.tracks.first {
//            messenger.publish(TrackPlaybackCommandNotification(track: firstTrack))
//        }
//    }
    
    func loadAndPlayNow(_ command: LoadAndPlayNowCommand) {
        
        playQueueDelegate.loadTracks(from: command.files, params: .init(clearQueue: command.clearPlayQueue, autoplayFirstAddedTrack: true))
        
//        controllers.forEach {
//            
//            $0.reloadTable()
//            $0.updateSummary()
//        }
    }
    
    // TODO:
    func enqueueAndPlayNext(_ tracks: [Track]) {
        
//        let indices = playQueueDelegate.enqueueTracksToPlayNext(tracks)
        
    }
    
    // TODO:
    func enqueueAndPlayLater(_ tracks: [Track]) {
        
//        let indices = playQueueDelegate.enqueueTracks(tracks, clearQueue: false)
    }
}
