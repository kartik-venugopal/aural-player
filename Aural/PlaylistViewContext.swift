import Cocoa

// Convenient accessor for information about the current playlist view
class PlaylistViewState {
    
    // The current playlist view type displayed within the playlist tab group
    static var current: PlaylistType = .tracks
    
    // The current playlist view displayed within the playlist tab group
    static var currentView: NSTableView!
    
    static var chaptersListView: NSTableView!
    
    static var textSize: TextSize = .normal
    
    static func initialize(_ appState: PlaylistUIState) {
        
        textSize = appState.textSize
        current = PlaylistType(rawValue: appState.view.lowercased()) ?? .tracks
    }
    
    static var persistentState: PlaylistUIState {
        
        let state = PlaylistUIState()
        
        state.textSize = textSize
        state.view = current.rawValue.capitalizingFirstLetter()
        
        return state
    }
    
    // The group type corresponding to the current playlist view type
    static var groupType: GroupType? {
        return current.toGroupType()
    }
    
    static var selectedItem: SelectedItem {
        
        // Determine which item was clicked, and what kind of item it is
        if let outlineView = currentView as? AuralPlaylistOutlineView {
            
            // Grouping view
            let item = outlineView.item(atRow: outlineView.selectedRow)
            
            if let group = item as? Group {
                return SelectedItem(group: group)
            } else {
                // Track
                return SelectedItem(track: item as! Track)
            }
        } else {
            
            // Tracks view
            return SelectedItem(index: currentView.selectedRow)
        }
    }
    
    static var selectedItems: [SelectedItem] {
        
        let selRows = currentView.selectedRowIndexes
        var items: [SelectedItem] = []
        
        if let outlineView = currentView as? AuralPlaylistOutlineView {
            
            // Grouping view
            for row in selRows {
                
                let item = outlineView.item(atRow: row)
                
                if let group = item as? Group {
                    items.append(SelectedItem(group: group))
                } else {
                    // Track
                    items.append(SelectedItem(track: item as! Track))
                }
            }
            
        } else {
            
            for row in selRows {
                // Tracks view
                items.append(SelectedItem(index: row))
            }
        }
        
        return items
    }
    
    static var hasSelectedChapter: Bool {
        return chaptersListView.selectedRow >= 0
    }
    
    static var selectedChapter: SelectedItem? {
        
        if chaptersListView.selectedRow >= 0 {
            return SelectedItem(index: chaptersListView.selectedRow)
        }
        
        return nil
    }
}

/*
    Utility that holds information about the currently displayed playlist view and about its current selection state when presenting a contextual menu. This is required in order to expose an NSTableView outside the scope of its owning ViewController.
 
    TODO: Merge this with PlaylistViewState
 */
class PlaylistViewContext {
    
    // The playlist view that was clicked. Will be nil initially.
    private static var _clickedView: NSTableView!
    
    // The playlist item that was clicked. Will be nil initially.
    private static var _clickedItem: SelectedItem!
    
    // Exposed to outside callers (should never be nil). Should only be accessed subsequent to calling noteViewClicked().
    static var clickedView: NSTableView {
        return _clickedView!
    }
    
    // Exposed to outside callers (should never be nil). Should only be accessed subsequent to calling noteViewClicked().
    static var clickedItem: SelectedItem {
        return _clickedItem!
    }
    
    /*
        When a playlist view is clicked, notes and keeps track of which view was clicked, and which row in that view was clicked.
     
        NOTE - This function should only be called when the playlist is non-empty (i.e. has at least one row). This is assumed by the code inside this function.
     */
    static func noteViewClicked(_ view: NSTableView) {
        
        _clickedView = view
        
        // Determine which item was clicked, and what kind of item it is
        if let outlineView = _clickedView as? AuralPlaylistOutlineView {
            
            // Grouping view
            let item = outlineView.item(atRow: outlineView.selectedRow)
            
            if let group = item as? Group {
                _clickedItem = SelectedItem(group: group)
            } else {
                // Track
                _clickedItem = SelectedItem(track: item as! Track)
            }
        } else {
            
            // Tracks view (or chapters list)
            _clickedItem = SelectedItem(index: _clickedView.selectedRow)
        }
    }
}

// Encapsulates information about a playlist item that was clicked
struct SelectedItem {
    
    var type: SelectedItemType
    
    // Only one of these will be non-nil, depending on the type of item
    var index: Int?
    var track: Track?
    var group: Group?
    
    // Initialize the object with a track index. This represents an item from the Tracks playlist.
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
