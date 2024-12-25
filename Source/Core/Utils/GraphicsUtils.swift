//
//  GraphicsUtils.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// A collection of utilities for drawing graphics.
///
class GraphicsUtils {
    
    // Draws a line between 2 points
    static func drawLine(_ color: NSColor, pt1: NSPoint, pt2: NSPoint, width: CGFloat) {
        
        let line = NSBezierPath(lineFrom: pt1, to: pt2) // container for line(s)
        line.stroke(withColor: color, lineWidth: width)
    }
    
    // Draws a line between 2 points
//    static func drawVerticalLine(_ gradient: NSGradient, pt1: NSPoint, pt2: NSPoint, width: CGFloat) {
//        
//        let rect = NSRect(x: pt1.x, y: pt1.y, width: pt2.x - pt1.x + width, height: pt2.y - pt1.y + 1)
//        gradient.draw(in: rect, angle: .verticalGradientDegrees)
//    }
    
    // Draws an arrow, from a given point (origin)
    static func drawArrow(_ color: NSColor, origin: NSPoint, dx: CGFloat, dy: CGFloat, lineWidth: CGFloat) {
        
        drawLine(color, pt1: origin, pt2: NSMakePoint(origin.x - dx, origin.y - dy), width: lineWidth)
        drawLine(color, pt1: origin, pt2: NSMakePoint(origin.x + dx, origin.y - dy), width: lineWidth)
    }
}
