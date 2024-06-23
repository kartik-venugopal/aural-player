//
//  NSSizePersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// A persistent representation of an **NSSize** object.
///
struct NSSizePersistentState: Codable {
    
    let width: CGFloat?
    let height: CGFloat?
    
    init(size: NSSize) {
        
        self.width = size.width
        self.height = size.height
    }
    
    func toNSSize() -> NSSize? {
        
        guard let width = self.width, let height = self.height else {return nil}
        return NSMakeSize(width, height)
    }
}
