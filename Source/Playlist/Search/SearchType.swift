//
//  SearchType.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

///
/// An enumeration of different types of text comparison when performing a playlist search.
///
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
