import Cocoa

class Favorite: StringKeyedItem {
    
    // The file of the track being favorited
    let file: URL
    
    private var _name: String
    
    // Used by the UI (track.displayName)
    var name: String {
        
        get {
            self.track?.displayName ?? _name
        }
        
        set {
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
        self._name = track.displayName
    }
    
    init(_ file: URL, _ name: String) {
        
        self.file = file
        self._name = name
    }
}
