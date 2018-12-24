import Cocoa

class Bookmark: StringKeyedItem, PlayableItem {
    
    // A name or description (e.g. "2nd chapter of audiobook")
    private var _name: String
    
    // Used by the UI (track.conciseDisplayName)
    var name: String {
        
        get {
            
            if let track = self.track {
                return track.conciseDisplayName
            }
            
            return _name
        }
        
        set(newValue) {
            _name = newValue
        }
    }
    
    // The file of the track being bookmarked
    let file: URL
    
    var track: Track?
    
    // Seek position within track, expressed in seconds
    let startPosition: Double
    
    // Seek position within track, expressed in seconds
    let endPosition: Double?
    
    // Display information used in menu items
    var art: NSImage = Images.imgPlayedTrack
    
    var key: String {return name}
    
    convenience init(_ name: String, _ file: URL, _ startPosition: Double) {
        self.init(name, file, startPosition, nil)
    }
    
    init(_ name: String, _ file: URL, _ startPosition: Double, _ endPosition: Double?) {
        
        self._name = name
        self.file = file
        self.startPosition = startPosition
        self.endPosition = endPosition
        
//        loadArtworkFromFile()
    }
    
    init(_ name: String, _ track: Track, _ startPosition: Double, _ endPosition: Double?) {
        
        self._name = name
        self.track = track
        self.file = track.file
        self.startPosition = startPosition
        self.endPosition = endPosition
        
//        loadArtworkFromFile()
    }
    
    // Loads display information (name and art) from the filesystem file
    private func loadArtworkFromFile() {
        
        // Load display info (async) from disk. This is done during app startup, and hence can and should be done asynchronously. It is not required immediately.
        
         // TODO: Temporarily disabled
//        DispatchQueue.global(qos: .background).async {
//            
//            if let artwork = MetadataUtils.loadArtworkForFile(self.file) {
//                self.art = artwork.copy() as! NSImage
//            }
//        }
    }
    
    func validateFile() -> Bool {
        return FileSystemUtils.fileExists(file)
    }
}
