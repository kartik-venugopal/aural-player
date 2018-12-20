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
    
    // Used for tracks
    init(_ file: URL, _ displayName: String, _ time: Date, _ art: NSImage? = nil) {
        
        self.file = file
        self.time = time
        
        // Default the displayName to file name (intended to be replaced later)
        self.displayName = displayName
        if art != nil {
            self.art = art!
        }
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
        
        // TODO: Temporarily disabled
        DispatchQueue.global(qos: .background).async {

            if let art = MetadataReader.loadArtworkForFile(self.file) {
                self.art = art.copy() as! NSImage
            }
        }
    }
    
    func validateFile() -> Bool {
        return FileSystemUtils.fileExists(file)
    }
}

// Either a folder, audio file, or playlist file
class AddedItem: HistoryItem {
    
    init(_ file: URL, _ time: Date) {
        
        super.init(file, file.lastPathComponent, time)
        loadDisplayInfoFromFile(true)
    }
    
    init(_ file: URL, _ displayName: String, _ time: Date) {
        
        super.init(file, displayName, time)
        loadDisplayInfoFromFile(false)
    }
    
    init(_ track: Track, _ time: Date) {
        
        var trackArt: NSImage? = nil
        if let art = track.displayInfo.art {
            trackArt = art.copy() as? NSImage
        }
        super.init(track.file, track.conciseDisplayName, time, trackArt)
        
    }
    
    func loadDisplayInfoFromFile(_ setDisplayName: Bool) {
        
        // Resolve sym links and aliases
        let resolvedFileInfo = FileSystemUtils.resolveTruePath(file)
        self.file = resolvedFileInfo.resolvedURL
        
        if (resolvedFileInfo.isDirectory) {
            
            // Display name is last path component
            // Art is folder icon
            
            self.art = Images.imgGroup
            
            if setDisplayName {
                self.displayName = FileSystemUtils.getLastPathComponents(file, 3)
            }
            
        } else {
            
            // Single file - playlist or track
            let fileExtension = file.pathExtension.lowercased()
            
            if (AppConstants.SupportedTypes.playlistExtensions.contains(fileExtension)) {
                
                // Playlist
                // Display name is last path component
                // Art is playlist icon
                self.art = Images.imgHistory_playlist_padded
                
                if setDisplayName {
                    self.displayName = FileSystemUtils.getLastPathComponents(file, 3)
                }
                
            } else if (AppConstants.SupportedTypes.allAudioExtensions.contains(fileExtension)) {
                
                // Track
                super.loadDisplayInfoFromFile()
            }
        }
    }
}

// Item (track) that has been added to the Recently played list.
class PlayedItem: HistoryItem, PlayableHistoryItem {
    
    init(_ track: Track, _ time: Date) {
        
        super.init(track.file, track.conciseDisplayName, time)
        
        // If track art is available, load display info from it
        if let trackArt = track.displayInfo.art {
            self.art = trackArt.copy() as! NSImage
        }
    }

    init(_ file: URL, _ name: String, _ time: Date) {
        
        super.init(file, name, time)
        loadDisplayInfoFromFile()
    }
}
