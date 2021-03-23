import Foundation

class MusicBrainzCacheState: PersistentState {
    
    var entries: [MusicBrainzCacheEntryState] = []
    
    static func deserialize(_ map: NSDictionary) -> MusicBrainzCacheState {
        
        let state =  MusicBrainzCacheState()
        
        if let entriesArr = map["entries"] as? [NSDictionary] {
            state.entries = entriesArr.compactMap {MusicBrainzCacheEntryState($0)}
        }
        
        return state
    }
}

class MusicBrainzCacheEntryState {
    
    var artist: String
    var releaseTitle: String
    var file: URL
    
    init(artist: String, releaseTitle: String, file: URL) {
        
        self.artist = artist
        self.releaseTitle = releaseTitle
        self.file = file
    }
    
    init?(_ map: NSDictionary) {
        
        let artist: String? = map["artist"] as? String
        let releaseTitle: String? = map["releaseTitle"] as? String
        var file: URL?
        
        if let filePath = map["file"] as? String {
            file = URL(fileURLWithPath: filePath)
        }
        
        if let theArtist = artist, let theReleaseTitle = releaseTitle, let theFile = file {
            
            self.artist = theArtist
            self.releaseTitle = theReleaseTitle
            self.file = theFile
            
        } else {
            return nil
        }
    }
}

extension MusicBrainzCache: PersistentModelObject {
    
    var persistentState: MusicBrainzCacheState {
        
        let state = MusicBrainzCacheState()
        
        for (artist, artistCache) in self.onDiskCache {
            
            for (releaseTitle, file) in artistCache {
                state.entries.append(MusicBrainzCacheEntryState(artist: artist, releaseTitle: releaseTitle, file: file))
            }
        }
        
        return state
    }
}
