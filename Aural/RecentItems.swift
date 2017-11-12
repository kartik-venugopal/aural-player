import Cocoa

protocol EquatableHistoryItem {
    func equals(_ other: EquatableHistoryItem) -> Bool
}

// Marker protocol
protocol PlayableHistoryItem {}

// Intended to be abstract class
class HistoryItem: EquatableHistoryItem {
    
    var file: URL
    var displayName: String = ""
    var art: NSImage = Images.imgPlayedTrack
    
    init(_ file: URL) {
        self.file = file
    }
    
    func equals(_ other: EquatableHistoryItem) -> Bool {
        
        if let otherHistoryItem = other as? HistoryItem {
            return self.file.path == otherHistoryItem.file.path
        }
        
        return false
    }
    
    fileprivate func loadDisplayInfoFromFile() {
        
        // Load display info (async) from disk
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
    
    override init(_ file: URL) {
        
        super.init(file)
        loadDisplayInfoFromFile()
    }
    
    override func loadDisplayInfoFromFile() {
        
        // Always resolve sym links and aliases before reading the file
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

// Recently played item (track)
class PlayedItem: HistoryItem, PlayableHistoryItem {

    let track: Track?
    
    init(_ file: URL, _ track: Track? = nil) {
        
        self.track = track
        super.init(file)
        
        if (track != nil) {
            
            // Load display info from the track
            self.displayName = track!.conciseDisplayName
            if let trackArt = track?.displayInfo.art {
                self.art = trackArt.copy() as! NSImage
            }
            
        } else {

            loadDisplayInfoFromFile()
        }
    }
}

// Favorited item (track)
class FavoritesItem: PlayedItem {
}
