//
//  SearchOptions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

///
/// Additional options to further filter playlist search results.
///
struct SearchOptions: OptionSet {
    
    let rawValue: Int
    
    static let caseSensitive = SearchOptions(rawValue: 1 << 0)
    
    static let none: SearchOptions = []
    static let all: SearchOptions = [caseSensitive]
}
