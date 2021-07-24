//
//  FilterChart.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FilterChart: NSView {
    
    private let fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    
    var bandsDataFunction: (() -> [FilterBand]) = {[]}
    var filterUnitStateFunction: EffectsUnitStateFunction = {.active}
    
    var inactiveUnitGradient: NSGradient {
        Colors.Effects.defaultSliderBackgroundGradient
    }
    
    var bandStopGradient: NSGradient {
        Colors.Effects.bypassedSliderGradient
    }
    
    var bandPassGradient: NSGradient {
        Colors.Effects.activeSliderGradient
    }
    
    var backgroundColor: NSColor {
        Colors.windowBackgroundColor
    }
    
    var textFont: NSFont {
        fontSchemesManager.systemScheme.effects.filterChartFont
    }
    
    var textColor: NSColor {
        Colors.Effects.functionCaptionTextColor
    }
    
    private let offset: CGFloat = 5
    private let bottomMargin: CGFloat = 5
    private let lineWidth: CGFloat = 2
    
    private let xMarks: [CGFloat] = [31, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
    
    override func draw(_ dirtyRect: NSRect) {
        
        let unitState: EffectsUnitState = filterUnitStateFunction()
        
        var drawPath = NSBezierPath(rect: dirtyRect)
        drawPath.fill(withColor: backgroundColor)
        
        let width = self.width - 2 * offset
        let height = self.height - 10
        let scale: CGFloat = width / 3
        
        let frameRect: NSRect = NSRect(x: offset, y: bottomMargin, width: width, height: height / 2)
        
        drawPath = NSBezierPath(rect: frameRect)
        drawPath.stroke(withColor: .lightGray, lineWidth: 0.5)
        
        // Draw bands
        let bands = bandsDataFunction()
        
        for band in bands {
            
            switch band.type {
                
            case .bandPass, .bandStop:
                
                guard let min = band.minFreq, let max = band.maxFreq else {continue}
                
                let x1 = log10(min/2) - 1
                let x2 = log10(max/2) - 1
                
                let rx1 = offset + CGFloat(x1) * scale
                let rx2 = offset + CGFloat(x2) * scale
                
                let gradient = unitState == .active ? (band.type == .bandStop ? bandStopGradient : bandPassGradient) : inactiveUnitGradient
                
                let brect = NSRect(x: rx1, y: bottomMargin + 1, width: rx2 - rx1, height: (height / 2) - 2)
                drawPath = NSBezierPath(rect: brect)
                
                gradient.draw(in: drawPath, angle: .verticalGradientDegrees)
                
            case .lowPass:
                
                guard let f = band.maxFreq else {continue}
                
                let x = log10(f/2) - 1
                let rx = min(offset + CGFloat(x) * scale, frameRect.maxX - lineWidth / 2)
                
                if unitState == .active {
                
                    GraphicsUtils.drawVerticalLine(bandPassGradient, pt1: NSPoint(x: rx - lineWidth / 2, y: bottomMargin + 1), pt2: NSPoint(x: rx - lineWidth / 2, y: bottomMargin + (height / 2) - 2), width: lineWidth)
                    
                    GraphicsUtils.drawVerticalLine(bandStopGradient, pt1: NSPoint(x: rx + lineWidth / 2, y: bottomMargin + 1), pt2: NSPoint(x: rx + lineWidth / 2, y: bottomMargin + (height / 2) - 2), width: lineWidth)
                    
                } else {
                    
                    GraphicsUtils.drawVerticalLine(inactiveUnitGradient, pt1: NSPoint(x: rx, y: bottomMargin + 1), pt2: NSPoint(x: rx, y: bottomMargin + (height / 2) - 2), width: lineWidth)
                }
                
            case .highPass:
                
                guard let f = band.minFreq else {continue}
                
                let x = log10(f/2) - 1
                let rx = min(offset + CGFloat(x) * scale, frameRect.maxX - lineWidth / 2)
                
                if unitState == .active {
                    
                    GraphicsUtils.drawVerticalLine(bandStopGradient, pt1: NSPoint(x: rx - lineWidth / 2, y: bottomMargin + 1), pt2: NSPoint(x: rx - lineWidth / 2, y: bottomMargin + (height / 2) - 2), width: lineWidth)
                    
                    GraphicsUtils.drawVerticalLine(bandPassGradient, pt1: NSPoint(x: rx + lineWidth / 2, y: bottomMargin + 1), pt2: NSPoint(x: rx + lineWidth / 2, y: bottomMargin + (height / 2) - 2), width: lineWidth)
                    
                } else {
                    
                    GraphicsUtils.drawVerticalLine(inactiveUnitGradient, pt1: NSPoint(x: rx, y: bottomMargin + 1), pt2: NSPoint(x: rx, y: bottomMargin + (height / 2) - 2), width: lineWidth)
                }
            }
        }
        
        // Draw X-axis markings
        
        for y in xMarks {

            let x = log10(y/2) - 1
            let sx = offset + x * scale

            let intY: Int = Int(y)

            let text: String
            if intY % 1000 == 0 {
                text = String(format: "%dk", intY / 1000)
            } else {
                text = String(describing: intY)
            }
            
            let tw = text.size(withFont: textFont).width
            let tx = offset + (x * scale) - (tw / 2)
            
            let trect = NSRect(x: tx, y: bottomMargin + height / 2 + 2, width: tw + 10, height: 15)
            text.draw(in: trect, withFont: textFont, andColor: textColor)
            
            if (sx != offset && sx != offset + width) {
                
                GraphicsUtils.drawLine(.gray, pt1: NSPoint(x: sx, y: bottomMargin + height / 2), pt2:
                                        NSPoint(x: sx, y: bottomMargin + height / 2 + 5), width: 1.5)
            }
        }
    }
}
