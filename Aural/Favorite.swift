import Cocoa

class Favorite: StringKeyedItem, PlayableItem {
    
    // The file of the track being favorited
    let file: URL
    
    // Used by the UI (track.conciseDisplayName)
    var name: String
    
    // Display information used in menu items
    var art: NSImage = Images.imgPlayedTrack
    
    var key: String {return file.path}
    
    init(_ track: Track) {
        
        self.file = track.file
        self.name = track.conciseDisplayName
        if let art = track.displayInfo.art {
            self.art = art
        }
    }
    
    init(_ file: URL, _ name: String) {
        
        self.file = file
        self.name = name
        loadDisplayInfoFromFile()
    }
    
    // Loads display information (name and art) from the filesystem file
    private func loadDisplayInfoFromFile() {
        
        // Load display info (async) from disk. This is done during app startup, and hence can and should be done asynchronously. It is not required immediately.
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
