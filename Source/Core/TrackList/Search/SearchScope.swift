//
//  SearchScope.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct SearchScope: OptionSet {
    
    let rawValue: Int
    let description: String
    
    static let playQueue = SearchScope(rawValue: 1 << 0, description: "Play Queue")
    static let library = SearchScope(rawValue: 1 << 1, description: "Library")
    static let fileSystem = SearchScope(rawValue: 1 << 2, description: "File System")
    
    static let all: SearchScope = [playQueue, library, fileSystem]
    
    init(rawValue: Int) {
        self.rawValue = rawValue
        self.description = ""
    }
    
    init(rawValue: Int, description: String) {
        
        self.rawValue = rawValue
        self.description = description
    }
}
