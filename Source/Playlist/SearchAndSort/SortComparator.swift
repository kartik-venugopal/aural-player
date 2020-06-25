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
        return sort.tracksSort?.options.contains(.useNameIfNoMetadata) ?? false
    }
    
    func compareGroups(_ aGroup: Group, _ anotherGroup: Group) -> Bool {
        
        if let groupsSort = sort.groupsSort {
            
            let comparison = compareGroups(aGroup, anotherGroup, groupsSort.fields[0])
            return groupsSort.order == .ascending ? comparison == .orderedAscending : comparison == .orderedDescending
        }
        
        return true
    }
    
    private func compareGroups(_ aGroup: Group, _ anotherGroup: Group, _ field: SortField) -> ComparisonResult {
        
        switch field {
            
        case .name:
            
            return aGroup.name.compare(anotherGroup.name)
            
        case .duration:
            
            return aGroup.duration.compare(anotherGroup.duration)
            
        // Impossible
        default: return .orderedSame
            
        }
    }

    // MARK: --------- Tracks comparison --------------
    
    func compareTracks(_ aTrack: Track, _ anotherTrack: Track) -> Bool {
        
        if let tracksSort = sort.tracksSort {
        
            let comparison = compareTracks(aTrack, anotherTrack, tracksSort.fields)
            return tracksSort.order == .ascending ? comparison == .orderedAscending : comparison == .orderedDescending
        }
        
        return true
    }
    
    private func compareTracks(_ aTrack: Track, _ anotherTrack: Track, _ fields: [SortField]) -> ComparisonResult {
        return fields.map {compareTracks(aTrack, anotherTrack, $0)}.filter({$0 != .orderedSame}).first ?? .orderedSame
    }
    
    private func compareTracks(_ aTrack: Track, _ anotherTrack: Track, _ field: SortField) -> ComparisonResult {
        
        switch field {
            
        case .name:
            
            return trackDisplayNameFunction(aTrack).compare(trackDisplayNameFunction(anotherTrack))
            
        case .duration:
            
            return aTrack.duration.compare(anotherTrack.duration)
            
        case .artist:
            
            return compareOptionalFieldForTracks(aTrack, anotherTrack, {$0.groupingInfo.artist}, "")
            
        case .album:
            
            return compareOptionalFieldForTracks(aTrack, anotherTrack, {$0.groupingInfo.album}, "")
            
        case .discNumberAndTrackNumber:
            
            let discNumberComparison = compareOptionalFieldForTracks(aTrack, anotherTrack, {$0.groupingInfo.discNumber}, 0)
            
            return discNumberComparison != .orderedSame ?
                discNumberComparison :
                (aTrack.groupingInfo.trackNumber ?? 0).compare(anotherTrack.groupingInfo.trackNumber ?? 0)
        }
    }
    
    private func compareOptionalFieldForTracks<F>(_ t1: Track, _ t2: Track, _ field: (Track) -> F?, _ defaultValue: F) -> ComparisonResult where F: Comparable {
        
        let f1 = field(t1)
        let f2 = field(t2)
        
        if shouldUseTrackNameIfNoMetadata() && f1 == nil && f2 == nil {
            return compareTracks(t1, t2, .name)
        }
        
        return (f1 ?? defaultValue).compare(f2 ?? defaultValue)
    }
}

extension Comparable {
    
    func compare(_ other: Self) -> ComparisonResult {
        
        if self == other {
            return .orderedSame
        }
        
        if self < other {
            return .orderedAscending
        }
        
        return .orderedDescending
    }
}
