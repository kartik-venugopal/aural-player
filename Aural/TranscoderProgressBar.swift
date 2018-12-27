import Cocoa

class TranscoderProgressBar: NSProgressIndicator {
    
    var barPlainGradient: NSGradient {return Colors.sliderBarPlainGradient}
    var barColoredGradient: NSGradient {return Colors.progressBarColoredGradient}
    var gradientDegrees: CGFloat {return UIConstants.horizontalGradientDegrees}
    
    var barRadius: CGFloat {return 1.3}
    var barInsetX: CGFloat {return 0}
    var barInsetY: CGFloat {return 8}
    
    var textFont: NSFont = Fonts.progressBarFont
    
    override func draw(_ dirtyRect: NSRect) {
        
        let aRect: NSRect = dirtyRect.insetBy(dx: barInsetX, dy: barInsetY)
        let perc = CGFloat(self.doubleValue)
        let width = perc * self.width / 100
        
        var drawPath: NSBezierPath
        
        if perc > 0 {

            let leftRect = NSRect(x: aRect.minX, y: aRect.minY, width: width, height: aRect.height)
            drawPath = NSBezierPath.init(roundedRect: leftRect, xRadius: barRadius, yRadius: barRadius)
            barColoredGradient.draw(in: drawPath, angle: gradientDegrees)
        }
        
        if aRect.width - width > 0 {
            
            let rightRect = NSRect(x: aRect.minX + width, y: aRect.minY, width: aRect.width - width, height: aRect.height)
            drawPath = NSBezierPath.init(roundedRect: rightRect, xRadius: barRadius, yRadius: barRadius)
            barPlainGradient.draw(in: drawPath, angle: gradientDegrees)
        }
        
        // Percentage text
        
//        let text = String(format: "%d%%", Int(round(perc)))
//
//        let attrs: [String: AnyObject] = [
//            NSAttributedString.Key.font.rawValue: textFont,
//            NSAttributedString.Key.foregroundColor.rawValue: perc < 50 ? NSColor.white : NSColor.black]
//
//        let dict = convertToOptionalNSAttributedStringKeyDictionary(attrs)
//
//        let size: CGSize = text.size(withAttributes: dict)
//
//        // Draw title (adjacent to image)
//        text.draw(in: NSRect(x: aRect.width / 2 - 10, y: aRect.minY - 3, width: size.width, height: size.height), withAttributes: dict)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
