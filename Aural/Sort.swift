/*
    Options for performing a sort on the playlist
 */

import Cocoa

// Encapsulates all sort criteria
class Sort {
    
    // By default, sort is performed by name, in ascending order
    
    var field: SortField = .name
    var order: SortOrder = .ascending
    var options: SortOptions = SortOptions()
}

// Specifies which track field is used as sort criteria
enum SortField {
    
    case name
    case duration
    
    // For grouping playlists only
    case artist
    case album
    case discNumber
    case trackNumber
}

// Specifies the order in which to perform the sort
enum SortOrder {
    
    case ascending
    case descending
}

// Additional sort options
class SortOptions {
    
    // Whether or not the tracks within each group are to be sorted
    var sortTracksInGroups: Bool = true
}
