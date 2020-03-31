import Cocoa

class FilterChart: NSView {
    
    var barRadius: CGFloat {return 1}
    var barColoredGradient: NSGradient {return Colors.neutralSliderBarColoredGradient}
    
    var bandsDataFunction: (() -> [FilterBand]) = {() -> [FilterBand] in return []}
    var filterUnitStateFunction: (() -> EffectsUnitState) = {() -> EffectsUnitState in return .active}
    
    private let bandStopColor: NSColor = NSColor(calibratedRed: 1, green: 0, blue: 0, alpha: 1)
    private let bandPassColor: NSColor = NSColor(calibratedRed: 0, green: 0.8, blue: 0, alpha: 1)
    
    private let inactiveUnitGradient: NSGradient = {
        
        let start = NSColor(calibratedWhite: 0.5, alpha: 1)
        let end = NSColor(calibratedWhite: 0.2, alpha: 1)
        let gradient = NSGradient(starting: start, ending: end)
        
        return gradient!
    }()
    
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
    
    override func draw(_ dirtyRect: NSRect) {
        
        let unitState: EffectsUnitState = filterUnitStateFunction()
        
        var drawPath = NSBezierPath.init(rect: dirtyRect)
        Colors.windowBackgroundColor.setFill()
        drawPath.fill()
        
        let offset: CGFloat = 0
        let width = self.frame.width - 2 * offset
        let height = self.frame.height
        let scale: CGFloat = width / 3
        let bottomMargin: CGFloat = 0
        
        let frameRect: NSRect = NSRect(x: offset, y: bottomMargin, width: width, height: height)
        
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
                
                let brect = NSRect(x: rx1, y: bottomMargin + 1, width: rx2 - rx1, height: height - 2)
                drawPath = NSBezierPath.init(rect: brect)
                
                col.draw(in: drawPath, angle: UIConstants.verticalGradientDegrees)
                
            case .lowPass:
                
                let f = band.maxFreq!
                let x = log10(f/2) - 1
                let rx = offset + CGFloat(x) * scale
                let lineWidth: CGFloat = 2
                
                if unitState == .active {
                
                    GraphicsUtils.drawVerticalLine(bandPassGradient, pt1: NSPoint(x: rx - lineWidth / 2, y: bottomMargin + 1), pt2: NSPoint(x: rx - lineWidth / 2, y: bottomMargin + height - 2), width: lineWidth)
                    GraphicsUtils.drawVerticalLine(bandStopGradient, pt1: NSPoint(x: rx + lineWidth / 2, y: bottomMargin + 1), pt2: NSPoint(x: rx + lineWidth / 2, y: bottomMargin + height - 2), width: lineWidth)
                    
                } else {
                    
                    GraphicsUtils.drawVerticalLine(inactiveUnitGradient, pt1: NSPoint(x: rx, y: bottomMargin + 1), pt2: NSPoint(x: rx, y: bottomMargin + height - 2), width: lineWidth)
                }
                
            case .highPass:
                
                let f = band.minFreq!
                let x = log10(f/2) - 1
                let rx = offset + CGFloat(x) * scale
                let lineWidth: CGFloat = 2
                
                if unitState == .active {
                    
                    GraphicsUtils.drawVerticalLine(bandStopGradient, pt1: NSPoint(x: rx - lineWidth / 2, y: bottomMargin + 1), pt2: NSPoint(x: rx - lineWidth / 2, y: bottomMargin + height - 2), width: lineWidth)
                    GraphicsUtils.drawVerticalLine(bandPassGradient, pt1: NSPoint(x: rx + lineWidth / 2, y: bottomMargin + 1), pt2: NSPoint(x: rx + lineWidth / 2, y: bottomMargin + height - 2), width: lineWidth)
                    
                } else {
                    
                    GraphicsUtils.drawVerticalLine(inactiveUnitGradient, pt1: NSPoint(x: rx, y: bottomMargin + 1), pt2: NSPoint(x: rx, y: bottomMargin + height - 2), width: lineWidth)
                }
            }
        }
        
        drawPath = NSBezierPath.init(rect: frameRect)
        Colors.filterChartTextColor.setStroke()
        drawPath.stroke()
        
        // Draw X-axis markings
        let xMarks: [CGFloat] = [31, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
        let textFont: NSFont = TextSizes.filterChartFont
        
        for y in xMarks {

            let x = log10(y/2) - 1
            let sx = offset + x * scale

            var text: String
            if Int(y) % 1000 == 0 {
                text = String(format: "%dk", Int(y) / 1000)
            } else {
                text = String(describing: Int(y))
            }
            
            let tw = StringUtils.sizeOfString(text, textFont)
            let tx = offset + x * scale - tw.width / 2
            
            let trect = NSRect(x: tx, y: bottomMargin + height / 2 - 7.5, width: tw.width + 10, height: 15)
            
            GraphicsUtils.drawTextInRect(trect, text, Colors.filterChartTextColor, textFont)
            
            if (sx != offset && sx != offset + width) {
                GraphicsUtils.drawLine(Colors.fxFunctionTextColor, pt1: NSPoint(x: sx, y: bottomMargin), pt2: NSPoint(x: sx, y: bottomMargin + height / 2 - 8), width: 1.5)
                GraphicsUtils.drawLine(Colors.fxFunctionTextColor, pt1: NSPoint(x: sx, y: bottomMargin + height / 2 + 8), pt2: NSPoint(x: sx, y: bottomMargin + height), width: 1.5)
            }
        }
    }
}
