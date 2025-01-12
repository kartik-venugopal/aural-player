//
//  NSPointPersistentState.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import CoreGraphics

///
/// A persistent representation of an **NSPoint** object.
///
struct NSPointPersistentState: Codable {
    
    let x: CGFloat?
    let y: CGFloat?
    
    init(point: CGPoint) {
        
        self.x = point.x
        self.y = point.y
    }
    
    func toNSPoint() -> CGPoint? {
        
        guard let x = self.x, let y = self.y else {return nil}
        return CGPoint(x: x, y: y)
    }
}
