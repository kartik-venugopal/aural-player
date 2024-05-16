//
//  UnifiedPlayerSidebarViewController+DataSource.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension UnifiedPlayerSidebarViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if item == nil {
            return unifiedPlayerUIState.sidebarItems.count
            
        } else if let sidebarItem = item as? UnifiedPlayerSidebarItem {
            return sidebarItem.childItems.count
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {
            return unifiedPlayerUIState.sidebarItems[index]
            
        } else if let sidebarItem = item as? UnifiedPlayerSidebarItem {
            return sidebarItem.childItems[index]
        }
        
        return ""
    }
    
    // MARK: Drag and drop
    
    // Writes source information to the pasteboard
    func outlineView(_ outlineView: NSOutlineView, writeItems items: [Any], to pasteboard: NSPasteboard) -> Bool {
        false
//        guard let sidebarItems = items as? [UnifiedPlayerSidebarItem] else {return false}
//        
//        // We can only copy file system folders and playlists.
//        let filteredItems = sidebarItems.filter {$0.browserTab.equalsOneOf(.fileSystem, .playlists)}
//        guard filteredItems.isNonEmpty else {return false}
//        
//        TableDragDropContext.setData(filteredItems, from: sidebarView, pasteboard: pasteboard)
//        return true
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
