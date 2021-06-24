//
//  PlaylistViewState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

// Convenient accessor for information about the current playlist view
class PlaylistViewState {
    
    // The current playlist view type displayed within the playlist tab group
    static var currentView: PlaylistType = .tracks
    
    // The current playlist view displayed within the playlist tab group
    static weak var currentTableView: NSTableView!
    
    static weak var chaptersListView: NSTableView!
    
    // The playlist view that was clicked. Will be nil initially.
    private static weak var _clickedView: NSTableView?
    
    // The playlist item that was clicked. Will be nil initially.
    private static var _clickedItem: SelectedPlaylistItem?
    
    static var selectedRowView: NSView? {
        
        if let theClickedView = _clickedView {
            return theClickedView.rowView(atRow: theClickedView.selectedRow, makeIfNecessary: false)
        }
        
        return nil
    }
    
    // Exposed to outside callers (should never be nil). Should only be accessed subsequent to calling noteViewClicked().
    static var clickedItem: SelectedPlaylistItem? {_clickedItem}
    
    static var hasSelectedChapter: Bool {chaptersListView.selectedRow >= 0}
    
    // The group type corresponding to the current playlist view type
    static var groupType: GroupType? {currentView.toGroupType()}
    
    static var selectedItem: SelectedPlaylistItem? {
        
        // Determine which item was clicked, and what kind of item it is
        if let outlineView = currentTableView as? AuralPlaylistOutlineView {
            
            // Grouping view
            let item = outlineView.item(atRow: outlineView.selectedRow)
            
            if let group = item as? Group {
                return SelectedPlaylistItem(group: group)
                
            } else if let track = item as? Track {
                // Track
                return SelectedPlaylistItem(track: track)
            }
            
            return nil
            
        } else {
            
            // Tracks view
            return currentTableView.selectedRow >= 0 ? SelectedPlaylistItem(index: currentTableView.selectedRow) : nil
        }
    }
    
    static var selectedItemCount: Int {currentTableView.numberOfSelectedRows}
    
    static var selectedItems: [SelectedPlaylistItem] {
        
        let selectedRows = currentTableView.selectedRowIndexes
        var items: [SelectedPlaylistItem] = []
        
        if let outlineView = currentTableView as? AuralPlaylistOutlineView {
            
            // Grouping view
            for item in selectedRows.compactMap({outlineView.item(atRow: $0)}) {
                
                if let group = item as? Group {
                    items.append(SelectedPlaylistItem(group: group))
                    
                } else if let track = item as? Track {
                    // Track
                    items.append(SelectedPlaylistItem(track: track))
                }
            }
            
        } else {    // Tracks view
            
            items = selectedRows.map {SelectedPlaylistItem(index: $0)}
        }
        
        return items
    }
    
    /*
        When a playlist view is clicked, notes and keeps track of which view was clicked, and which row in that view was clicked.
     
        NOTE - This function should only be called when the playlist is non-empty (i.e. has at least one row). This is assumed by the code inside this function.
     */
    static func registerTableViewClick(_ view: NSTableView) {
        
        _clickedView = view
        
        // Determine which item was clicked, and what kind of item it is
        if let outlineView = _clickedView as? AuralPlaylistOutlineView {
            
            // Grouping view
            let item = outlineView.item(atRow: outlineView.selectedRow)
            
            if let group = item as? Group {
                _clickedItem = SelectedPlaylistItem(group: group)
                
            } else if let track = item as? Track {
                _clickedItem = SelectedPlaylistItem(track: track)
            }
            
        } else if let theClickedView = _clickedView {
            
            // Tracks view (or chapters list)
            _clickedItem = theClickedView.selectedRow >= 0 ? SelectedPlaylistItem(index: theClickedView.selectedRow) : nil
        }
    }
}

// Encapsulates information about a playlist item that was clicked
struct SelectedPlaylistItem {
    
    var type: SelectedItemType
    
    // Only one of these will be non-nil, depending on the type of item
    var index: Int?
    var track: Track?
    var group: Group?
    
    // Initialize the object with a track index or a track chapter.
    init(index: Int) {
        
        self.index = index
        self.type = .index
    }
    
    // Initialize the object with a track. This represents an item from a grouping/hierarchical playlist.
    init(track: Track) {
        
        self.track = track
        self.type = .track
    }
    
    // Initialize the object with a group. This represents an item from a grouping/hierarchical playlist.
    init(group: Group) {
        
        self.group = group
        self.type = .group
    }
}

// Enumerates the different types of playlist items (in terms of their location within the playlist)
enum SelectedItemType {
    
    case index
    case track
    case group
}

class PlaylistViewDefaults {
    
    static let currentView: PlaylistType = .tracks
}
