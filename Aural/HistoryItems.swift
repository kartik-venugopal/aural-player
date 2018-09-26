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
    var displayName: String
    var art: NSImage = Images.imgPlayedTrack
    
    init(_ file: URL, _ time: Date) {
        
        self.file = file
        self.time = time
        
        // Default the displayName to file name (intended to be replaced later)
        self.displayName = file.lastPathComponent
    }
    
    func equals(_ other: EquatableHistoryItem) -> Bool {
        
        if let otherHistoryItem = other as? HistoryItem {
            return self.file.path == otherHistoryItem.file.path
        }
        
        return false
    }
    
    // Loads display information (name and art) from the filesystem file
    fileprivate func loadDisplayInfoFromFile() {
        
        // Load display info (async) from disk. This is done during app startup, and hence can and should be done asynchronously. It is not required immediately.
        DispatchQueue.global(qos: .background).async {
            
            let displayInfo = MetadataReader.loadDisplayInfoForFile(self.file)
            self.displayName = displayInfo.displayName
            if (displayInfo.art != nil) {
                self.art = displayInfo.art!.copy() as! NSImage
            }
        }
    }
}

// Either a folder, audio file, or playlist file
class AddedItem: HistoryItem {
    
    override init(_ file: URL, _ time: Date) {
        
        super.init(file, time)
        loadDisplayInfoFromFile()
    }
    
    override func loadDisplayInfoFromFile() {
        
        // Resolve sym links and aliases
        let resolvedFileInfo = FileSystemUtils.resolveTruePath(file)
        self.file = resolvedFileInfo.resolvedURL
        
        if (resolvedFileInfo.isDirectory) {
            
            // Display name is last path component
            // Art is folder icon
            self.displayName = FileSystemUtils.getLastPathComponents(file, 3)
            self.art = Images.imgGroup
            
        } else {
            
            // Single file - playlist or track
            let fileExtension = file.pathExtension.lowercased()
            
            if (AppConstants.supportedPlaylistFileExtensions.contains(fileExtension)) {
                
                // Playlist
                // Display name is last path component
                // Art is playlist icon
                self.displayName = FileSystemUtils.getLastPathComponents(file, 3)
                self.art = Images.imgPlaylistOff
                
            } else if (AppConstants.supportedAudioFileExtensions.contains(fileExtension)) {
                
                // Track
                super.loadDisplayInfoFromFile()
            }
        }
    }
}

// Item (track) that has been added to the Recently played list.
class PlayedItem: HistoryItem, PlayableHistoryItem {

    // Optional track information. If the track was added to the Recently played list during the current app execution, this will be non-nil because a corresponding Track instance exists. Otherwise, this item will be loaded from disk as a file object (URL) upon app startup, and this Track object will be nil.
    let track: Track?
    
    init(_ file: URL, _ time: Date, _ track: Track? = nil) {
        
        self.track = track
        super.init(file, time)
        
        // If track info is available, load display info from it
        if (track != nil) {
            
            // Load display info from the track
            self.displayName = track!.conciseDisplayName
            if let trackArt = track?.displayInfo.art {
                self.art = trackArt.copy() as! NSImage
            }
            
        } else {

            // No track info available, read display info from filesystem
            loadDisplayInfoFromFile()
        }
    }
}
