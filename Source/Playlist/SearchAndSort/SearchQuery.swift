//
//  SearchQuery.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

// Encapsulates the options/criteria of a playlist search
class SearchQuery {
    
    var text: String = ""
    var type: SearchType = .contains
    var fields: SearchFields = SearchFields()
    var options: SearchOptions = SearchOptions()
    
    var noFieldsSelected: Bool {fields.noFieldsSelected}
    
    var noQueryText: Bool {text == ""}
    
    var queryPossible: Bool {!(noFieldsSelected || noQueryText)}
    
    // Helper function that compares the value of a single field to the search text to determine if there is a match
    func compare(_ fieldValue: String) -> Bool {
        
        let caseSensitive: Bool = options.caseSensitive
        let queryText: String = caseSensitive ? text : text.lowercased()
        let compared: String = caseSensitive ? fieldValue : fieldValue.lowercased()
        
        switch type {
            
        case .beginsWith: return compared.hasPrefix(queryText)
            
        case .endsWith: return compared.hasSuffix(queryText)
            
        case .equals: return compared == queryText
            
        case .contains: return compared.contains(queryText)
            
        }
    }
}

// Indicates which track fields are to be compared, in the search
class SearchFields {
    
    // By default, search by all fields
    var name: Bool = true
    var artist: Bool = true
    var title: Bool = true
    var album: Bool = true
    
    // Returns true if none of the four fields has been selected for the search
    var noFieldsSelected: Bool {!(name || artist || title || album)}
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
