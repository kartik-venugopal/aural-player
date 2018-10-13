import Cocoa

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
            
            // Tracks view
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
