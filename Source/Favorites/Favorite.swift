import Cocoa

class Favorite: MappedPreset {
    
    // The file of the track being favorited
    let file: URL
    
    private var _name: String
    
    // Used by the UI (track.displayName)
    var name: String {
        
        get {track?.displayName ?? _name}
        set {_name = newValue}
    }
    
    var key: String {
        
        get {file.path}
        set {} // Do nothing
    }
    
    var userDefined: Bool {true}
    
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
