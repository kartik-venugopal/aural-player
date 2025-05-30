//
//  CALayerExtensions.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension CAShapeLayer {
    
    ///
    /// Convenience initializer to create a ``CAShapeLayer`` with a rectangle path and fill it with a solid color.
    ///
    convenience init(fillingRect rect: CGRect, withColor color: NSColor) {
        
        self.init()
        
        self.path = NSBezierPath(rect: rect).cgPath
        self.fillColor = color.cgColor
    }
    
    ///
    /// Convenience initializer to create a ``CAShapeLayer`` with a rounded rectangle path and fill it with a solid color.
    ///
    /// - Parameter radius:     Rounding radius for the rectangle.
    ///
    convenience init(fillingRoundedRect rect: CGRect, radius: CGFloat, withColor color: NSColor) {
        
        self.init()
        
        self.path = NSBezierPath(roundedRect: rect, cornerRadius: radius).cgPath
        self.fillColor = color.cgColor
    }
}

extension CALayer {
    
    func deepCopy() -> CALayer? {
        
        try? NSKeyedUnarchiver.unarchivedObject(
                ofClass: CALayer.self,
                from: try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false))
    }
}
