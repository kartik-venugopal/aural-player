//
//  SearchQuery.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all the criteria for a playlist search.
///
class SearchQuery {
    
    var text: String = ""
    var scope: SearchScope = .playQueue
    var type: SearchType = .contains
    var fields: SearchFields = .all
    var options: SearchOptions = .none
    
    var noFieldsSelected: Bool {fields.isEmpty}
    
    var noQueryText: Bool {text == ""}
    
    var queryPossible: Bool {!(noFieldsSelected || noQueryText)}
    
    // Helper function that compares the value of a single field to the search text to determine if there is a match
    func compare(_ fieldValue: String) -> Bool {
        
        let caseSensitive: Bool = options.contains(.caseSensitive)
        let queryText: String = caseSensitive ? text : text.lowercased()
        let compared: String = caseSensitive ? fieldValue : fieldValue.lowercased()
        
        switch type {
            
        case .beginsWith: return compared.hasPrefix(queryText)
            
        case .endsWith: return compared.hasSuffix(queryText)
            
        case .equals: return compared == queryText
            
        case .contains: return compared.contains(queryText)
            
        case .matchesRegex: return compared.matches(regex: queryText)
            
        }
    }
}
