import Foundation

class MusicBrainzCacheState: PersistentStateProtocol {
    
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

class MusicBrainzCacheEntryState: Hashable {
    
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
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(artist)
        hasher.combine(title)
        hasher.combine(file)
    }
    
    static func == (lhs: MusicBrainzCacheEntryState, rhs: MusicBrainzCacheEntryState) -> Bool {
        lhs.artist == rhs.artist && lhs.title == rhs.title && lhs.file == rhs.file
    }
}

extension MusicBrainzCache: PersistentModelObject {
    
    var persistentState: MusicBrainzCacheState {
        
        let state = MusicBrainzCacheState()
        
        for (artist, title, file) in self.onDiskReleasesCache.entries {
            state.releases.append(MusicBrainzCacheEntryState(artist: artist, title: title, file: file))
        }
        
        for (artist, title, file) in self.onDiskRecordingsCache.entries {
            state.recordings.append(MusicBrainzCacheEntryState(artist: artist, title: title, file: file))
        }
        
        return state
    }
}
