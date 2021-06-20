/*
    Customizes the look and feel of all popup menus
*/

import Cocoa

// Base class for all popup menu cells
class PopupMenuCell: NSPopUpButtonCell {
    
    var cellInsetX: CGFloat {return 0}
    var cellInsetY: CGFloat {return 0}
    var rectRadius: CGFloat {return 1}
    var menuGradient: NSGradient {return Colors.sliderBarGradient}
    
    var titleFont: NSFont {return Fonts.popupMenuFont}
    var titleColor: NSColor {return Colors.Effects.defaultPopupMenuTextColor}
    
    var arrowXMargin: CGFloat {return 5}
    var arrowYMargin: CGFloat {return 5}
    var arrowWidth: CGFloat {return 3}
    var arrowHeight: CGFloat {return 3}
    var arrowLineWidth: CGFloat {return 2}
    var arrowColor: NSColor {return Colors.popupMenuArrowColor}
    
    var textOffsetX: CGFloat {0}
    var textOffsetY: CGFloat {0}
    
    override internal func drawBorderAndBackground(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let drawRect = cellFrame.insetBy(dx: cellInsetX, dy: cellInsetY)
        let drawPath = NSBezierPath.init(roundedRect: drawRect, xRadius: rectRadius, yRadius: rectRadius)
        
        menuGradient.draw(in: drawPath, angle: -.verticalGradientDegrees)
        
        // Draw arrow
        let x = drawRect.maxX - arrowXMargin, y = drawRect.maxY - arrowYMargin
        GraphicsUtils.drawArrow(arrowColor, origin: NSMakePoint(x, y), dx: arrowWidth, dy: arrowHeight, lineWidth: arrowLineWidth)
    }
    
    override func drawTitle(_ title: NSAttributedString, withFrame: NSRect, in inView: NSView) -> NSRect {
        
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.center
        
        let textFontAttributes = [
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): titleFont,
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): titleColor,
            convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): textStyle
        ]
        
        title.string.draw(in: withFrame.offsetBy(dx: textOffsetX, dy: textOffsetY), withAttributes: convertToOptionalNSAttributedStringKeyDictionary(textFontAttributes))
        
        return withFrame
    }
}

// Cell for reverb preset popup menu
class NicerPopupMenuCell: PopupMenuCell {
    
    override var cellInsetY: CGFloat {return 4}
    override var rectRadius: CGFloat {return 2}
    override var arrowXMargin: CGFloat {return 10}
    override var arrowYMargin: CGFloat {return 4}
    override var arrowHeight: CGFloat {return 4}
}

class FXUnitPopupMenuCell: NicerPopupMenuCell {
    
    override var cellInsetY: CGFloat {return 1}
    override var rectRadius: CGFloat {return 2}
    override var arrowXMargin: CGFloat {return 10}
    override var arrowYMargin: CGFloat {return 7}
    override var arrowColor: NSColor {return Colors.buttonMenuTextColor}
    
    override var arrowWidth: CGFloat {return 3}
    override var arrowHeight: CGFloat {return 4}
    override var arrowLineWidth: CGFloat {return 1}
    
    override var menuGradient: NSGradient {return Colors.textButtonMenuGradient}
    
    override var titleFont: NSFont {return FontSchemes.systemScheme.effects.unitFunctionFont}
    override var titleColor: NSColor {return Colors.buttonMenuTextColor}
    
    override func drawTitle(_ title: NSAttributedString, withFrame: NSRect, in inView: NSView) -> NSRect {
        
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.center
        
        let textFontAttributes = [
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): titleFont,
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): titleColor,
            convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): textStyle
        ]
        
        let attrsDict = convertToOptionalNSAttributedStringKeyDictionary(textFontAttributes)
        
        // Compute size and origin
        let size: CGSize = title.string.size(withAttributes: attrsDict)
        let sx = (withFrame.width - size.width) / 2
        let sy = (withFrame.height - size.height) / 2 - 2
        
        title.string.draw(in: NSRect(x: sx, y: sy, width: size.width, height: size.height), withAttributes: attrsDict)
        
        return withFrame
    }
    
    override func titleRect(forBounds cellFrame: NSRect) -> NSRect {
        return cellFrame.offsetBy(dx: 0, dy: -1)
    }
}

// Cell for all preferences popup menus
class PreferencesPopupMenuCell: PopupMenuCell {
    
    override var cellInsetY: CGFloat {return 5}
    override var rectRadius: CGFloat {return 2}
    override var arrowXMargin: CGFloat {return 10}
    override var arrowYMargin: CGFloat {return 6}
    override var arrowHeight: CGFloat {return 4}
    override var arrowColor: NSColor {return Colors.lightPopupMenuArrowColor}
    
    override var menuGradient: NSGradient {return Colors.popupMenuGradient}
}

class FontsPopupMenuCell: PopupMenuCell {
    
    override var cellInsetY: CGFloat {return 2}
    override var rectRadius: CGFloat {return 2}
    override var arrowXMargin: CGFloat {return 10}
    override var arrowYMargin: CGFloat {return 6}
    override var arrowHeight: CGFloat {return 6}
    override var arrowColor: NSColor {return Colors.lightPopupMenuArrowColor}
    
    override var menuGradient: NSGradient {return Colors.popupMenuGradient}
    
    override var textOffsetY: CGFloat {3}
}

class FXPreviewPopupMenuCell: NicerPopupMenuCell {
    
    override var menuGradient: NSGradient {return Colors.Effects.defaultPopupMenuGradient}
    
    override var titleColor: NSColor {return Colors.Effects.defaultPopupMenuTextColor}
    
    override var arrowColor: NSColor {return titleColor}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
