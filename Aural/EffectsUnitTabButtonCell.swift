import Cocoa

@IBDesignable
class EffectsUnitTabButtonCell: NSButtonCell {
    
    private let borderInsetX: CGFloat = 0
    private let borderInsetY: CGFloat = 0
    private let borderRadius: CGFloat = 3
    
//    private let backgroundFillColor: NSColor = Colors.tabViewButtonBackgroundColor
    private var backgroundFillColor: NSColor {return Colors.windowBackgroundColor}
    private var selectionBoxColor: NSColor {return Colors.tabViewSelectionBoxColor}
    
//    private let unselectedTextColor: NSColor = Colors.tabViewButtonTextColor
//    private let selectedTextColor: NSColor = Colors.playlistSelectedTextColor
//
//    private let regularTextFont: NSFont = Fonts.tabViewButtonFont_small
//    private let boldTextFont: NSFont = Fonts.tabViewButtonBoldFont_small
    
//    @IBInspectable var activeUnitTextColor: NSColor?
//    @IBInspectable var bypassedUnitTextColor: NSColor?
//    @IBInspectable var suppressedUnitTextColor: NSColor?
//
    var unitState: EffectsUnitState = .bypassed
//    var textColor: NSColor = Colors.tabViewButtonTextColor
//    var textFont: NSFont {return TextSizes.fxTabsFont}
    
    private let imgWidth: CGFloat = 15, imgHeight: CGFloat = 15
    
    func updateState(_ unitState: EffectsUnitState) {
        
        self.unitState = unitState
        
        // Change textColor based on state
//        switch unitState {
//
//        case .active:   textColor = activeUnitTextColor ?? NSColor.green
//
//        case .bypassed: textColor = bypassedUnitTextColor ?? NSColor.white
//
//        case .suppressed: textColor = suppressedUnitTextColor ?? NSColor.yellow
//
//        }
    }
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        // Background
        backgroundFillColor.setFill()
        NSBezierPath.init(rect: cellFrame).fill()
        
        // Selection box
        if isOn() {
            
            let drawRect = cellFrame.insetBy(dx: borderInsetX, dy: borderInsetY)
            selectionBoxColor.setFill()
//            selectionBoxColor.setStroke()
            NSBezierPath.init(roundedRect: drawRect, xRadius: borderRadius, yRadius: borderRadius).fill()
//            let path = NSBezierPath.init(roundedRect: drawRect, xRadius: borderRadius, yRadius: borderRadius)
//            path.lineWidth = 4
//            path.stroke()
        }
        
        // Check if selected, and adjust text font
//        textFont = isOn() ? boldTextFont : regularTextFont
        
        // Title
//        let attrs: [String: AnyObject] = [
//            convertFromNSAttributedStringKey(NSAttributedString.Key.font): textFont,
//            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): textColor]
        
        // Draw image (left aligned)
        let rectWidth: CGFloat = cellFrame.width, rectHeight: CGFloat = cellFrame.height
        let xInset = (rectWidth - imgWidth) / 2
        let yInset = (rectHeight - imgHeight) / 2
        
//        let imgRect = cellFrame.insetBy(dx: xInset, dy: yInset).offsetBy(dx: -(rectWidth / 2) + imgWidth - 1, dy: 0)
        let imgRect = cellFrame.insetBy(dx: xInset, dy: yInset)
        self.image?.draw(in: imgRect)
        
//        // Compute text size and position
//        let size: CGSize = self.title.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attrs))
//
//        let xPadding = (cellFrame.width - imgRect.maxX - size.width) / 2
//        let sx: CGFloat = imgRect.maxX + xPadding
//        print(xPadding, cellFrame.width, imgRect, sx)
//
//        let yPadding = (cellFrame.height - size.height) / 2
//        let sy = cellFrame.height - size.height - yPadding - 1
//
////        print(sx, sy, cellFrame.height, size.height)
//
//        // Draw title (adjacent to image)
//        self.title.draw(in: NSRect(x: sx, y: sy, width: size.width, height: size.height), withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attrs))
    }
}

// Helper function inserted by Swift 4.2 migrator.
//fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
//    return input.rawValue
//}
//
//// Helper function inserted by Swift 4.2 migrator.
//fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
//    guard let input = input else { return nil }
//    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
//}
