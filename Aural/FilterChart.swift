import Cocoa

class FilterChart: NSView {
    
    var barRadius: CGFloat {return 1}
    var barColoredGradient: NSGradient {return Colors.neutralSliderBarColoredGradient}
    
    private var graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    override func awakeFromNib() {
        
        print(graph.addFilterBand(FilterBand(.bandStop).withMinFreq(25).withMaxFreq(60)))
        print(graph.addFilterBand(FilterBand(.bandStop).withMinFreq(250).withMaxFreq(300)))
        print(graph.addFilterBand(FilterBand(.bandPass).withMinFreq(16386).withMaxFreq(20475)))
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        var drawPath = NSBezierPath.init(rect: dirtyRect)
        NSColor.black.setFill()
        drawPath.fill()
        
        let offset: CGFloat = 12
        let width = self.frame.width - 2 * offset
        let scale: CGFloat = width / 3
        
        let frameRect: NSRect = NSRect(x: offset, y: 20, width: width, height: 20)
        
        drawPath = NSBezierPath.init(rect: frameRect)
        NSColor.lightGray.setStroke()
        drawPath.stroke()
        
        // Draw bands
        let bands = graph.allFilterBands()
        
        for band in bands {
            
            let min = band.minFreq!
            let max = band.maxFreq!
            
            let x1 = log10(min/2) - 1
            let x2 = log10(max/2) - 1
            
            let rx1 = offset + CGFloat(x1) * scale
            let rx2 = offset + CGFloat(x2) * scale
            
            let col = band.type == .bandStop ? NSColor.red : NSColor.green
            
            let brect = NSRect(x: rx1, y: 20, width: rx2 - rx1, height: 20)
            drawPath = NSBezierPath.init(rect: brect)
            col.setFill()
            drawPath.fill()
        }
        
        // Draw X-axis markings
        let xMarks: [CGFloat] = [20, 60, 100, 250, 500, 1024, 2048, 4096, 8192, 10240, 16384, 20480]
        
        for y in xMarks {

            let x = log10(y/2) - 1
            let sx = offset + x * scale

            print(y, x, sx)

            var text: String
            if Int(y) % 1024 == 0 {
                text = String(format: "%dk", Int(y) / 1024)
            } else {
                text = String(describing: Int(y))
            }
            
            let tw = StringUtils.sizeOfString(text, Fonts.gillSans8Font)
            let tx = offset + x * scale - tw.width / 2
            
            let trect = NSRect(x: tx, y: 2, width: tw.width + 10, height: 15)
            
            GraphicsUtils.drawTextInRect(trect, text, NSColor.lightGray, Fonts.gillSans8Font)
            
            if (sx != offset && sx != offset + width) {
                GraphicsUtils.drawLine(NSColor.gray, pt1: NSPoint(x: sx, y: 16), pt2: NSPoint(x: sx, y: 24), width: 2)
            }
        }
        
//        var tr = NSRect(x: 5, y: 5, width: 50, height: 15)
//        GraphicsUtils.drawTextInRect(tr, "20", NSColor.red, Fonts.gillSans10Font)
//
//        tr = NSRect(x: 185, y: 5, width: 50, height: 15)
//        GraphicsUtils.drawTextInRect(tr, "200", NSColor.red, Fonts.gillSans10Font)
    }
}
