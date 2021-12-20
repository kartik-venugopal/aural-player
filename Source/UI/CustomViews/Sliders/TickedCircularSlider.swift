import Cocoa

struct CircularSliderTick {
    
    let value: Float
    let angleDegrees: CGFloat
    let perimeterPoint: NSPoint
}

@IBDesignable
class TickedCircularSlider: NSControl, EffectsUnitSliderProtocol {
    
    override func awakeFromNib() {
        
        self.enable()

        center = NSPoint(x: frame.width / 2, y: frame.height / 2)
        radius = self.width / 2
        computeTicks()
        
        setValue(allowedValues.lowerBound)
    }
    
    var unitState: EffectsUnitState = .bypassed {
        didSet {redraw()}
    }
    
    var stateFunction: (() -> EffectsUnitState)?
    
    func updateState() {
        
        if let function = stateFunction {
            
            unitState = function()
            redraw()
        }
    }
    
    override var integerValue: Int {
        didSet {redraw()}
    }
    
    func setValue(_ value: Int) {
        setValue(Float(value))
    }
    
    func setValue(_ value: Float) {
        
        let tick = snapValueToTick(value)
        perimeterPoint = tick.perimeterPoint
        
        self.floatValue = tick.value
        self.integerValue = roundedInt(self.floatValue)
    }
    
    @IBInspectable var minValue: Float = 0 {
        didSet {allowedValues = minValue...maxValue}
    }
    
    @IBInspectable var maxValue: Float = 100 {
        didSet {allowedValues = minValue...maxValue}
    }
    
    @IBInspectable var interval: Float = 1
    
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
    
    var backgroundColor: NSColor {Colors.Effects.sliderBackgroundColor}

    var foregroundColor: NSColor {
        
        switch unitState {
            
        case .active:
            
            return Colors.Effects.activeUnitStateColor
            
        case .bypassed:
            
            return Colors.Effects.bypassedUnitStateColor
            
        case .suppressed:
            
            return Colors.Effects.suppressedUnitStateColor
        }
    }
    
    var ticks: [CircularSliderTick] = []
    
    private func computeTicks() {
        
        ticks.removeAll()
        
        for val in stride(from: minValue, through: maxValue, by: interval) {
            ticks.append(computeTick(value: val))
        }
    }
    
    private func computeTick(value: Float) -> CircularSliderTick {

        let angle = CGFloat(computeAngle(value: value))
        let perimeterPoint = convertAngleDegreesToPerimeterPoint(angle)
        
        return CircularSliderTick(value: value, angleDegrees: angle, perimeterPoint: perimeterPoint)
    }
    
    private func snapAngleToTick(_ angle: CGFloat) -> CircularSliderTick {
        
        var minDistance: CGFloat = 10000
        var snapTick: CircularSliderTick!
        
        for tick in ticks {
            
            let distance = abs(angle - tick.angleDegrees)
            if distance < minDistance {
                
                minDistance = distance
                snapTick = tick
                
            } else if distance > minDistance {
                break
            }
        }
        
        return snapTick
    }
    
    private func snapValueToTick(_ value: Float) -> CircularSliderTick {
        
        var minDistance: Float = 10000
        var snapTick: CircularSliderTick!
        
        for tick in ticks {
            
            let distance = abs(value - tick.value)
            if distance < minDistance {
                
                minDistance = distance
                snapTick = tick
                
            } else if distance > minDistance {
                break
            }
        }
        
        return snapTick
    }

    private func computeAngle(value: Float) -> Float {

        let percentage = (value - minValue) * 100 / (maxValue - minValue)
        return percentage * 2.7
    }

    private func computeValue(angle: CGFloat) -> Float {
        return Float(CGFloat(minValue) + (angle * CGFloat(maxValue - minValue) / 270.0))
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        // Clear any previously added sublayers (otherwise, previously drawn arcs will remain)
        layer?.sublayers?.removeAll()
        
        let circlePath = NSBezierPath(ovalIn: dirtyRect.insetBy(dx: 0, dy: 0))

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.CGPath

        shapeLayer.fillColor = backgroundColor.cgColor
        shapeLayer.strokeColor = NSColor.clear.cgColor

        shapeLayer.rasterizationScale = 2.0 * NSScreen.main!.backingScaleFactor
        shapeLayer.shouldRasterize = true

        self.layer?.addSublayer(shapeLayer)
        
        // ------------------------ ARC ----------------------------
                
        let angleForMin = 225 - computeAngle(value: allowedValues.lowerBound)
        let angleForMax = 225 - computeAngle(value: allowedValues.upperBound)
        
        let arcPath = NSBezierPath()
        arcPath.appendArc(withCenter: center, radius: radius - 2, startAngle: CGFloat(angleForMin), endAngle: CGFloat(angleForMax), clockwise: true)

        let arcLayer = CAShapeLayer()
        arcLayer.path = arcPath.CGPath

        arcLayer.fillColor = NSColor.clear.cgColor
        arcLayer.strokeColor = foregroundColor.cgColor
        arcLayer.lineWidth = 3

        arcLayer.rasterizationScale = 2.0 * NSScreen.main!.backingScaleFactor
        arcLayer.shouldRasterize = true

        self.layer?.addSublayer(arcLayer)
        
        // ------------------------ LINE ----------------------------
        
        let line = NSBezierPath() // container for line(s)
        line.move(to: center) // start point
        line.line(to: perimeterPoint) // destination
        
        let fgLayer = CAShapeLayer()
        fgLayer.path = line.CGPath
            
        fgLayer.fillColor = NSColor.clear.cgColor
        fgLayer.strokeColor = foregroundColor.cgColor
        fgLayer.lineWidth = 2.0
            
        self.layer?.addSublayer(fgLayer)
        
        // --------------------- DIMMING WHEN DISABLED ----------------
        
        if self.isDisabled {

            let dimPath = NSBezierPath(ovalIn: dirtyRect.insetBy(dx: 0, dy: 0))

            let dimLayer = CAShapeLayer()
            dimLayer.path = dimPath.CGPath

            dimLayer.fillColor = NSColor(white: 0, alpha: 0.7).cgColor
            dimLayer.rasterizationScale = 2.0 * NSScreen.main!.backingScaleFactor
            dimLayer.shouldRasterize = true

            self.layer?.addSublayer(dimLayer)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        
        if self.isEnabled {
            computeValueForClick(loc: self.convert(event.locationInWindow, from: nil))
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        
        if self.isEnabled {
            computeValueForClick(loc: self.convert(event.locationInWindow, from: nil))
        }
    }
    
    private func computeValueForClick(loc: NSPoint) {
     
        let dx = center.x - loc.x
        let dy = center.y - loc.y
        
        let xSign: CGFloat = dx == 0 ? 1 : dx / abs(dx)
        let ySign: CGFloat = dy == 0 ? 1 : dy / abs(dy)
        
        let angleRads = ySign > 0 ? min(atan((dy * ySign) / (dx * xSign)), 45 * CGFloat.pi / 180) : atan((dy * ySign) / (dx * xSign))
        
        let correctedAngle: CGFloat = convertAngleRadsToAngleDegrees(angleRads, xSign, ySign)
        let tick = snapAngleToTick(correctedAngle)
        perimeterPoint = tick.perimeterPoint
        
        let val = computeValue(angle: tick.angleDegrees)
        
        if val > allowedValues.upperBound {
            
            perimeterPoint = ticks.filter {$0.value == allowedValues.upperBound}.first!.perimeterPoint
            self.floatValue = allowedValues.upperBound
            
        } else if val < allowedValues.lowerBound {
            
            perimeterPoint = ticks.filter {$0.value == allowedValues.lowerBound}.first!.perimeterPoint
            self.floatValue = allowedValues.lowerBound
            
        } else {
            
            self.floatValue = val
        }
        
        self.integerValue = roundedInt(self.floatValue)
        
        sendAction(self.action, to: self.target)
    }
    
    private func convertAngleRadsToAngleDegrees(_ rads: CGFloat, _ xSign: CGFloat, _ ySign: CGFloat) -> CGFloat {
        
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
    
    private func convertAngleDegreesToPerimeterPoint(_ angle: CGFloat) -> NSPoint {
        
        let radius = self.radius - 5
        
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

/*
    Some global Math-related functions
 */

// Rounds and converts a Float -> Int
func roundedInt(_ floatVal: Float) -> Int {
    return lroundf(floatVal)
}

// Rounds and converts a Double -> Int
func roundedInt(_ doubleVal: Double) -> Int {
    return lround(doubleVal)
}

// Floors and converts a Float -> Int
func floorInt(_ floatVal: Float) -> Int {
    return Int(floorf(floatVal))
}

// Floors and converts a Double -> Int
func floorInt(_ doubleVal: Double) -> Int {
    return Int(floor(doubleVal))
}
