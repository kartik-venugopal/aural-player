//
//  DiscreteCircularSlider.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

struct CircularSliderTick {
    
    let value: Float
    let angleDegrees: CGFloat
    let perimeterPoint: NSPoint
    let tolerance: Float?
}

@IBDesignable
class DiscreteCircularSlider: NSControl {
    
    var minValue: Float {
        allowedValues.lowerBound
    }
    
    var maxValue: Float {
        allowedValues.upperBound
    }
    
    @IBInspectable var interval: Float = 1
    
    @IBInspectable var arcWidth: CGFloat = 2 {
        didSet {redraw()}
    }
    
    @IBInspectable var lineWidth: CGFloat = 2 {
        didSet {redraw()}
    }
    
    override var integerValue: Int {
        didSet {redraw()}
    }
    
    var allowedValues: ClosedRange<Float> = 0...0 {
        
        didSet {
            
            if floatValue < allowedValues.lowerBound {
                setValue(allowedValues.lowerBound)
                
            } else if floatValue > allowedValues.upperBound {
                setValue(allowedValues.upperBound)
            }
            
            redraw()
        }
    }
    
    var radius: CGFloat = 30
    var center: NSPoint = NSPoint.zero
    var perimeterPoint: NSPoint = NSPoint.zero
    
    var backgroundColor: NSColor {systemColorScheme.backgroundColor}

    var foregroundColor: NSColor {
        systemColorScheme.activeControlColor
    }
    
    var ticks: [CircularSliderTick] = []
    
    override func awakeFromNib() {
        
        self.enable()

        center = NSPoint(x: frame.centerX, y: frame.centerY)
        radius = self.width / 2
        computeTicks()
        
        setValue(allowedValues.lowerBound)
    }
    
    func setValue(_ value: Int) {
        setValue(Float(value))
    }
    
    func setValue(_ value: Float) {
        
        let tick = snapValueToTick(value)
        perimeterPoint = tick.perimeterPoint
        
        self.floatValue = tick.value
        self.integerValue = self.floatValue.roundedInt
    }
    
    private func computeTicks() {
        
        ticks.removeAll()
        
        for val in stride(from: minValue, through: maxValue, by: interval) {
            ticks.append(computeTick(value: val))
        }
    }
    
    private func computeTick(value: Float) -> CircularSliderTick {

        let angle = CGFloat(computeAngle(value: value))
        let perimeterPoint = convertAngleDegreesToPerimeterPoint(angle)
        
        return CircularSliderTick(value: value, angleDegrees: angle, perimeterPoint: perimeterPoint, tolerance: nil)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        // Clear any previously added sublayers (otherwise, previously drawn arcs will remain)
        layer?.sublayers?.removeAll()
        
        // ------------------------ ARC ----------------------------
                
        let angleForMin = 225 - computeAngle(value: allowedValues.lowerBound)
        let angleForMax = 225 - computeAngle(value: allowedValues.upperBound)
        
        let arcPath = NSBezierPath()
        arcPath.appendArc(withCenter: center, radius: radius - 2, startAngle: CGFloat(angleForMin), endAngle: CGFloat(angleForMax), clockwise: true)

        let arcLayer = CAShapeLayer()
        arcLayer.path = arcPath.cgPath

        arcLayer.fillColor = NSColor.clear.cgColor
        arcLayer.strokeColor = foregroundColor.cgColor
        arcLayer.lineWidth = arcWidth

        arcLayer.rasterizationScale = 2.0 * NSScreen.main!.backingScaleFactor
        arcLayer.shouldRasterize = true

        self.layer?.addSublayer(arcLayer)
        
        // ------------------------ LINE ----------------------------
        
        let line = NSBezierPath() // container for line(s)
        line.move(to: center) // start point
        line.line(to: perimeterPoint) // destination
        
        let fgLayer = CAShapeLayer()
        fgLayer.path = line.cgPath
            
        fgLayer.fillColor = NSColor.clear.cgColor
        fgLayer.strokeColor = foregroundColor.cgColor
        fgLayer.lineWidth = lineWidth
            
        self.layer?.addSublayer(fgLayer)
        
        // --------------------- DIMMING WHEN DISABLED ----------------
        
        if self.isDisabled {

            let dimPath = NSBezierPath(ovalIn: dirtyRect.insetBy(dx: 0, dy: 0))

            let dimLayer = CAShapeLayer()
            dimLayer.path = dimPath.cgPath

            dimLayer.fillColor = NSColor(white: 0, alpha: 0.7).cgColor
            dimLayer.rasterizationScale = 2.0 * NSScreen.main!.backingScaleFactor
            dimLayer.shouldRasterize = true

            self.layer?.addSublayer(dimLayer)
        }
    }
}
