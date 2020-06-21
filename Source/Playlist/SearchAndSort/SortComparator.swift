import Foundation

// Utility class that encapsulates logic for different sort strategies
class SortComparator {
    
    let sort: Sort
    let trackDisplayNameFunction: ((Track) -> String)
    
    init(_ sort: Sort, _ trackDisplayNameFunction: @escaping ((Track) -> String)) {
        self.sort = sort
        self.trackDisplayNameFunction = trackDisplayNameFunction
    }
    
    private func shouldUseTrackNameIfNoMetadata() -> Bool {
        
        if let options = sort.tracksSort?.options {
            return options.contains(.useNameIfNoMetadata)
        }
        
        return false
    }
    
    func compareGroups(_ aGroup: Group, _ anotherGroup: Group) -> Bool {
        
        if let groupsSort = sort.groupsSort {
            
            if groupsSort.order == .ascending {
                return compareGroups(aGroup, anotherGroup, groupsSort.fields.first!) == .orderedAscending
            } else {
                return compareGroups(aGroup, anotherGroup, groupsSort.fields.first!) == .orderedDescending
            }
        }
        
        return true
    }
    
    private func compareGroups(_ aGroup: Group, _ anotherGroup: Group, _ field: SortField) -> ComparisonResult {
        
        switch field {
            
        case .name:
            
            return aGroup.name.compare(anotherGroup.name)
            
        case .duration:
            
            return compareDoubles(aGroup.duration, anotherGroup.duration)
            
        // Impossible
        default: return .orderedSame
            
        }
    }

    // MARK: --------- Tracks comparison --------------
    
    func compareTracks(_ aTrack: Track, _ anotherTrack: Track) -> Bool {
        
        if let tracksSort = sort.tracksSort {
        
            if tracksSort.order == .ascending {
                return compareTracks(aTrack, anotherTrack, tracksSort.fields) == .orderedAscending
            } else {
                return compareTracks(aTrack, anotherTrack, tracksSort.fields) == .orderedDescending
            }
        }
        
        return true
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
            
            let n1 = trackDisplayNameFunction(aTrack)
            let n2 = trackDisplayNameFunction(anotherTrack)
            
            return n1.compare(n2)
            
        case .duration:
            
            return compareDoubles(aTrack.duration, anotherTrack.duration)
            
        case .artist:
            
            if shouldUseTrackNameIfNoMetadata() && aTrack.groupingInfo.artist == nil && anotherTrack.groupingInfo.artist == nil {
                return compareTracks(aTrack, anotherTrack, .name)
            }
            
            let a1 = aTrack.groupingInfo.artist ?? ""
            let a2 = anotherTrack.groupingInfo.artist ?? ""
            return a1.compare(a2)
            
        case .album:
            
            if shouldUseTrackNameIfNoMetadata() && aTrack.groupingInfo.album == nil && anotherTrack.groupingInfo.album == nil {
                return compareTracks(aTrack, anotherTrack, .name)
            }
            
            let a1 = aTrack.groupingInfo.album ?? ""
            let a2 = anotherTrack.groupingInfo.album ?? ""
            return a1.compare(a2)
            
        case .discNumberAndTrackNumber:
            
            if shouldUseTrackNameIfNoMetadata() && aTrack.groupingInfo.discNumber == nil && anotherTrack.groupingInfo.discNumber == nil && aTrack.groupingInfo.trackNumber == nil && anotherTrack.groupingInfo.trackNumber == nil {
                
                return compareTracks(aTrack, anotherTrack, .name)
            }
            
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
    
    // TODO: compareNumbers<N>
    
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
