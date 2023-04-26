//
//  NSRectPersistentState.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// A persistent representation of an **NSRect** object.
///
struct NSRectPersistentState: Codable {
    
    static let zero: NSRectPersistentState = .init(rect: .zero)

    let origin: NSPointPersistentState?
    let size: NSSizePersistentState?
    
    init(rect: NSRect) {
        
        self.origin = NSPointPersistentState(point: rect.origin)
        self.size = NSSizePersistentState(size: rect.size)
    }
    
    func toNSRect() -> NSRect? {
    
        guard let origin = self.origin?.toNSPoint(), let size = self.size?.toNSSize() else {return nil}
        return NSRect(origin: origin, size: size)
    }
}
