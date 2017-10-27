import Foundation

class Sorts {
    
    static func compareGroups_ascendingByName(aGroup: Group, anotherGroup: Group) -> Bool {
        return aGroup.name.compare(anotherGroup.name) == ComparisonResult.orderedAscending
    }
    
    static func compareGroups_descendingByName(aGroup: Group, anotherGroup: Group) -> Bool {
        return aGroup.name.compare(anotherGroup.name) == ComparisonResult.orderedDescending
    }
    
    static func compareGroups_ascendingByDuration(aGroup: Group, anotherGroup: Group) -> Bool {
        return aGroup.duration < anotherGroup.duration
    }
    
    static func compareGroups_descendingByDuration(aGroup: Group, anotherGroup: Group) -> Bool {
        return aGroup.duration > anotherGroup.duration
    }
    
    static func compareTracks_ascendingByName(aTrack: Track, anotherTrack: Track) -> Bool {
        return aTrack.conciseDisplayName.compare(anotherTrack.conciseDisplayName) == ComparisonResult.orderedAscending
    }
    
    static func compareTracks_descendingByName(aTrack: Track, anotherTrack: Track) -> Bool {
        return aTrack.conciseDisplayName.compare(anotherTrack.conciseDisplayName) == ComparisonResult.orderedDescending
    }
    
    static func compareTracks_ascendingByDuration(aTrack: Track, anotherTrack: Track) -> Bool {
        return aTrack.duration < anotherTrack.duration
    }
    
    static func compareTracks_descendingByDuration(aTrack: Track, anotherTrack: Track) -> Bool {
        return aTrack.duration > anotherTrack.duration
    }
    
    
}
