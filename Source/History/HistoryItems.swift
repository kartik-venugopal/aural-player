import Cocoa

// Protocol that marks a history item as being equatable (for comparison in data structures)
protocol EquatableHistoryItem {
    
    // Compares this history item to another. Returns true if the two items point to the same filesystem path, and false otherwise.
    func equals(_ other: EquatableHistoryItem) -> Bool
}

// Marker protocol that indicates a history item as being playable (i.e. if it represents a track, as opposed to a playlist file or folder)
protocol PlayableHistoryItem {}

// An abstract base class for all history items
class HistoryItem: EquatableHistoryItem {
    
    // The filesystem location of the item
    var file: URL
    
    // A timestamp used in comparisons with other items, to maintain chronological order
    var time: Date
    
    // Display information used in menu items
    private var _displayName: String
    
    var track: Track?
    
    var displayName: String {
        
        get {
            
            if let track = self.track {
                return track.defaultDisplayName
            }
            
            return _displayName
        }
        
        set(newValue) {
            self._displayName = newValue
        }
    }
    
    // Used for tracks
    init(_ file: URL, _ displayName: String, _ time: Date) {
        
        self.file = file
        self.time = time
        
        // Default the displayName to file name (intended to be replaced later)
        self._displayName = displayName
    }
    
    func equals(_ other: EquatableHistoryItem) -> Bool {
        
        if let otherHistoryItem = other as? HistoryItem {
            return self.file.path == otherHistoryItem.file.path
        }
        
        return false
    }
}

// Either a folder, audio file, or playlist file
class AddedItem: HistoryItem {
    
    // Folder or playlist added for the first time
    init(_ file: URL, _ time: Date) {
        
        super.init(file, file.lastPathComponent, time)
        loadDisplayInfoFromFile(true)
    }
    
    override init(_ file: URL, _ displayName: String, _ time: Date) {
        super.init(file, displayName, time)
    }
    
    init(_ track: Track, _ time: Date) {
        super.init(track.file, track.defaultDisplayName, time)
        self.track = track
    }
    
    func loadDisplayInfoFromFile(_ setDisplayName: Bool) {
        
        // Resolve sym links and aliases
        let resolvedFileInfo = FileSystemUtils.resolveTruePath(file)
        self.file = resolvedFileInfo.resolvedURL
        
        if (resolvedFileInfo.isDirectory) {
            
            // Display name is last path component
            // Art is folder icon
            
            if setDisplayName {
                self.displayName = FileSystemUtils.getLastPathComponents(file, 4)
            }
            
        } else {
            
            // Single file - playlist or track
            let fileExtension = file.pathExtension.lowercased()
            
            if (AppConstants.SupportedTypes.playlistExtensions.contains(fileExtension)) {
                
                // Playlist
                // Display name is last path component
                // Art is playlist icon
                if setDisplayName {
                    self.displayName = FileSystemUtils.getLastPathComponents(file, 4)
                }
            }
        }
    }
}

// Item (track) that has been added to the Recently played list.
class PlayedItem: HistoryItem, PlayableHistoryItem {
    
    init(_ track: Track, _ time: Date) {
        
        super.init(track.file, track.defaultDisplayName, time)
        self.track = track
    }
    
    override init(_ file: URL, _ displayName: String, _ time: Date) {
        super.init(file, displayName, time)
    }
}
