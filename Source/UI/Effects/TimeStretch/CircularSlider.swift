//
//  CircularSlider.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

@IBDesignable
class CircularSlider: NSControl, FXUnitStateObserver {
    
    var effectsUnit: EffectsUnitProtocol!
    
    override var floatValue: Float {
        didSet {redraw()}
    }
    
    var minValue: Float {
        allowedValues.lowerBound
    }
    
    var maxValue: Float {
        allowedValues.upperBound
    }
    
    override var integerValue: Int {
        
        didSet {
            
            setValue(Float(integerValue))
            redraw()
        }
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
    
    var angleFunction: (Float, CGFloat, ClosedRange<Float>) -> CGFloat = {_, _, _ in
        0
    }
    
    var valueFunction: (CGFloat, CGFloat, ClosedRange<Float>) -> Float = {_, _, _ in
        0
    }
    
    @IBInspectable var arcWidth: CGFloat = 2 {
        didSet {redraw()}
    }
    
    @IBInspectable var lineWidth: CGFloat = 1 {
        didSet {redraw()}
    }
        
    var radius: CGFloat = 30
    var center: NSPoint = NSPoint.zero
    var perimeterPoint: NSPoint = NSPoint.zero
    
    var backgroundColor: NSColor {.black}

    var foregroundColor: NSColor {
        systemColorScheme.colorForEffectsUnitState(effectsUnit.state)
    }
    
    var ticks: [CircularSliderTick] = []
    
    func setTicks(valuesAndTolerances: [(value: Float, tolerance: Float)]) {
        
        ticks.removeAll()
        
        for valueAndTolerance in valuesAndTolerances {
            ticks.append(computeTick(valueAndTolerance: valueAndTolerance))
        }
    }
    
    private func computeTick(valueAndTolerance: (value: Float, tolerance: Float)) -> CircularSliderTick {

        let angle = CGFloat(computeAngle(value: valueAndTolerance.value))
        let perimeterPoint = convertAngleDegreesToPerimeterPoint(angle)
        
        return CircularSliderTick(value: valueAndTolerance.value, angleDegrees: angle, perimeterPoint: perimeterPoint, tolerance: valueAndTolerance.tolerance)
    }
    
    func snapValueToTick(_ value: Float) -> CircularSliderTick? {
        
        var minDistance: Float = 10000
        var snapTick: CircularSliderTick?
        
        for tick in ticks {
            
            guard let tolerance = tick.tolerance else {continue}
            
            let distance = abs(value - tick.value)
            if distance < minDistance {
                
                minDistance = distance
                if distance <= tolerance {
                    snapTick = tick
                }
                
            } else if distance > minDistance {
                break
            }
        }
        
        return snapTick
    }
    
    func setValue(_ value: Float) {
        
        let angle = computeAngle(value: value.clamped(to: minValue...maxValue))
        perimeterPoint = convertAngleDegreesToPerimeterPoint(angle)
        
        self.floatValue = value
    }
    
    override func awakeFromNib() {
        
        self.enable()
        
        center = NSPoint(x: frame.width / 2, y: frame.height / 2)
        radius = frame.width / 2
        perimeterPoint = convertAngleDegreesToPerimeterPoint(0)
        
        setValue(minValue)
    }
   
    func computeAngle(value: Float) -> CGFloat {
        angleFunction(value, arcRange, allowedValues)
    }

    func computeValue(angle: CGFloat) -> Float {
        valueFunction(angle, arcRange, allowedValues)
    }
    
    var arcStartAngle: CGFloat = 225
    var arcEndAngle: CGFloat = -45
    
    lazy var arcRange: CGFloat = arcStartAngle - arcEndAngle
    
    override func draw(_ dirtyRect: NSRect) {
        
        // Clear any previously added sublayers (otherwise, previously drawn arcs will remain)
        layer?.sublayers?.removeAll()
        
        // ------------------------ ARC ----------------------------
        
        let arcPath = NSBezierPath()
        arcPath.appendArc(withCenter: center, radius: radius - arcWidth, startAngle: arcStartAngle, endAngle: arcEndAngle, clockwise: true)

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
    }
    
    override func mouseDown(with event: NSEvent) {
        computeValueForClick(loc: self.convert(event.locationInWindow, from: nil))
    }
    
    override func mouseDragged(with event: NSEvent) {
        computeValueForClick(loc: self.convert(event.locationInWindow, from: nil))
    }
    
    func computeValueForClick(loc: NSPoint) {
        
//        let maxedOut = floatValue >= maxValue
     
        let dx = center.x - loc.x
        let dy = center.y - loc.y
        
        let xSign: CGFloat = dx == 0 ? 1 : dx / abs(dx)
        let ySign: CGFloat = dy == 0 ? 1 : dy / abs(dy)
        
        let angleRads = ySign > 0 ? min(atan((dy * ySign) / (dx * xSign)), 45 * CGFloat.pi / 180) : atan((dy * ySign) / (dx * xSign))
        
        let correctedAngle: CGFloat = convertAngleRadsToAngleDegrees(angleRads, xSign, ySign)
        let value = computeValue(angle: correctedAngle)
        
        if let tick = snapValueToTick(value) {
            
            self.floatValue = tick.value
            perimeterPoint = convertAngleDegreesToPerimeterPoint(tick.angleDegrees)
            
        } else {
            
            self.floatValue = value
            perimeterPoint = convertAngleDegreesToPerimeterPoint(correctedAngle)
        }
        
        sendAction(self.action, to: self.target)
    }
    
    func convertAngleRadsToAngleDegrees(_ rads: CGFloat, _ xSign: CGFloat, _ ySign: CGFloat) -> CGFloat {
        
        let rawAngle = rads * (180 / CGFloat.pi)
        
        if xSign > 0 && ySign > 0 {
            
            // Bottom left quadrant
            return max(0, 45 - rawAngle)
            
        } else if xSign > 0 && ySign < 0 {
            
            // Top left quadrant
            return 45 + rawAngle
            
        } else if xSign < 0 && ySign > 0 {
            
            // Bottom right quadrant
            return min(270, 225 + rawAngle)
            
        } else {
            
            // Top right quadrant
            return 225 - rawAngle
        }
    }
    
    func convertAngleDegreesToPerimeterPoint(_ angle: CGFloat) -> NSPoint {
        
        let radius = self.radius - 7
        
        if angle < 45 {
            
            let angleRads: CGFloat = (45 - angle) * CGFloat.pi / 180
            
            let ppx: CGFloat = center.x - radius * cos(angleRads)
            let ppy: CGFloat = center.y - radius * sin(angleRads)
    
            return NSPoint(x: ppx, y: ppy)
            
        } else if angle < 135 {
            
            let angleRads: CGFloat = (angle - 45) * CGFloat.pi / 180
            
            let ppx: CGFloat = center.x - radius * cos(angleRads)
            let ppy: CGFloat = center.y + radius * sin(angleRads)
    
            return NSPoint(x: ppx, y: ppy)
            
        } else if angle < 225 {
            
            let angleRads: CGFloat = (225 - angle) * CGFloat.pi / 180
            
            let ppx: CGFloat = center.x + radius * cos(angleRads)
            let ppy: CGFloat = center.y + radius * sin(angleRads)
    
            return NSPoint(x: ppx, y: ppy)
            
        } else {
            
            let angleRads: CGFloat = (angle - 225) * CGFloat.pi / 180
            
            let ppx: CGFloat = center.x + radius * cos(angleRads)
            let ppy: CGFloat = center.y - radius * sin(angleRads)
    
            return NSPoint(x: ppx, y: ppy)
        }
    }
}
