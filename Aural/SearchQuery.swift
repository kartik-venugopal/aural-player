import Cocoa

// Encapsulates the options/criteria of a playlist search
class SearchQuery {
    
    var text: String = ""
    var type: SearchType = .contains
    var fields: SearchFields = SearchFields()
    var options: SearchOptions = SearchOptions()
}

// Indicates which track fields are to be compared, in the search
class SearchFields {
    
    // By default, search by all fields
    var name: Bool = true
    var artist: Bool = true
    var title: Bool = true
    var album: Bool = true
    
    // Returns true if none of the four fields has been selected for the search
    func noFieldsSelected() -> Bool {
        return !name && !artist && !title && !album
    }
}

// Additional search options
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
