//
//  TrackListTableViewController+Actions.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension TrackListTableViewController {
    
    func checkAndAlertIfTrackListIsBeingModified() -> Bool {
        
        guard !trackList.isBeingModified else {
            
            // TODO: Show alert "Cannot add files to the <trackList.displayName> while it is being modified!"
            return true
        }
        
        return false
    }
    
    @IBAction func importFilesAndFoldersAction(_ sender: AnyObject) {
        
        if checkAndAlertIfTrackListIsBeingModified() {return}
        importFilesAndFolders()
    }
    
    @IBAction func removeTracksAction(_ sender: AnyObject) {
        
        if checkAndAlertIfTrackListIsBeingModified() {return}
        removeTracks()
    }
    
    @IBAction func cropSelectionAction(_ sender: AnyObject) {
        
        if checkAndAlertIfTrackListIsBeingModified() {return}
        cropSelection()
    }
    
    @IBAction func removeAllTracksAction(_ sender: AnyObject) {
        
        if checkAndAlertIfTrackListIsBeingModified() {return}
        removeAllTracks()
    }
    
    // MARK: Reordering of tracks
    
    // Moves any selected tracks up one row in the play queue
    @IBAction func moveTracksUpAction(_ sender: Any) {
        
        if checkAndAlertIfTrackListIsBeingModified() {return}
        moveTracksUp()
    }
    
    // Moves any selected tracks down one row in the play queue
    @IBAction func moveTracksDownAction(_ sender: Any) {
        
        if checkAndAlertIfTrackListIsBeingModified() {return}
        moveTracksDown()
    }
    
    // Moves the selected playlist item up one row in the play queue
    @IBAction func moveTracksToTopAction(_ sender: Any) {
        
        if checkAndAlertIfTrackListIsBeingModified() {return}
        moveTracksToTop()
    }
    
    // Moves the selected playlist item up one row in the play queue
    @IBAction func moveTracksToBottomAction(_ sender: Any) {
        
        if checkAndAlertIfTrackListIsBeingModified() {return}
        moveTracksToBottom()
    }
    
    // MARK: Table view selection manipulation
    
    @IBAction func clearSelectionAction(_ sender: AnyObject) {
        clearSelection()
    }
    
    @IBAction func invertSelectionAction(_ sender: AnyObject) {
        invertSelection()
    }
    
    @IBAction func exportToPlaylistAction(_ sender: AnyObject) {
        exportTrackList()
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
    
    @IBAction func pageUpAction(_ sender: AnyObject) {
        pageUp()
    }
    
    @IBAction func pageDownAction(_ sender: AnyObject) {
        pageDown()
    }
    
    @IBAction func scrollToTopAction(_ sender: AnyObject) {
        scrollToTop()
    }
    
    @IBAction func scrollToBottomAction(_ sender: AnyObject) {
        scrollToBottom()
    }
}
