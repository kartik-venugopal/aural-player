//
//  TrackComparators.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

typealias TrackComparator = (Track, Track) -> Bool

let trackArtistAlbumDiscTrackNumberComparator: TrackComparator = TrackListSort(fields: [.artist, .album, .discNumberAndTrackNumber], order: .ascending).comparator

let trackNameAscendingComparator: TrackComparator = {t1, t2 in
    trackNameComparison(t1, t2) == .orderedAscending
}

let trackNameDescendingComparator: TrackComparator = {t1, t2 in
    trackNameComparison(t1, t2) == .orderedDescending
}

let trackTitleAscendingComparator: TrackComparator = {t1, t2 in
    trackTitleComparison(t1, t2) == .orderedAscending
}

let trackTitleDescendingComparator: TrackComparator = {t1, t2 in
    trackTitleComparison(t1, t2) == .orderedDescending
}

let trackFileNameAscendingComparator: TrackComparator = {t1, t2 in
    trackFileNameComparison(t1, t2) == .orderedAscending
}

let trackFileNameDescendingComparator: TrackComparator = {t1, t2 in
    trackFileNameComparison(t1, t2) == .orderedDescending
}

let trackArtistAscendingComparator: TrackComparator = {t1, t2 in
    trackArtistComparison(t1, t2) == .orderedAscending
}

let trackArtistDescendingComparator: TrackComparator = {t1, t2 in
    trackArtistComparison(t1, t2) == .orderedDescending
}

let trackAlbumAscendingComparator: TrackComparator = {t1, t2 in
    trackAlbumComparison(t1, t2) == .orderedAscending
}

let trackAlbumDescendingComparator: TrackComparator = {t1, t2 in
    trackAlbumComparison(t1, t2) == .orderedDescending
}

let trackGenreAscendingComparator: TrackComparator = {t1, t2 in
    trackGenreComparison(t1, t2) == .orderedAscending
}

let trackGenreDescendingComparator: TrackComparator = {t1, t2 in
    trackGenreComparison(t1, t2) == .orderedDescending
}

let trackNumberAscendingComparator: TrackComparator = {t1, t2 in
    trackNumberComparison(t1, t2) == .orderedAscending
}

let trackNumberDescendingComparator: TrackComparator = {t1, t2 in
    trackNumberComparison(t1, t2) == .orderedDescending
}

let trackDiscNumberAscendingComparator: TrackComparator = {t1, t2 in
    trackDiscNumberComparison(t1, t2) == .orderedAscending
}

let trackDiscNumberDescendingComparator: TrackComparator = {t1, t2 in
    trackDiscNumberComparison(t1, t2) == .orderedDescending
}

let trackDiscAndTrackNumberAscendingComparator: TrackComparator = {t1, t2 in
    trackDiscAndTrackNumberComparison(t1, t2) == .orderedAscending
}

let trackDiscAndTrackNumberDescendingComparator: TrackComparator = {t1, t2 in
    trackDiscAndTrackNumberComparison(t1, t2) == .orderedDescending
}

let trackAlbumDiscAndTrackNumberAscendingComparator: TrackComparator = {t1, t2 in
    trackAlbumDiscAndTrackNumberComparison(t1, t2) == .orderedAscending
}

let trackAlbumDiscAndTrackNumberDescendingComparator: TrackComparator = {t1, t2 in
    trackAlbumDiscAndTrackNumberComparison(t1, t2) == .orderedDescending
}

let trackDurationAscendingComparator: TrackComparator = {t1, t2 in
    trackDurationComparison(t1, t2) == .orderedAscending
}

let trackDurationDescendingComparator: TrackComparator = {t1, t2 in
    trackDurationComparison(t1, t2) == .orderedDescending
}

let trackLastModifiedTimeAscendingComparator: TrackComparator = {t1, t2 in
    trackLastModifiedTimeComparison(t1, t2) == .orderedAscending
}

let trackLastModifiedTimeDescendingComparator: TrackComparator = {t1, t2 in
    trackLastModifiedTimeComparison(t1, t2) == .orderedDescending
}

let trackYearAscendingComparator: TrackComparator = {t1, t2 in
    trackYearComparison(t1, t2) == .orderedAscending
}

let trackYearDescendingComparator: TrackComparator = {t1, t2 in
    trackYearComparison(t1, t2) == .orderedDescending
}

func comparisonToAscendingTrackComparator(_ comparison: @escaping TrackComparison) -> TrackComparator {
    
    {t1, t2 in
        comparison(t1, t2) == .orderedAscending
    }
}

func comparisonToDescendingTrackComparator(_ comparison: @escaping TrackComparison) -> TrackComparator {
    
    {t1, t2 in
        comparison(t1, t2) == .orderedDescending
    }
}

// MARK: Group comparator

//typealias GroupComparator = (Group, Group) -> Bool
//
//let groupNameAscendingComparator: GroupComparator = {g1, g2 in
//    groupNameComparison(g1, g2) == .orderedAscending
//}
//
//let groupNameDescendingComparator: GroupComparator = {g1, g2 in
//    groupNameComparison(g1, g2) == .orderedDescending
//}
//
//let groupDurationAscendingComparator: GroupComparator = {g1, g2 in
//    groupDurationComparison(g1, g2) == .orderedAscending
//}
//
//let groupDurationDescendingComparator: GroupComparator = {g1, g2 in
//    groupDurationComparison(g1, g2) == .orderedDescending
//}
//
//func comparisonToAscendingGroupComparator(_ comparison: @escaping GroupComparison) -> GroupComparator {
//    
//    {g1, g2 in
//        comparison(g1, g2) == .orderedAscending
//    }
//}
//
//func comparisonToDescendingGroupComparator(_ comparison: @escaping GroupComparison) -> GroupComparator {
//    
//    {g1, g2 in
//        comparison(g1, g2) == .orderedDescending
//    }
//}
