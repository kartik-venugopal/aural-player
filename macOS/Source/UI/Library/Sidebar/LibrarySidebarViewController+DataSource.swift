//
//  LibrarySidebarViewController+DataSource.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension LibrarySidebarViewController: NSOutlineViewDataSource {

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if item == nil {
            return categories.count
            
        } else if let sidebarCat = item as? LibrarySidebarCategory {
            return sidebarCat.numberOfItems
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {
            return categories[index]
            
        } else if let sidebarCat = item as? LibrarySidebarCategory {
            return sidebarCat.items[index]
        }
        
        return ""
    }
    
    // MARK: Drag and drop
    
    // Writes source information to the pasteboard
    func outlineView(_ outlineView: NSOutlineView, writeItems items: [Any], to pasteboard: NSPasteboard) -> Bool {
        
        guard let sidebarItems = items as? [LibrarySidebarItem] else {return false}
        
        // We can only copy file system folders and playlists.
        let filteredItems = sidebarItems.filter {$0.browserTab == .fileSystem}
        guard filteredItems.isNonEmpty else {return false}
        
        TableDragDropContext.setData(filteredItems, from: sidebarView, pasteboard: pasteboard)
        return true
    }
    
    // Validates the drag/drop operation
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        
        // Check if dragging from this sidebar view.
        if let sourceTable = info.draggingSource as? NSOutlineView, sourceTable === sidebarView {
            
            // TODO: Allow 1 - drag from playlists into another playlist, 2 - drag from playlists into library, 3 - favorites -> library / playlist
            // 4 - history -> library / playlist
        }

        // TODO: Remove this dummy code
        return .invalidDragOperation
    }
    
    // Performs the drop
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        
        TableDragDropContext.reset()
        
        // TODO: Allow 1 - drag from playlists into another playlist, 2 - drag from playlists into library, 3 - favorites -> library / playlist
        
        // TODO: Remove this dummy code
        return false
    }
}
