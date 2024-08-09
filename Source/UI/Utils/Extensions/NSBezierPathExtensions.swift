//
//  NSBezierPathExtensions.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

public extension NSBezierPath {
    
    convenience init(lineFrom pt1: NSPoint, to pt2: NSPoint) {
        
        self.init()
        move(to: pt1)
        line(to: pt2)
    }

    var cgPath: CGPath {

        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)

        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)

            switch type {
            case .moveTo: path.move(to: CGPoint(x: points[0].x, y: points[0].y) )
            case .lineTo: path.addLine(to: CGPoint(x: points[0].x, y: points[0].y) )
            case .curveTo: path.addCurve(      to: CGPoint(x: points[2].x, y: points[2].y),
                                               control1: CGPoint(x: points[0].x, y: points[0].y),
                                               control2: CGPoint(x: points[1].x, y: points[1].y) )
            case .closePath: path.closeSubpath()
                
            case .cubicCurveTo, .quadraticCurveTo:
                break
                
            @unknown default:
                NSLog("Encountered unknown CGPath element type:" + String(describing: type))
            }
        }
        
        return path
    }
    
    func fill(withColor color: NSColor) {
        
        color.setFill()
        self.fill()
    }
    
    func stroke(withColor color: NSColor, lineWidth: CGFloat? = nil) {
        
        color.setStroke()
        
        if let width = lineWidth {
            self.lineWidth = width
        }
        
        self.stroke()
    }
    
    ///
    /// A convenience function to draw a line between 2 points specified as tuples of ``CGFloat``.
    ///
    /// Performs 2 distinct steps:
    ///
    /// - Move to the ``from`` point.
    /// - Draw a line to the ``to`` point.
    ///
    func line(from: (x: CGFloat, y: CGFloat), to: (x: CGFloat, y: CGFloat)) {
        
        move(to: CGPoint(x: from.x, y: from.y))
        line(to: CGPoint(x: to.x, y: to.y))
    }
    
    static func fillRoundedRect(_ rect: NSRect, radius: CGFloat, withColor color: NSColor) {
        NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill(withColor: color)
    }
    
    static func strokeRoundedRect(_ rect: NSRect, radius: CGFloat, withColor color: NSColor, lineWidth: CGFloat = 1) {
        
        let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
        color.setStroke()
        
        path.lineWidth = lineWidth
        path.stroke()
    }
    
    static func fillOval(in rect: NSRect, withColor color: NSColor) {
        NSBezierPath(ovalIn: rect).fill(withColor: color)
    }
    
    static func fillRoundedRect(_ rect: NSRect, radius: CGFloat, withGradient gradient: NSGradient, angle: CGFloat) {
        
        let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
        gradient.draw(in: path, angle: angle)
    }
    
    // ------------------------------------------------------------------------------

    // MARK: Initializers / functions
    
    ///
    /// Convenience initializer to create an ``NSBezierPath`` with the given
    /// rounded rectangle and corner radius.
    ///
    convenience init(roundedRect: NSRect, cornerRadius: CGFloat) {
        self.init(roundedRect: roundedRect, xRadius: cornerRadius, yRadius: cornerRadius)
    }
}
