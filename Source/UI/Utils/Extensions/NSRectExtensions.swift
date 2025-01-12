//
//  NSRectExtensions.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
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
    
    static func boundingBox(of rectangles: [NSRect]) -> NSRect {
        
        guard rectangles.isNonEmpty else {return .zero}
        
        let minX = rectangles.map {$0.minX}.min() ?? 0
        let maxX = rectangles.map {$0.maxX}.max() ?? 0
        
        let minY = rectangles.map {$0.minY}.min() ?? 0
        let maxY = rectangles.map {$0.maxY}.max() ?? 0
        
        return NSMakeRect(minX, minY, maxX - minX, maxY - minY)
    }
}

extension NSPoint {
    
    func translating(_ dx: CGFloat, _ dy: CGFloat) -> NSPoint {
        self.applying(CGAffineTransform(translationX: dx, y: dy))
    }
    
    func distanceFrom(_ otherPoint: NSPoint) -> NSSize {
        
        let offsetX = self.x - otherPoint.x
        let offsetY = self.y - otherPoint.y
        
        return NSMakeSize(offsetX, offsetY)
    }
}
