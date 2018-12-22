import Cocoa

class Favorite: StringKeyedItem, PlayableItem {
    
    // The file of the track being favorited
    let file: URL
    
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
    
    // Display information used in menu items
    var art: NSImage = Images.imgPlayedTrack
    
    var key: String {return file.path}
    
    var track: Track?
    
    init(_ track: Track) {
        
        self.track = track
        self.file = track.file
        self._name = track.conciseDisplayName
        if let art = track.displayInfo.art {
            self.art = art
        }
    }
    
    init(_ file: URL, _ name: String) {
        
        self.file = file
        self._name = name
//        loadDisplayInfoFromFile()
    }
    
    // Loads display information (name and art) from the filesystem file
    private func loadDisplayInfoFromFile() {
        
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
