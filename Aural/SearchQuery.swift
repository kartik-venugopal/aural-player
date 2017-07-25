/*
    Encapsulates the options/criteria of a search for tracks performed on the playlist
 */

import Cocoa

class SearchQuery {
    
    var text: String
    var type: SearchType = .contains
    var fields: SearchFields = SearchFields()
    var options: SearchOptions = SearchOptions()
    
    init(text: String) {
        self.text = text
    }
}

// Indicates which track fields are to be compared, in the search
class SearchFields {
    
    // By default, perform only a search by name (display name or filename without the extension)
    var name: Bool = true
    
    var artist: Bool = false
    var title: Bool = false
    var album: Bool = false
    
    // Returns true if none of the four fields has been selected for the search
    func noFieldsSelected() -> Bool {
        return !name && !artist && !title && !album
    }
}

// Search options
class SearchOptions {
    
    // Whether or not field comparisons are to be case sensitive
    // By default, searches are not case sensitive
    var caseSensitive: Bool = false
}

// Enumeration of different types of field comparison for the search
enum SearchType {
    
    // Will return results for which field values contain, as a substring, the search query text
    case contains
    
    // Will return results for which field values begin with the search query text
    case beginsWith
    
    // Will return results for which field values end with the search query text
    case endsWith
    
    // Will return results for which field values exactly match the search query text
    case equals
}
