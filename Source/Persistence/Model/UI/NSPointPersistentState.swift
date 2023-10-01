//
//  NSPointPersistentState.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// A persistent representation of an **NSPoint** object.
///
struct NSPointPersistentState: Codable {
    
    static let zero: NSPointPersistentState = .init(point: .zero)
    
    let x: CGFloat?
    let y: CGFloat?
    
    init(point: NSPoint) {
        
        self.x = point.x
        self.y = point.y
    }
    
    func toNSPoint() -> NSPoint? {
        
        guard let x = self.x, let y = self.y else {return nil}
        return NSMakePoint(x, y)
    }
}
