import Cocoa

class PlaylistViewContext {
    
    static var clickedView: NSTableView!
    
    static func getClickedItem() -> ClickedItem {
        
        if let outlineView = clickedView as? AuralPlaylistOutlineView {
            
            // Grouping view
            let item = outlineView.item(atRow: outlineView.selectedRow)
            
            if let group = item as? Group {
                return ClickedItem(group: group)
            } else {
                // Track
                return ClickedItem(track: item as! Track)
            }
        } else {
            
            // Tracks view
            return ClickedItem(index: clickedView.selectedRow)
        }
    }
}

struct ClickedItem {
    
    var type: ClickedItemType
    
    var index: Int?
    var track: Track?
    var group: Group?
    
    var description: String {
        
        switch self.type {
            
        case .index: return "Index: " + String(index!)
            
        case .track: return "Track: " + track!.conciseDisplayName
            
        case .group: return "Group: " + group!.name
            
        }
    }
    
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

enum ClickedItemType {
    
    case index
    case track
    case group
}
