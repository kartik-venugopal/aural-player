//
//  LibraryOutlineViewController+DataSource.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension LibraryOutlineViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if item == nil {
            return grouping.numberOfGroups
        }
        
        if let group = item as? Group {
            return group.hasSubGroups ? group.subGroups.count : group.numberOfTracks
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {
            return grouping.group(at: index)
        }
        
        if let group = item as? Group {
            return (group.hasSubGroups ? group.subGroups.elements[index].value : group[index]) as Any
        }
        
        return ""
    }
    
    // MARK: Drag n Drop
    
    // Writes source information to the pasteboard
    func outlineView(_ outlineView: NSOutlineView, writeItems items: [Any], to pasteboard: NSPasteboard) -> Bool {
        
        if trackList.isBeingModified {return false}
        
        let srcRows = items.map {outlineView.row(forItem: $0)}
        pasteboard.sourceIndexes = IndexSet(srcRows)
        
        return true
    }
    
    // Validates the drag/drop operation
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        
        if trackList.isBeingModified {return .invalidDragOperation}
        
        // If the source is the outlineView, that means playlist tracks/groups are being reordered
        if let srcOutlineView = info.draggingSource as? NSOutlineView,
           srcOutlineView === self.outlineView {
            return .invalidDragOperation
        }
        
        // TODO: Drag from other tables (Play Queue, Playlist names table, Favorites, etc)
        
        // TODO: What about items added from apps other than Finder ??? From VOX or other audio players ???
        
        // Otherwise, files are being dragged in from outside the app (e.g. tracks/playlists from Finder)
        return .copy
    }
    
    // Performs the drop
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        
        if trackList.isBeingModified {return false}
        
        if let files = info.urls {
            
            // Files added from Finder, add them to the playlist as URLs
            trackList.loadTracks(from: files)
            return true
        }
        
        return false
    }
}
