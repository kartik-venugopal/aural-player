/*
    Customizes the look n feel of check and radio buttons on all modal dialogs
 */
import Cocoa

private func attributedString(_ text: String, _ font: NSFont, _ color: NSColor) -> NSAttributedString {
        
        return NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color])
    }

/*
    Custom check box / radio button that can custom-color its title.
 */
class DialogCheckRadioButton: NSButton {
    
    override func awakeFromNib() {
        titleUpdated()
    }
    
    // Call this function whenever the title is updated
    func titleUpdated() {
        
        self.attributedTitle = attributedString(self.title, self.font ?? Fonts.checkRadioButtonFont, Colors.boxTextColor)
        self.attributedAlternateTitle = attributedString(self.title, self.font ?? Fonts.checkRadioButtonFont, Colors.playlistSelectedTextColor)
    }
}

class CheckRadioButtonCell: NSButtonCell {
    
    var textFont: NSFont {return Fonts.checkRadioButtonFont}
    
    var textColor: NSColor {return isOff ? Colors.boxTextColor : Colors.playlistSelectedTextColor}
    
    var xOffset: CGFloat {0}
    var yOffset: CGFloat {0}
    
    override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
        
        let attrs: [String: AnyObject] = [
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): textFont,
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): textColor]
        
        let titleText = title.string
        
        let attrDict = convertToOptionalNSAttributedStringKeyDictionary(attrs)
        
        let size: CGSize = titleText.size(withAttributes: attrDict)
        let sx = frame.minX + xOffset
        let sy = frame.minY + (frame.height - size.height) / 2 - yOffset
        
        let textRect = NSRect(x: sx, y: sy, width: size.width, height: size.height)
        titleText.draw(in: textRect, withAttributes: attrDict)
        
        return frame
    }
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

class FXFunctionCheckRadioButtonCell: CheckRadioButtonCell {
    
    override var textColor: NSColor {return Colors.Effects.functionCaptionTextColor}
    override var textFont: NSFont {return FontSchemes.systemScheme.effects.unitFunctionFont}
    
    override var xOffset: CGFloat {8}
}

class ColorSchemesDialogCheckBoxCell: CheckRadioButtonCell {
    
    override var textFont: NSFont {return Fonts.Standard.mainFont_12}
}

class ColorSchemesDialogRadioButtonCell: CheckRadioButtonCell {
    
    override var textFont: NSFont {return Fonts.Standard.mainFont_12}
    override var yOffset: CGFloat {return 2}
}
