import Foundation

// Utility class that encapsulates logic for different sort strategies
class SortStrategy {
    
    let sort: Sort
    
    init(_ sort: Sort) {
        self.sort = sort
    }
    
    func compareTracks(_ aTrack: Track, _ anotherTrack: Track) -> Bool {
        
        let tracksSort = sort.tracksSort!
        
        if tracksSort.order == .ascending {
            return compareTracks(aTrack, anotherTrack, tracksSort.fields) == .orderedAscending
        } else {
            return compareTracks(aTrack, anotherTrack, tracksSort.fields) == .orderedDescending
        }
    }
    
    private func compareTracks(_ aTrack: Track, _ anotherTrack: Track, _ fields: [SortField]) -> ComparisonResult {
        
        var result: ComparisonResult = .orderedSame
        
        for field in fields {
            
            result = compareTracks(aTrack, anotherTrack, field)
            if result != .orderedSame {
                return result
            }
        }
        
        return result
    }
    
    private func compareTracks(_ aTrack: Track, _ anotherTrack: Track, _ field: SortField) -> ComparisonResult {
        
        switch field {
            
        case .name:
            
            return aTrack.conciseDisplayName.compare(anotherTrack.conciseDisplayName)
            
        case .duration:
            
            return compareDoubles(aTrack.duration, anotherTrack.duration)
            
        case .artist:
            
            let a1 = aTrack.groupingInfo.artist ?? ""
            let a2 = anotherTrack.groupingInfo.artist ?? ""
            return a1.compare(a2)
            
        case .album:
            
            let a1 = aTrack.groupingInfo.album ?? ""
            let a2 = anotherTrack.groupingInfo.album ?? ""
            return a1.compare(a2)
            
        case .discNumberAndTrackNumber:
            
            let d1 = aTrack.groupingInfo.discNumber ?? 0
            let d2 = anotherTrack.groupingInfo.discNumber ?? 0
            
            if d1 == d2 {
                
                let t1 = aTrack.groupingInfo.trackNumber ?? 0
                let t2 = anotherTrack.groupingInfo.trackNumber ?? 0
                return compareInts(t1, t2)
            }
            
            return compareInts(d1, d2)
        }
    }
    
    private func compareDoubles(_ d1: Double, _ d2: Double) -> ComparisonResult {
        
        if d1 == d2 {
            return .orderedSame
        } else if d1 < d2 {
            return .orderedAscending
        } else {
            return .orderedDescending
        }
    }
    
    private func compareInts(_ i1: Int, _ i2: Int) -> ComparisonResult {
        
        if i1 == i2 {
            return .orderedSame
        } else if i1 < i2 {
            return .orderedAscending
        } else {
            return .orderedDescending
        }
    }
}
