//
//  NSRectExtensions.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
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
    
    func shrink(_ factor: CGFloat) -> NSRect {
        
        let nx = self.minX * factor
        let ny = self.minY * factor
        let nw = self.width * factor
        let nh = self.height * factor
        
        return NSRect(x: nx, y: ny, width: nw, height: nh)
    }
    
    var leftHalf: NSRect {
        NSRect(x: minX, y: minY, width: width / 2, height: height)
    }
    
    var rightHalf: NSRect {
        NSRect(x: centerX, y: minY, width: width / 2, height: height)
    }
}

extension NSPoint {
    
    func translating(_ dx: CGFloat, _ dy: CGFloat) -> NSPoint {
        self.applying(CGAffineTransform(translationX: dx, y: dy))
    }
}
