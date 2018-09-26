import Cocoa

class Bookmark: StringKeyedItem, PlayableItem {
    
    // A name or description (e.g. "2nd chapter of audiobook")
    var name: String
    
    // The file of the track being bookmarked
    let file: URL
    
    // Seek position within track, expressed in seconds
    let position: Double
    
    // Display information used in menu items
    var art: NSImage = Images.imgPlayedTrack
    
    var key: String {return name}
    
    init(_ name: String, _ file: URL, _ position: Double) {
        
        self.name = name
        self.file = file
        self.position = position
        loadArtworkFromFile()
    }
    
    // Loads display information (name and art) from the filesystem file
    private func loadArtworkFromFile() {
        
        // Load display info (async) from disk. This is done during app startup, and hence can and should be done asynchronously. It is not required immediately.
        DispatchQueue.global(qos: .background).async {
            
            if let artwork = MetadataReader.loadArtworkForFile(self.file) {
                self.art = artwork.copy() as! NSImage
            }
        }
    }
    
    func validateFile() -> Bool {
        return FileSystemUtils.fileExists(file)
    }
}
