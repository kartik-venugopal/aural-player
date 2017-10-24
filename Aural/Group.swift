import Foundation

class Group: NSObject, GroupedPlaylistItem {
    
    var type: GroupType
    var name: String
    var tracks: [Track] = [Track]()
    
    var duration: Double {
        
        var totalDuration: Double = 0
        tracks.forEach({totalDuration += $0.duration})
        return totalDuration
    }
    
    init(_ type: GroupType, _ name: String) {
        self.type = type
        self.name = name
    }
    
    func size() -> Int {
        return tracks.count
    }
    
    func indexOf(_ track: Track) -> Int {
        return tracks.index(of: track)!
    }
    
    func addTrack(_ track: Track) -> Int {
        
        ConcurrencyUtils.executeSynchronized(tracks) {
            tracks.append(track)
        }
//        sort()
        
        return tracks.count - 1
    }
    
    func sort() {
        
        // TODO: Sort by strategy for type
        tracks.sort(by: GroupSortStrategies.byAlbumAndTrackNumber)
    }
    
    func removeTrack(_ track: Track) -> Int {
        
        var trackIndex: Int = -1
        
        // TODO: Thread-safe ???
        ConcurrencyUtils.executeSynchronized(tracks) {
            
            if let index = tracks.index(of: track) {
                tracks.remove(at: index)
                trackIndex = index
            }
        }
        
        return trackIndex
    }
    
    func removeTrackAtIndex(_ index: Int) {
        tracks.remove(at: index)
    }
}

enum GroupType: String {
    
    case artist
    case album
    case genre
}

class GroupSortStrategies {
    
    static var byAlbumAndTrackNumber: (Track, Track) -> Bool = {
        (track1: Track, track2: Track) -> Bool in
        
        if let a1 = track1.groupingInfo.album, let a2 = track2.groupingInfo.album {
            
            if (a1 == a2) {
                
                if let d1 = track1.groupingInfo.diskNumber, let d2 = track2.groupingInfo.diskNumber {
                
                    if (d1 == d2) {
                        
                        if let n1 = track1.groupingInfo.trackNumber, let n2 = track2.groupingInfo.trackNumber {
                            return n1 < n2
                        }
                        
                    } else {
                        
                        return d1 < d2
                    }
                }
                
            } else {
               
                return a1.compare(a2) == ComparisonResult.orderedAscending
            }
        }
        
        if let t1 = track1.displayInfo.title, let t2 = track2.displayInfo.title {
            return t1.compare(t2) == ComparisonResult.orderedAscending
        }
        
        return track1.conciseDisplayName.compare(track2.conciseDisplayName) == ComparisonResult.orderedAscending
    }
}
