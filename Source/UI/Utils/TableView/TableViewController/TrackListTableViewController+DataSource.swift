//
//  TableViewController+DataSource.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension TrackListTableViewController: NSTableViewDataSource {
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {numberOfTracks}
    
    // MARK: Drag n drop
    
    // Writes source information to the pasteboard
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pasteboard: NSPasteboard) -> Bool {

        TableDragDropContext.setIndicesAndData(rowIndexes, trackList[rowIndexes], from: tableView, pasteboard: pasteboard)
        return true
    }
    
    // Validates the proposed drag/drop operation
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        
        if isTrackListBeingModified {return .invalidDragOperation}
        
        // If the source is the same tableView, that means tracks are being reordered.
        if let sourceTable = info.draggingSource as? NSTableView,
           sourceTable === self.tableView, let sourceIndexSet = TableDragDropContext.indices {
            
            // Reordering of tracks
            return validateReorderOperation(tableView, sourceIndexSet, row, dropOperation) ? .move : .invalidDragOperation
        }
        
        // TODO: What about items added from apps other than Finder ??? From VOX or other audio players ???
        
        // Otherwise, files are being dragged in from outside the table view
        // (e.g. tracks/playlists from Finder or drag/drop from another track list).
        return .copy
    }
    
    // Given source indexes, a destination index (dropRow), and the drop operation (on/above), determines if the drop is a valid reorder operation (depending on the bounds of the playlist, and the source and destination indexes)
    private func validateReorderOperation(_ tableView: NSTableView, _ sourceIndexSet: IndexSet, _ dropRow: Int, _ operation: NSTableView.DropOperation) -> Bool {
        
        // If all rows are selected, they cannot be moved, and dropRow cannot be one of the source rows
        return operation == .above && (sourceIndexSet.count < tableView.numberOfRows) && !sourceIndexSet.contains(dropRow)
    }
    
    // Performs the drop
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        
        defer {TableDragDropContext.reset()}
        
        if isTrackListBeingModified {return false}
        
        if let sourceTable = info.draggingSource as? NSTableView {
            
            // TODO: Move this to the PQ, this is not valid for the Library or other track lists.
            if player.isInGaplessPlaybackMode {
                
                DispatchQueue.main.async {
                    NSAlert.showInfo(withTitle: "Function unavailable", andText: "Reordering of Play Queue tracks is not possible while in gapless playback mode.")
                }
                
                return false
            }
            
            // TODO: PQ can override the helper functions with options for 'clearQueue' and 'autoplay'.
            // Figure out the user requirements / use cases.
            
            // Re-order tracks within the same table.
            if sourceTable === self.tableView,
               let sourceIndices = TableDragDropContext.indices {
                
                // TODO: Special case (if only 1 track in the list or all tracks selected, do nothing)
                
                moveTracks(from: sourceIndices, to: row)
                return true
            }
            
            // Import tracks from another TrackList.
            if let sourceTracks = TableDragDropContext.data as? [Track] {
                
                importTracks(sourceTracks, to: row)
                return true
            }

//            // Import files from the Tune Browser.
//            if let fsItems = TableDragDropContext.data as? [FileSystemItem] {
//                
//                importFiles(fileSystemItems: fsItems, to: row)
//                return true
//            }
//            
//            // Import from Tune Browser folders (shortcuts) and playlist names table.
//            if let sidebarItems = TableDragDropContext.data as? [LibrarySidebarItem] {
//                
//                importFromLibrarySidebarItems(sidebarItems, to: row)
//                return true
//            }
            
        } else if let files = info.urls {
            
            // TODO: Move this to the PQ, this is not valid for the Library or other track lists.
            if player.isInGaplessPlaybackMode {
                
                DispatchQueue.main.async {
                    NSAlert.showInfo(withTitle: "Function unavailable", andText: "Adding tracks to the Play Queue is not possible while in gapless playback mode.")
                }
                
                return false
            }
            
            // If adding at the end of the list, just do an "append" instead of an "insert"
            if row == trackList.size {
                loadFinderTracks(from: files)
                
            } else {
                
                // Files added from Finder, add them to the playlist as URLs
                loadFinderTracks(from: files, atPosition: row)
            }
            
            return true
        }
        
        return false
    }
    
    @objc func loadFinderTracks(from files: [URL]) {
        trackList.loadTracks(from: files)
    }
    
    @objc func loadFinderTracks(from files: [URL], atPosition row: Int) {
        trackList.loadTracks(from: files, atPosition: row)
    }
    
    @objc func moveTracks(from sourceIndices: IndexSet, to destRow: Int) {
        
        let results = trackList.moveTracks(from: sourceIndices, to: destRow)
        
        let sortedMoves = results.filter({$0.movedDown}).sorted(by: >) +
            results.filter({$0.movedUp}).sorted(by: <)
        
        var allIndices: [Int] = []
        var destinationIndices: [Int] = []
        
        for move in sortedMoves {
            
            tableView.moveRow(at: move.sourceIndex, to: move.destinationIndex)
            
            // Collect source and destination indices for later
            allIndices += [move.sourceIndex, move.destinationIndex]
            destinationIndices.append(move.destinationIndex)
        }
        
        // Reload all source and destination rows, and all rows in between.
        if let minReloadIndex = allIndices.min(), let maxReloadIndex = allIndices.max() {
            
            tableView.reloadRows(minReloadIndex...maxReloadIndex)
            tracksMovedByDragDrop(minReloadIndex: minReloadIndex, maxReloadIndex: maxReloadIndex)
        }
        
        // Select all the destination rows (the new locations of the moved tracks).
        tableView.selectRows(destinationIndices)
    }
    
    @objc func tracksMovedByDragDrop(minReloadIndex: Int, maxReloadIndex: Int) {
        // Overriden by subclasses
    }

//    /// Import tracks from the file system (Tune Browser).
//    func importFiles(fileSystemItems: [FileSystemItem], to destRow: Int) {
//        trackList.loadTracks(from: fileSystemItems.map {$0.url}, atPosition: destRow)
//    }
    
    func importFiles(_ files: [URL], to destRow: Int) {
        trackList.loadTracks(from: files, atPosition: destRow)
    }
    
//    private func importFromLibrarySidebarItems(_ sidebarItems: [LibrarySidebarItem], to destRow: Int) {
//        
//        // Tune Browser folders (shortcuts).
//        let fileSystemItems = sidebarItems.filter {$0.browserTab == .fileSystem}
//        
//        if fileSystemItems.isNonEmpty {
//         
//            let folders: [URL] = fileSystemItems.compactMap {$0.tuneBrowserFolder}.map {$0.url}
//            importFiles(folders, to: destRow)
//        }
//        
//        // Playlist names.
////        let playlistItems = sidebarItems.filter {$0.browserTab == .playlists}
////        
////        if playlistItems.isNonEmpty {
////         
////            let playlistNames = playlistItems.map {$0.displayName}
////            importPlaylists(playlistNames.compactMap {playlistsManager.userDefinedObject(named: $0)}, to: destRow)
////        }
//    }
}

extension NSUserInterfaceItemIdentifier {
    
    static let tableId_compactPlayQueue: NSUserInterfaceItemIdentifier = .init(rawValue: "tid_CompactPlayQueue")
    static let tableId_playlist: NSUserInterfaceItemIdentifier = .init(rawValue: "tid_Playlist")
    static let tableId_playlistNames: NSUserInterfaceItemIdentifier = .init(rawValue: "tid_PlaylistNames")
}
