import Foundation

class MusicBrainzCacheState: PersistentState {
    
    var releases: [MusicBrainzCacheEntryState] = []
    var recordings: [MusicBrainzCacheEntryState] = []
    
    static func deserialize(_ map: NSDictionary) -> MusicBrainzCacheState {
        
        let state =  MusicBrainzCacheState()
        
        if let entriesArr = map["releases"] as? [NSDictionary] {
            state.releases = entriesArr.compactMap {MusicBrainzCacheEntryState($0)}
        }
        
        if let entriesArr = map["recordings"] as? [NSDictionary] {
            state.recordings = entriesArr.compactMap {MusicBrainzCacheEntryState($0)}
        }
        
        return state
    }
}

class MusicBrainzCacheEntryState {
    
    var artist: String
    var title: String
    var file: URL
    
    init(artist: String, title: String, file: URL) {
        
        self.artist = artist
        self.title = title
        self.file = file
    }
    
    init?(_ map: NSDictionary) {
        
        if let theArtist = map["artist"] as? String,
           let theTitle = map["title"] as? String,
           let filePath = map["file"] as? String {
            
            self.artist = theArtist
            self.title = theTitle
            self.file = URL(fileURLWithPath: filePath)
            
        } else {
            return nil
        }
    }
}

extension MusicBrainzCache: PersistentModelObject {
    
    var persistentState: MusicBrainzCacheState {
        
        let state = MusicBrainzCacheState()
        
        for (artist, artistCache) in self.onDiskReleasesCache {
            
            for (title, file) in artistCache {
                state.releases.append(MusicBrainzCacheEntryState(artist: artist, title: title, file: file))
            }
        }
        
        for (artist, artistCache) in self.onDiskRecordingsCache {
            
            for (title, file) in artistCache {
                state.recordings.append(MusicBrainzCacheEntryState(artist: artist, title: title, file: file))
            }
        }
        
        return state
    }
}
