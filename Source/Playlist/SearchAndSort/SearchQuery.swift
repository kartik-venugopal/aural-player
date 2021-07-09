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
    var fields: SearchFields = .all
    var options: SearchOptions = SearchOptions()
    
    var noFieldsSelected: Bool {fields.isEmpty}
    
    var noQueryText: Bool {text == ""}
    
    var queryPossible: Bool {!(noFieldsSelected || noQueryText)}
    
    func withText(_ text: String) -> SearchQuery {
        
        self.text = text
        return self
    }
    
    func withFields(_ fields: SearchFields) -> SearchQuery {
        
        self.fields = fields
        return self
    }
    
    func withOptions(_ options: SearchOptions) -> SearchQuery {
        
        self.options = options
        return self
    }
    
    func withType(_ type: SearchType) -> SearchQuery {
        
        self.type = type
        return self
    }
    
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
