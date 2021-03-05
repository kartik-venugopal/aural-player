import Cocoa

class Bookmark: StringKeyedItem {
    
    // A name or description (e.g. "2nd chapter of audiobook")
    private var _name: String
    
    // Used by the UI (track.displayName)
    var name: String {
        
        get {
            self.track?.displayName ?? _name
        }
        
        set(newValue) {
            _name = newValue
        }
    }
    
    var key: String {
        
        get {
            return name
        }
        
        set(newValue) {
            name = newValue
        }
    }
    
    // The file of the track being bookmarked
    let file: URL
    
    var track: Track?
    
    // TODO: What if the same bookmarked file is now shorter than the startPosition or endPosition ???
    // Playback of the bookmark will fail. Handle this scenario with an error/warning message.
    
    // Seek position within track, expressed in seconds
    let startPosition: Double
    
    // Seek position within track, expressed in seconds
    let endPosition: Double?
    
    convenience init(_ name: String, _ file: URL, _ startPosition: Double) {
        self.init(name, file, startPosition, nil)
    }
    
    init(_ name: String, _ file: URL, _ startPosition: Double, _ endPosition: Double?) {
        
        self._name = name
        self.file = file
        self.startPosition = startPosition
        self.endPosition = endPosition
    }
    
    init(_ name: String, _ track: Track, _ startPosition: Double, _ endPosition: Double?) {
        
        self._name = name
        self.track = track
        self.file = track.file
        self.startPosition = startPosition
        self.endPosition = endPosition
    }
}
