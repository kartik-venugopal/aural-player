import Cocoa

class FilterChart: NSView {
    
    var bandsDataFunction: (() -> [FilterBand]) = {() -> [FilterBand] in return []}
    var filterUnitStateFunction: (() -> EffectsUnitState) = {() -> EffectsUnitState in return .active}
    
<<<<<<< HEAD:Aural/FilterChart.swift
    private let bandStopColor: NSColor = NSColor(calibratedRed: 1, green: 0, blue: 0, alpha: 1)
    private let bandPassColor: NSColor = NSColor(calibratedRed: 0, green: 0.8, blue: 0, alpha: 1)
=======
    var bandStopColor: NSColor = Colors.Effects.bypassedUnitStateColor
    var bandPassColor: NSColor = Colors.Effects.activeUnitStateColor
>>>>>>> upstream/master:Source/UI/Effects/Filter/FilterChart.swift
    
    var inactiveUnitGradient: NSGradient {
        return Colors.Effects.defaultSliderBackgroundGradient
    }
    
<<<<<<< HEAD:Aural/FilterChart.swift
    private let bandStopGradient: NSGradient = {
        
        let start = NSColor(red: 0.8, green: 0, blue: 0, alpha: 1)
        let end =  NSColor(red: 0.6, green: 0, blue: 0, alpha: 1)
        let gradient = NSGradient(starting: start, ending: end)
        
        return gradient!
    }()
    
    private let bandPassGradient: NSGradient = {
        
        let start = NSColor(red: 0, green: 0.7, blue: 0, alpha: 1)
        let end =  NSColor(red: 0, green: 0.5, blue: 0, alpha: 1)
        let gradient = NSGradient(starting: start, ending: end)
        
        return gradient!
    }()
=======
    var bandStopGradient: NSGradient {
        return Colors.Effects.bypassedSliderGradient
    }
    
    var bandPassGradient: NSGradient {
        return Colors.Effects.activeSliderGradient
    }
    
    var backgroundColor: NSColor {
        return Colors.windowBackgroundColor
    }
    
    var textColor: NSColor {
        return Colors.filterChartTextColor
    }
>>>>>>> upstream/master:Source/UI/Effects/Filter/FilterChart.swift
    
    override func draw(_ dirtyRect: NSRect) {
        
        let unitState: EffectsUnitState = filterUnitStateFunction()
        
        var drawPath = NSBezierPath.init(rect: dirtyRect)
<<<<<<< HEAD:Aural/FilterChart.swift
        Colors.windowBackgroundColor.setFill()
=======
        backgroundColor.setFill()
>>>>>>> upstream/master:Source/UI/Effects/Filter/FilterChart.swift
        drawPath.fill()
        
        let offset: CGFloat = 0
        let width = self.frame.width - 2 * offset
        let height = self.frame.height
        let scale: CGFloat = width / 3
        let bottomMargin: CGFloat = 0
        
        let frameRect: NSRect = NSRect(x: offset, y: bottomMargin, width: width, height: height / 2)
        
<<<<<<< HEAD:Aural/FilterChart.swift
=======
        drawPath = NSBezierPath.init(rect: frameRect)
        NSColor.lightGray.setStroke()
        drawPath.lineWidth = 0.5
        drawPath.stroke()
        
>>>>>>> upstream/master:Source/UI/Effects/Filter/FilterChart.swift
        // Draw bands
        let bands = bandsDataFunction()
        
        for band in bands {
            
            switch band.type {
                
            case .bandPass, .bandStop:
            
                let min = band.minFreq!
                let max = band.maxFreq!
                
                let x1 = log10(min/2) - 1
                let x2 = log10(max/2) - 1
                
                let rx1 = offset + CGFloat(x1) * scale
                let rx2 = offset + CGFloat(x2) * scale
                
                let col = unitState == .active ? (band.type == .bandStop ? bandStopGradient : bandPassGradient) : inactiveUnitGradient
                
                let brect = NSRect(x: rx1, y: bottomMargin + 1, width: rx2 - rx1, height: (height / 2) - 2)
                drawPath = NSBezierPath.init(rect: brect)
                
                col.draw(in: drawPath, angle: UIConstants.verticalGradientDegrees)
                
            case .lowPass:
                
                let f = band.maxFreq!
                let x = log10(f/2) - 1
                let lineWidth: CGFloat = 2
                let rx = min(offset + CGFloat(x) * scale, frameRect.maxX - lineWidth / 2)
                
                if unitState == .active {
                
                    GraphicsUtils.drawVerticalLine(bandPassGradient, pt1: NSPoint(x: rx - lineWidth / 2, y: bottomMargin + 1), pt2: NSPoint(x: rx - lineWidth / 2, y: bottomMargin + (height / 2) - 2), width: lineWidth)
                    
                    GraphicsUtils.drawVerticalLine(bandStopGradient, pt1: NSPoint(x: rx + lineWidth / 2, y: bottomMargin + 1), pt2: NSPoint(x: rx + lineWidth / 2, y: bottomMargin + (height / 2) - 2), width: lineWidth)
                    
                } else {
                    
                    GraphicsUtils.drawVerticalLine(inactiveUnitGradient, pt1: NSPoint(x: rx, y: bottomMargin + 1), pt2: NSPoint(x: rx, y: bottomMargin + (height / 2) - 2), width: lineWidth)
                }
                
            case .highPass:
                
                let f = band.minFreq!
                let x = log10(f/2) - 1
                let lineWidth: CGFloat = 2
                let rx = min(offset + CGFloat(x) * scale, frameRect.maxX - lineWidth / 2)
                
                if unitState == .active {
                    
                    GraphicsUtils.drawVerticalLine(bandStopGradient, pt1: NSPoint(x: rx - lineWidth / 2, y: bottomMargin + 1), pt2: NSPoint(x: rx - lineWidth / 2, y: bottomMargin + (height / 2) - 2), width: lineWidth)
                    
                    GraphicsUtils.drawVerticalLine(bandPassGradient, pt1: NSPoint(x: rx + lineWidth / 2, y: bottomMargin + 1), pt2: NSPoint(x: rx + lineWidth / 2, y: bottomMargin + (height / 2) - 2), width: lineWidth)
                    
                } else {
                    
                    GraphicsUtils.drawVerticalLine(inactiveUnitGradient, pt1: NSPoint(x: rx, y: bottomMargin + 1), pt2: NSPoint(x: rx, y: bottomMargin + (height / 2) - 2), width: lineWidth)
                }
            }
        }
        
        drawPath = NSBezierPath.init(rect: frameRect)
        Colors.filterChartTextColor.setStroke()
        drawPath.stroke()
        
        // Draw X-axis markings
        let xMarks: [CGFloat] = [31, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
        let textFont: NSFont = FontSchemes.systemScheme.effects.filterChartFont
        
        for y in xMarks {

            let x = log10(y/2) - 1
            let sx = offset + x * scale

            var text: String
            let intY: Int = Int(y)
            if intY % 1000 == 0 {
                text = String(format: "%dk", intY / 1000)
            } else {
                text = String(describing: intY)
            }
            
            let tw = StringUtils.sizeOfString(text, textFont)
            let tx = offset + x * scale - tw.width / 2
            
            let trect = NSRect(x: tx, y: bottomMargin + height / 2 + 2, width: tw.width + 10, height: 15)
            
            GraphicsUtils.drawTextInRect(trect, text, textColor, textFont)
            
            if (sx != offset && sx != offset + width) {
<<<<<<< HEAD:Aural/FilterChart.swift
                GraphicsUtils.drawLine(Colors.fxFunctionTextColor, pt1: NSPoint(x: sx, y: bottomMargin), pt2: NSPoint(x: sx, y: bottomMargin + height / 2 - 8), width: 1.5)
                GraphicsUtils.drawLine(Colors.fxFunctionTextColor, pt1: NSPoint(x: sx, y: bottomMargin + height / 2 + 8), pt2: NSPoint(x: sx, y: bottomMargin + height), width: 1.5)
=======
                
                GraphicsUtils.drawLine(NSColor.gray, pt1: NSPoint(x: sx, y: bottomMargin + height / 2), pt2: NSPoint(x: sx, y: bottomMargin + height / 2 + 5), width: 1.5)
>>>>>>> upstream/master:Source/UI/Effects/Filter/FilterChart.swift
            }
        }
    }
}

class FilterPreviewChart: FilterChart {
    
    override func awakeFromNib() {
        
        bandStopColor = Colors.Effects.defaultBypassedUnitColor
        bandPassColor = Colors.Effects.defaultActiveUnitColor
    }
    
    override var inactiveUnitGradient: NSGradient {
        return Colors.Effects.defaultSliderBackgroundGradient
    }
    
    override var bandStopGradient: NSGradient {
        return Colors.Effects.defaultBypassedSliderGradient
    }
    
    override var bandPassGradient: NSGradient {
        return Colors.Effects.defaultActiveSliderGradient
    }
    
    override var backgroundColor: NSColor {
        return NSColor.black
    }
    
    override var textColor: NSColor {
        return NSColor.white
    }
}
