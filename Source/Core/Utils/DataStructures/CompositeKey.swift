//
//  CompositeKey.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct CompositeKey {
    
    let primaryKey: String
    let secondaryKey: String
}

extension CompositeKey: Hashable {
    
    static func ==(lhs: CompositeKey, rhs: CompositeKey) -> Bool {
        lhs.primaryKey == rhs.primaryKey && lhs.secondaryKey == rhs.secondaryKey
    }
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(primaryKey)
        hasher.combine(secondaryKey)
    }
}
