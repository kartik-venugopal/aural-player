//
//  DiscreteCircularSlider+Support.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import AppKit

extension DiscreteCircularSlider {
    
    override func mouseDown(with event: NSEvent) {
        
        if self.isEnabled {
            computeValueForClick(loc: convert(event.locationInWindow, from: nil))
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        
        if self.isEnabled {
            computeValueForClick(loc: convert(event.locationInWindow, from: nil))
        }
    }
    
    func snapAngleToTick(_ angle: CGFloat) -> CircularSliderTick {
        
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
    
    func snapValueToTick(_ value: Float) -> CircularSliderTick {
        
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

    func computeAngle(value: Float) -> Float {

        let percentage = (value - minValue) * 100 / (maxValue - minValue)
        return percentage * 2.7
    }

    func computeValue(angle: CGFloat) -> Float {
        return Float(CGFloat(minValue) + (angle * CGFloat(maxValue - minValue) / 270.0))
    }
    
    func computeValueForClick(loc: NSPoint) {
     
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
        
        self.integerValue = self.floatValue.roundedInt
        
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
        
        let radius = self.radius - 10
        
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
