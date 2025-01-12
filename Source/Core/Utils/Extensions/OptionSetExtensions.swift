//
//  OptionSetExtensions.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

extension OptionSet {
    
    mutating func include(_ newMember: Element, if condition: Bool) {
        
        if condition {
            insert(newMember)
        } else {
            remove(newMember)
        }
    }
    
    func containsOneOf(_ members: Element...) -> Bool {
        members.contains(where: {self.contains($0)})
    }
}
