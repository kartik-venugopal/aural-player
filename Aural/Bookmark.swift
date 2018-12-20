import Cocoa

class Bookmark: StringKeyedItem, PlayableItem {
    
    // A name or description (e.g. "2nd chapter of audiobook")
    var name: String
    
    // The file of the track being bookmarked
    let file: URL
    
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
        
        self.name = name
        self.file = file
        self.startPosition = startPosition
        self.endPosition = endPosition
        
        loadArtworkFromFile()
    }
    
    // Loads display information (name and art) from the filesystem file
    private func loadArtworkFromFile() {
        
        // Load display info (async) from disk. This is done during app startup, and hence can and should be done asynchronously. It is not required immediately.
        
         // TODO: Temporarily disabled
//        DispatchQueue.global(qos: .background).async {
//            
//            if let artwork = MetadataReader.loadArtworkForFile(self.file) {
//                self.art = artwork.copy() as! NSImage
//            }
//        }
    }
    
    func validateFile() -> Bool {
        return FileSystemUtils.fileExists(file)
    }
}
