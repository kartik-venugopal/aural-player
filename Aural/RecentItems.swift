import Cocoa

protocol EquatableHistoryItem {
    
    func equals(_ other: EquatableHistoryItem) -> Bool
}

struct AddedItem {
    
}

class HistoryItem: EquatableHistoryItem {
    
    let file: URL
    let track: Track?
    
    var displayName: String = ""
    var art: NSImage = Images.imgPlayedTrack
    
    init(_ file: URL, _ track: Track? = nil) {
        
        self.file = file
        self.track = track
        
        if (track != nil) {
            
            // Load display info from the track
            self.displayName = track!.conciseDisplayName
            if let trackArt = track?.displayInfo.art {
                self.art = trackArt.copy() as! NSImage
            }
            
        } else {
            
            // Load display info (async) from disk
            DispatchQueue.global(qos: .background).async {
                let displayInfo = MetadataReader.loadDisplayInfoForFile(file)
                self.displayName = displayInfo.displayName
                if (displayInfo.art != nil) {
                    self.art = displayInfo.art!.copy() as! NSImage
                }
            }
        }
    }
    
    func equals(_ other: EquatableHistoryItem) -> Bool {
        
        if let otherHistoryItem = other as? HistoryItem {
            return self.file.path == otherHistoryItem.file.path
        }
        
        return false
    }
}
