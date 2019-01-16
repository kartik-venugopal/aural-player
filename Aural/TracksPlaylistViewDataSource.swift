import Cocoa

/*
    Data source for the NSTableView that displays the "Tracks" (flat) playlist view.
 */
class TracksPlaylistViewDataSource: NSObject, NSOutlineViewDataSource {
    
    // Delegate that relays accessor operations to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    // Used to determine if a track is currently playing
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    // Signifies an invalid drag/drop operation
    private let invalidDragOperation: NSDragOperation = []
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if item == nil {
            return playlist.size
        }
        
        if let track = item as? Track {
            return track.chapters.count
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil, let track = playlist.trackAtIndex(index)?.track {
            return track
        }
        
        if let track = item as? Track {
            return track.chapters[index]
        }
        
        return ""
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        
        // Only tracks with chapters are expandable
        if let track = item as? Track, !track.chapters.isEmpty {
            return true
        }
        
        return false
    }
    
}
    
    
// Indicates the type of drop operation being performed
enum DropType {
    
    // Drop on a destination row
    case on
    
    // Drop above a destination row
    case above
    
    // Converts an NSTableViewDropOperation to a DropType
    static func fromDropOperation(_ dropOp: NSTableView.DropOperation) -> DropType {
        return dropOp == .on ? .on : .above
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSPasteboardPasteboardType(_ input: String) -> NSPasteboard.PasteboardType {
	return NSPasteboard.PasteboardType(rawValue: input)
}
