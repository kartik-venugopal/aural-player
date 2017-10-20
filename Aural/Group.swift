import Foundation

class Group {
    
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
    
    func sort() {
        
        // Sort by strategy for type
        tracks.sort(by: GroupSortStrategies.byAlbumAndTrackNumber)
    }
}

enum GroupType {
    
    case artist
    case album
    case genre
}

class GroupSortStrategies {
    
    static var byAlbumAndTrackNumber: (Track, Track) -> Bool = {
        (track1: Track, track2: Track) -> Bool in
        
        if let a1 = track1.groupingInfo.album, let a2 = track2.groupingInfo.album {
            
            if (track1.groupingInfo.album == track2.groupingInfo.album) {
                
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
