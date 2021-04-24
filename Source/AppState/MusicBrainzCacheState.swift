import Foundation

class MusicBrainzCacheState: PersistentStateProtocol {

    let releases: [MusicBrainzCacheEntryState]?
    let recordings: [MusicBrainzCacheEntryState]?
    
    init(releases: [MusicBrainzCacheEntryState], recordings: [MusicBrainzCacheEntryState]) {
        
        self.releases = releases
        self.recordings = recordings
    }
    
    required init?(_ map: NSDictionary) {
        
        self.releases = map.arrayValue(forKey: "releases", ofType: MusicBrainzCacheEntryState.self)
        self.recordings = map.arrayValue(forKey: "recordings", ofType: MusicBrainzCacheEntryState.self)
    }
}

class MusicBrainzCacheEntryState: PersistentStateProtocol {
    
    let artist: String
    let title: String
    let file: URL
    
    init(artist: String, title: String, file: URL) {
        
        self.artist = artist
        self.title = title
        self.file = file
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let artist = map.nonEmptyStringValue(forKey: "artist"),
           let title = map.nonEmptyStringValue(forKey: "title"),
           let file = map.urlValue(forKey: "file") else {return nil}
        
        self.artist = artist
        self.title = title
        self.file = file
    }
    
//    func hash(into hasher: inout Hasher) {
//
//        hasher.combine(artist)
//        hasher.combine(title)
//        hasher.combine(file)
//    }
//
//    static func == (lhs: MusicBrainzCacheEntryState, rhs: MusicBrainzCacheEntryState) -> Bool {
//        lhs.artist == rhs.artist && lhs.title == rhs.title && lhs.file == rhs.file
//    }
}

extension MusicBrainzCache: PersistentModelObject {
    
    var persistentState: MusicBrainzCacheState {
        
        var releases: [MusicBrainzCacheEntryState] = []
        var recordings: [MusicBrainzCacheEntryState] = []
        
        for (artist, title, file) in self.onDiskReleasesCache.entries {
             releases.append(MusicBrainzCacheEntryState(artist: artist, title: title, file: file))
        }
        
        for (artist, title, file) in self.onDiskRecordingsCache.entries {
            recordings.append(MusicBrainzCacheEntryState(artist: artist, title: title, file: file))
        }
        
        return MusicBrainzCacheState(releases: releases, recordings: recordings)
    }
}
