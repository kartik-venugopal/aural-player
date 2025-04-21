////
////  PlaylistNamesTableViewController+DataSource.swift
////  Aural
////
////  Copyright © 2025 Kartik Venugopal. All rights reserved.
////
////  This software is licensed under the MIT software license.
////  See the file "LICENSE" in the project root directory for license terms.
////  
//
//import Cocoa
//
//extension PlaylistNamesTableViewController: NSTableViewDataSource {
//    
//    // Drag and drop.
//    
//    // Returns the total number of playlist rows
//    func numberOfRows(in tableView: NSTableView) -> Int {
//        numberOfPlaylists
//    }
//    
//    // MARK: Drag n drop
//    
//    // Writes source information to the pasteboard
//    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pasteboard: NSPasteboard) -> Bool {
//
//        pasteboard.sourceIndexes = rowIndexes
//        return true
//    }
//    
//    // Validates the proposed drag/drop operation
//    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int,
//                   proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
//        
//        // Cannot drop between playlist names, can only drop onto a playlist name.
//        if dropOperation == .above {
//            return .invalidDragOperation
//        }
//
//        // Dragging from its own table view is not allowed.
//        if let sourceTable = info.draggingSource as? NSTableView, sourceTable == tableView {
//            return .invalidDragOperation
//        }
//        
//        // Import an entire playlist from the playlist names table into either a playlist or the Play Queue.
//        return .copy
//    }
//    
//    // Performs the drop
//    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
//        
//        let destinationPlaylist = playlistsManager.userDefinedObjects[row]
//        
//        // 1 - Neither source nor destination playlist should be being modified.
//        // 2 - Cannot drag onto the same playlist.
//        
//        guard !destinationPlaylist.isBeingModified,
//              let otherTable = info.draggingSource as? NSTableView,
//              let otherTableId = otherTable.identifier,
//              let sourceIndices = info.sourceIndexes else {return false}
//        
//        switch otherTableId {
//            
//        case .tableId_playlist:
//            
//            guard let sourcePlaylist = playlistsUIState.displayedPlaylist,
//                  sourcePlaylist != destinationPlaylist,
//                  !sourcePlaylist.isBeingModified else {return false}
//            
//            importTracksFromPlaylist(sourcePlaylist, intoPlaylist: destinationPlaylist, sourceIndices: sourceIndices)
//            return true
//            
//        case .tableId_compactPlayQueue:
//
//            importTracksFromPlayQueue(intoPlaylist: destinationPlaylist, sourceIndices: sourceIndices)
//            return true
//            
//        default:
//            
//            return false
//        }
//    }
//    
//    private func importTracksFromPlaylist(_ sourcePlaylist: Playlist, intoPlaylist destinationPlaylist: Playlist, sourceIndices: IndexSet) {
//        destinationPlaylist.addTracks(sourcePlaylist[sourceIndices])
//    }
//    
//    private func importTracksFromPlayQueue(intoPlaylist destinationPlaylist: Playlist, sourceIndices: IndexSet) {
//        
//        let destinationIndices = destinationPlaylist.addTracks(playQueue[sourceIndices])
//        
//        if destinationPlaylist == playlistsUIState.displayedPlaylist {
//            messenger.publish(PlaylistTracksAddedNotification(playlistName: destinationPlaylist.name, trackIndices: destinationIndices))
//        }
//    }
//}
