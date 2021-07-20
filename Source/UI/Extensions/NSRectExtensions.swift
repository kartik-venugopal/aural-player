//
//  NSRectExtensions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

extension NSRect {
    
    var centerX: CGFloat {
        return self.minX + (self.width / 2)
    }
    
    var centerY: CGFloat {
        return self.minY + (self.height / 2)
    }
    
    var topLeftPoint: NSPoint {
        NSMakePoint(minX, maxY)
    }
    
    var topRightPoint: NSPoint {
        NSMakePoint(maxX, maxY)
    }
    
    var bottomRightPoint: NSPoint {
        NSMakePoint(maxX, minY)
    }
    
    var corners: [NSPoint] {[origin, topLeftPoint, topRightPoint, bottomRightPoint]}
    
    func fill(withColor color: NSColor) {
        
        color.setFill()
        self.fill()
    }
}

extension NSPoint {
    
    func translating(_ dx: CGFloat, _ dy: CGFloat) -> NSPoint {
        self.applying(CGAffineTransform(translationX: dx, y: dy))
    }
}
