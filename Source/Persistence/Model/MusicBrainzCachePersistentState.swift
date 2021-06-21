import Foundation

class MusicBrainzCachePersistentState: PersistentStateProtocol {

    let releases: [MusicBrainzCacheEntryPersistentState]?
    let recordings: [MusicBrainzCacheEntryPersistentState]?
    
    init(releases: [MusicBrainzCacheEntryPersistentState], recordings: [MusicBrainzCacheEntryPersistentState]) {
        
        self.releases = releases
        self.recordings = recordings
    }
    
    required init?(_ map: NSDictionary) {
        
        self.releases = map.persistentObjectArrayValue(forKey: "releases", ofType: MusicBrainzCacheEntryPersistentState.self)
        self.recordings = map.persistentObjectArrayValue(forKey: "recordings", ofType: MusicBrainzCacheEntryPersistentState.self)
    }
}

class MusicBrainzCacheEntryPersistentState: PersistentStateProtocol {
    
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
}

extension MusicBrainzCache: PersistentModelObject {
    
    var persistentState: MusicBrainzCachePersistentState {
        
        var releases: [MusicBrainzCacheEntryPersistentState] = []
        var recordings: [MusicBrainzCacheEntryPersistentState] = []
        
        for (artist, title, file) in self.onDiskReleasesCache.entries {
             releases.append(MusicBrainzCacheEntryPersistentState(artist: artist, title: title, file: file))
        }
        
        for (artist, title, file) in self.onDiskRecordingsCache.entries {
            recordings.append(MusicBrainzCacheEntryPersistentState(artist: artist, title: title, file: file))
        }
        
        return MusicBrainzCachePersistentState(releases: releases, recordings: recordings)
    }
}
