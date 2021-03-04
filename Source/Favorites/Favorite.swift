import Cocoa

class Favorite: StringKeyedItem {
    
    // The file of the track being favorited
    let file: URL
    
    private var _name: String
    
    // Used by the UI (track.defaultDisplayName)
    var name: String {
        
        get {
            
            if let track = self.track {
                return track.defaultDisplayName
            }
            
            return _name
        }
        
        set(newValue) {
            _name = newValue
        }
    }
    
    var key: String {
        
        get {
            return file.path
        }
        
        set {
            // Do nothing
        }
    }
    
    var track: Track?
    
    init(_ track: Track) {
        
        self.track = track
        self.file = track.file
        self._name = track.defaultDisplayName
    }
    
    init(_ file: URL, _ name: String) {
        
        self.file = file
        self._name = name
    }
    
    func validateFile() -> Bool {
        return FileSystemUtils.fileExists(file)
    }
}
