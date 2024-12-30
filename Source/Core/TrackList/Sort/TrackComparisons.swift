//
//  TrackComparisons.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

typealias TrackComparison = (Track, Track) -> ComparisonResult

let trackNameComparison: TrackComparison = {t1, t2 in
    t1.titleOrDefaultDisplayName.compare(t2.titleOrDefaultDisplayName)
}

let trackTitleComparison: TrackComparison = {t1, t2 in
    (t1.title ?? "zz").compare(t2.title ?? "zz")
}

let trackFileNameComparison: TrackComparison = {t1, t2 in
    t1.fileName.compare(t2.fileName)
}

let trackArtistComparison: TrackComparison = {t1, t2 in
    (t1.artist ?? "zz").compare(t2.artist ?? "zz")
}

let trackAlbumComparison: TrackComparison = {t1, t2 in
    (t1.album ?? "zz").compare(t2.album ?? "zz")
}

let trackGenreComparison: TrackComparison = {t1, t2 in
    (t1.genre ?? "zz").compare(t2.genre ?? "zz")
}

let trackNumberComparison: TrackComparison = {t1, t2 in
    (t1.trackNumber ?? -1).compare(t2.trackNumber ?? -1)
}

let trackDiscNumberComparison: TrackComparison = {t1, t2 in
    (t1.discNumber ?? -1).compare(t2.discNumber ?? -1)
}

let trackDiscAndTrackNumberComparison: TrackComparison = {t1, t2 in
    
    let compositeFunction = chainTrackComparisons(trackDiscNumberComparison, trackNumberComparison)
    return compositeFunction(t1, t2)
}

let trackAlbumDiscAndTrackNumberComparison: TrackComparison = {t1, t2 in
    
    let compositeFunction = chainTrackComparisons(trackAlbumComparison, trackDiscAndTrackNumberComparison)
    return compositeFunction(t1, t2)
}

let trackDurationComparison: TrackComparison = {t1, t2 in
    (t1.duration).compare(t2.duration)
}

let trackLastModifiedTimeComparison: TrackComparison = {t1, t2 in
    
    let time1 = t1.file.lastModifiedTime
    let time2 = t2.file.lastModifiedTime
    
    if let theTime1 = time1, let theTime2 = time2 {
        return theTime1.compare(theTime2)
    }
    
    if time1 == nil && time2 == nil {
        return .orderedSame
    }
    
    if time1 == nil {
        return .orderedAscending
    }
    
    return .orderedDescending
}

func chainTrackComparisons(_ c1: @escaping TrackComparison, _ c2: @escaping TrackComparison) -> TrackComparison {

    {t1, t2 in

        if c1(t1, t2) == .orderedSame {
            return c2(t1, t2)
        } else {
            return c1(t1, t2)
        }
    }
}

func chainTrackComparisonsToAscendingComparator(_ c1: @escaping TrackComparison, _ c2: @escaping TrackComparison) -> TrackComparator {
    comparisonToAscendingTrackComparator(chainTrackComparisons(c1, c2))
}

func chainTrackComparisonsToDescendingComparator(_ c1: @escaping TrackComparison, _ c2: @escaping TrackComparison) -> TrackComparator {
    comparisonToDescendingTrackComparator(chainTrackComparisons(c1, c2))
}

// MARK: Group comparison

//typealias GroupComparison = (Group, Group) -> ComparisonResult

//let groupNameComparison: GroupComparison = {g1, g2 in
//    (g1.name).compare(g2.name)
//}
//
//let groupDurationComparison: GroupComparison = {g1, g2 in
//    (g1.duration).compare(g2.duration)
//}
//
//func chainGroupComparisons(_ c1: @escaping GroupComparison, _ c2: @escaping GroupComparison) -> GroupComparison {
//
//    {g1, g2 in
//
//        if c1(g1, g2) == .orderedSame {
//            return c2(g1, g2)
//        } else {
//            return c1(g1, g2)
//        }
//    }
//}
