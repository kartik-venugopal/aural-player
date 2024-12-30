//
//  SortField.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

///
/// An enumeration of fields that can be used as playlist sort criteria.
///
enum TrackSortField {
    
    case name
    case title
    case fileName
    case duration
    case artist
    case album
    case genre
    case trackNumber
    case discNumberAndTrackNumber
    case fileLastModifiedTime
    case year
    case playCount
    case format
    
    var comparison: TrackComparison {
        
        switch self {
            
        case .name:
            return trackNameComparison
            
        case .title:
            return trackTitleComparison
            
        case .fileName:
            return trackFileNameComparison
            
        case .artist:
            return trackArtistComparison
            
        case .album:
            return trackAlbumComparison
            
        case .genre:
            return trackGenreComparison
            
        case .trackNumber:
            return trackNumberComparison
            
        case .discNumberAndTrackNumber:
            return trackDiscAndTrackNumberComparison
            
        case .duration:
            return trackDurationComparison
            
        case .fileLastModifiedTime:
            return trackLastModifiedTimeComparison
            
        case .year:
            return trackYearComparison
            
        case .playCount:
            return trackPlayCountComparison
            
        case .format:
            return trackFormatComparison
        }
    }
    
    func comparator(withOrder order: SortOrder) -> TrackComparator {
        
        switch self {
            
        case .name:
            
            return order == .ascending ? trackNameAscendingComparator : trackNameDescendingComparator
            
        case .title:
            
            return order == .ascending ? trackTitleAscendingComparator : trackTitleDescendingComparator
            
        case .fileName:
            
            return order == .ascending ? trackFileNameAscendingComparator : trackFileNameDescendingComparator
            
        case .artist:
            
            return order == .ascending ? trackArtistAscendingComparator : trackArtistDescendingComparator
            
        case .album:
            
            return order == .ascending ? trackAlbumAscendingComparator : trackAlbumDescendingComparator
            
        case .genre:
            
            return order == .ascending ? trackGenreAscendingComparator : trackGenreDescendingComparator
            
        case .trackNumber:
            
            return order == .ascending ? trackNumberAscendingComparator : trackNumberDescendingComparator
            
        case .discNumberAndTrackNumber:
            
            return order == .ascending ? trackDiscAndTrackNumberAscendingComparator : trackDiscAndTrackNumberDescendingComparator
            
        case .duration:
            
            return order == .ascending ? trackDurationAscendingComparator : trackDurationDescendingComparator
            
        case .fileLastModifiedTime:
            
            return order == .ascending ? trackLastModifiedTimeAscendingComparator : trackLastModifiedTimeDescendingComparator
            
        case .year:
            
            return order == .ascending ? trackYearAscendingComparator : trackYearDescendingComparator
            
        case .playCount:
            
            return order == .ascending ? trackPlayCountAscendingComparator : trackPlayCountDescendingComparator
            
        case .format:
            
            return order == .ascending ? trackFormatAscendingComparator : trackFormatDescendingComparator
        }
    }
}

//enum GroupSortField {
//    
//    case name
//    case duration
//    
//    var comparison: GroupComparison {
//        
//        switch self {
//            
//        case .name:
//            
//            return groupNameComparison
//            
//        case .duration:
//            
//            return groupDurationComparison
//        }
//    }
//    
//    func comparator(withOrder order: SortOrder) -> GroupComparator {
//        
//        switch self {
//            
//        case .name:
//            
//            return order == .ascending ? groupNameAscendingComparator : groupNameDescendingComparator
//            
//        case .duration:
//            
//            return order == .ascending ? groupDurationAscendingComparator : groupDurationDescendingComparator
//        }
//    }
//}
