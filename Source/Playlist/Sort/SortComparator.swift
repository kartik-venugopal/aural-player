//
//  SortComparator.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Utility class that encapsulates logic for different sort strategies.
///
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
            
            let comparison = doCompareGroups(aGroup, anotherGroup, groupsSort.fields[0])
            return groupsSort.order == .ascending ? comparison == .orderedAscending : comparison == .orderedDescending
        }
        
        return true
    }
    
    private func doCompareGroups(_ aGroup: Group, _ anotherGroup: Group, _ field: SortField) -> ComparisonResult {
        
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
        
            let comparison = doCompareTracks(aTrack, anotherTrack, tracksSort.fields)
            return tracksSort.order == .ascending ? comparison == .orderedAscending : comparison == .orderedDescending
        }
        
        return true
    }
    
    private func doCompareTracks(_ aTrack: Track, _ anotherTrack: Track, _ fields: [SortField]) -> ComparisonResult {
        
        for field in fields {
            
            let comparison = doCompareTracks(aTrack, anotherTrack, field)
            if comparison != .orderedSame {return comparison}
        }
        
        return .orderedSame
    }
    
    private func doCompareTracks(_ aTrack: Track, _ anotherTrack: Track, _ field: SortField) -> ComparisonResult {
        
        switch field {
            
        case .name:
            
            return trackDisplayNameFunction(aTrack).compare(trackDisplayNameFunction(anotherTrack))
            
        case .duration:
            
            return aTrack.duration.compare(anotherTrack.duration)
            
        case .artist:
            
            return compareOptionalFieldsForTracks(aTrack, anotherTrack, ({$0.artist}, ""))
            
        case .album:
            
            return compareOptionalFieldsForTracks(aTrack, anotherTrack, ({$0.album}, ""))
            
        case .discNumberAndTrackNumber:
            
            return compareOptionalFieldsForTracks(aTrack, anotherTrack, ({$0.discNumber}, 0), ({$0.trackNumber}, 0))
        }
    }
    
    typealias SortFieldValue<F> = (field: (Track) -> F?, defaultValue: F) where F: Comparable
    
    private func compareOptionalFieldsForTracks<F>(_ t1: Track, _ t2: Track, _ sortFieldValues: SortFieldValue<F>...) -> ComparisonResult where F: Comparable {
        
        let allFieldsNil: Bool = !(sortFieldValues.map {$0.field(t1)} + sortFieldValues.map {$0.field(t2)}).contains(where: {$0 != nil})
        
        if shouldUseTrackNameIfNoMetadata() && allFieldsNil {
            return doCompareTracks(t1, t2, .name)
        }
        
        // Compare fields in given order. Return the first encountered non-equal comparison result (or conclude that they are equal).
        for fieldValue in sortFieldValues {
            
            let comparison = (fieldValue.field(t1) ?? fieldValue.defaultValue).compare(fieldValue.field(t2) ?? fieldValue.defaultValue)
            if comparison != .orderedSame {return comparison}
        }
        
        return .orderedSame
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
