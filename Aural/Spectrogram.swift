import Cocoa

class Spectrogram: NSView {
    
    static var instance: Spectrogram?
    
    let viewWidth: Int = 512
    let viewHeight: Int = 308
    
    var barCount: Int = 10
    
    var barWidth: Int {
        return viewWidth / barCount
    }
    
    var roundRadius: Int {
        return barWidth / 10
    }
    
    var maxBarHeight: Int {
        return viewHeight * 7 / 8
    }
    
    let multiplier: Float = 5
    
    var data: FrequencyData?
    
    let viewRect = NSRect(x: 0, y: 0, width: 512, height: 308)
    let bottomRect = NSRect(x: CGFloat(0), y: CGFloat(0), width: 512, height: CGFloat(4))
    
    func updateWithData(_ data: FrequencyData) {
        
        self.data = data
        
        DispatchQueue.main.sync {
            redraw()
        }
        
        //        Swift.print("Data: ", data.bandMags)
        //        Swift.print("Data:", data.frequencies.count, data.magnitudes.count)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        Spectrogram.instance = self
        
        if let data = data {
        
        if (data.frequencies.count > 0) {
            
            //            barCount = (data?.magnitudes.count)!
            barCount = 10
//            let interval = data.magnitudes.count / barCount
            
            NSColor.black.set()
            NSBezierPath.fill(viewRect)
            
            for i in 0...barCount - 1 {
//                for i in 0...2 {
            
                let x = CGFloat(barWidth * i)
                let y = -1
                //                let magn = data!.magnitudes[i * interval]
                //                let magn = max(minI: i * interval, maxI: ((i + 1) * interval) - 1)
                //                let magn = avg(minI: i * interval, maxI: ((i + 1) * interval) - 1)
                let magn = data.magnitudes[i]
                
                let height = min(Float(maxBarHeight), magn * multiplier * Float(maxBarHeight))
                let barRect = NSRect(x: x, y: CGFloat(y), width: CGFloat(barWidth), height: CGFloat(height))
                
                drawBar(barRect, maxHeight: CGFloat(maxBarHeight))
                drawFreq(data.frequencies[i], bar: barRect)
            }
        }
        }
        
        //        NSColor.blackColor().setFill()
        //        NSBezierPath.fillRect(bottomRect)
    }
    
    func drawFreq(_ freq: Float, bar: NSRect) {
        
        //        let s = String(Int(round(freq)))
        //        let text = s as NSString
        //        let attrs: [String: AnyObject] = [
        //            NSFontAttributeName: NSFont(name: "Gill Sans", size: 12)!,
        //            NSForegroundColorAttributeName: NSColor.blue]
        //        let rect = NSRect(x: bar.origin.x + 15, y: 10, width: 40, height: 20)
        //        text.draw(in: rect, withAttributes: attrs)
    }
    
    func drawBar(_ bar: NSRect, maxHeight: CGFloat) {
        
        if (bar.height < CGFloat(roundRadius)) {
            return
        }
        
        let startColor = colorForHeight(bar.height, maxHeight: maxHeight)
        let endColor = NSColor.green
        
        let context: CGContext! = NSGraphicsContext.current?.cgContext
        context.saveGState()
        
        let myColorspace: CGColorSpace = CGColorSpaceCreateDeviceRGB();
        let locations: [CGFloat] = [1.0, 0.0]
        let components: [CGFloat] = [startColor.redComponent, startColor.greenComponent, startColor.blueComponent, startColor.alphaComponent,   endColor.redComponent, endColor.greenComponent, endColor.blueComponent, endColor.alphaComponent]
        
        let clippath: CGPath = NSBezierPath(roundedRect: bar, xRadius: 3, yRadius: 3).CGPath
        context.addPath(clippath);
        context.closePath();
        
        let myGradient: CGGradient = CGGradient(colorSpace: myColorspace, colorComponents: components, locations: locations, count: locations.count)!
        
        (context).clip()
        
        let myStartPoint = CGPoint(x:bar.minX + 5,y:0), myEndPoint = CGPoint(x: bar.minX + 5,y:bar.maxY)
        
        context.drawLinearGradient (myGradient, start: myStartPoint, end: myEndPoint, options: CGGradientDrawingOptions(rawValue: 0))
        context.restoreGState()
        
        // Outline around the bar (to separate bars)
        NSColor.black.setStroke()
        let barPath = NSBezierPath.init(rect: bar)
        barPath.stroke()
    }
    
    func avg(minI: Int, maxI: Int) -> Float {
        
        //        Swift.print("min", minI, "max", maxI)
        
        var sum: Float = 0
        
        for i in minI...maxI {
            sum += (data?.magnitudes[i])!
        }
        
        return sum / Float(maxI - minI + 1)
    }
    
    func max(minI: Int, maxI: Int) -> Float {
        
        //        Swift.print("min", minI, "max", maxI)
        
        var max: Float = -1
        
        for i in minI...maxI {
            let mag = (data?.magnitudes[i])!
            if (mag > max) {
                max = mag
            }
        }
        
        return max
    }
    
    func colorForHeight(_ height: CGFloat, maxHeight: CGFloat) -> NSColor {
        
        let green: CGFloat = (maxHeight - height) / maxHeight
        let red: CGFloat = (height / maxHeight)
        
        return NSColor(deviceRed: min(0.75, red), green: green, blue: 0, alpha: 1)
    }
}

public extension NSBezierPath {
    
    var CGPath: CGPath {
        
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        var fehler = 0
        
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            
            switch type {
            case .moveTo: path.move(to: CGPoint(x: points[0].x, y: points[0].y) )
            case .lineTo: path.addLine(to: CGPoint(x: points[0].x, y: points[0].y) )
            case .curveTo: path.addCurve(      to: CGPoint(x: points[2].x, y: points[2].y),
                                               control1: CGPoint(x: points[0].x, y: points[0].y),
                                               control2: CGPoint(x: points[1].x, y: points[1].y) )
            case .closePath: path.closeSubpath()
<<<<<<< HEAD
            @unknown default: 0
            }
        }
=======
                
            //dummy action avoiding compiler warning...
            default:  fehler = fehler + 1
            } //end switch
        } //end for
>>>>>>> master
        return path
    }
}
