//
//  TracksPlaylistViewDataSource.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Data source for the NSTableView that displays the "Tracks" (flat) playlist view.
 */
class TracksPlaylistViewDataSource: NSObject, NSTableViewDataSource {
    
    // Delegate that relays accessor operations to the playlist
    private let playlist: PlaylistDelegateProtocol = objectGraph.playlistDelegate
    
    // Signifies an invalid drag/drop operation
    private let invalidDragOperation: NSDragOperation = []
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {playlist.size}
    
    // MARK: Drag n drop
    
    // Writes source information to the pasteboard
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pasteboard: NSPasteboard) -> Bool {
        
        if playlist.isBeingModified {return false}
        pasteboard.sourceIndexes = rowIndexes
        
        return true
    }
    
    // Validates the proposed drag/drop operation
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        
        if playlist.isBeingModified {return invalidDragOperation}
        
        // If the source is the tableView, that means playlist tracks are being reordered
        if info.draggingSource is NSTableView {
            
            // Reordering of tracks
            if let sourceIndexSet = info.sourceIndexes,
               validateReorderOperation(tableView, sourceIndexSet, row, dropOperation) {
                
                return .move
            }
            
            return invalidDragOperation
        }
        
        // TODO: What about items added from apps other than Finder ??? From VOX or other audio players ???
        
        // Otherwise, files are being dragged in from outside the app (e.g. tracks/playlists from Finder)
        return .copy
    }
    
    // Given source indexes, a destination index (dropRow), and the drop operation (on/above), determines if the drop is a valid reorder operation (depending on the bounds of the playlist, and the source and destination indexes)
    private func validateReorderOperation(_ tableView: NSTableView, _ sourceIndexSet: IndexSet, _ dropRow: Int, _ operation: NSTableView.DropOperation) -> Bool {
        
        // If all rows are selected, they cannot be moved, and dropRow cannot be one of the source rows
        return operation == .above && (sourceIndexSet.count < tableView.numberOfRows) && !sourceIndexSet.contains(dropRow)
    }
    
    // Performs the drop
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        
        if playlist.isBeingModified {return false}
        
        if info.draggingSource is NSTableView {
            
            if let sourceIndices = info.sourceIndexes,
                let results = playlist.dropTracks(sourceIndices, row).results as? [TrackMoveResult] {
                
                let sortedMoves = results.filter({$0.movedDown}).sorted(by: ItemMoveResult.compareDescending) +
                    results.filter({$0.movedUp}).sorted(by: ItemMoveResult.compareAscending)
                
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
                }
                
                // Select all the destination rows (the new locations of the moved tracks).
                tableView.selectRows(destinationIndices)
                
                return true
            }
            
        } else if let files = info.urls {
            
            // Files added from Finder, add them to the playlist as URLs
            playlist.addFiles(files)
            return true
        }
        
        return false
    }
}
