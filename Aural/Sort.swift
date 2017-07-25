/*
    Options for performing a sort on the playlist
 */

import Cocoa

// Encapsulates all sort options
class Sort {
    
    // By default, sort is performed by name, in ascending order
    
    var field: SortField = .name
    var order: SortOrder = .ascending
}

// Specifies which track field is used as sort criteria
enum SortField {
    
    case name
    case duration
}

// Specifies the order in which to perform the sort
enum SortOrder {
    
    case ascending
    case descending
}
