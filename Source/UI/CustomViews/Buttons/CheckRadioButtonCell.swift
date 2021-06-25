//
//  CheckRadioButtonCell.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    Customizes the look n feel of check and radio buttons on all modal dialogs
 */
import Cocoa

fileprivate func attributedString(_ text: String, _ font: NSFont, _ color: NSColor) -> NSAttributedString {
    NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
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
        self.attributedAlternateTitle = attributedString(self.title, self.font ?? Fonts.checkRadioButtonFont, Colors.defaultSelectedLightTextColor)
    }
}

class CheckRadioButtonCell: NSButtonCell {
    
    var textFont: NSFont {return Fonts.checkRadioButtonFont}
    
    var textColor: NSColor {return isOff ? Colors.boxTextColor : Colors.defaultSelectedLightTextColor}
    
    var xOffset: CGFloat {0}
    var yOffset: CGFloat {0}
    
    override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
        
        let titleText = title.string
        
        let size: CGSize = titleText.size(withFont: textFont)
        let sx = frame.minX + xOffset
        let sy = frame.minY + (frame.height - size.height) / 2 - yOffset
        
        let textRect = NSRect(x: sx, y: sy, width: size.width, height: size.height)
        titleText.draw(in: textRect, withFont: textFont, andColor: textColor)
        
        return frame
    }
}

class EffectsFunctionCheckRadioButtonCell: CheckRadioButtonCell {
    
    override var textColor: NSColor {Colors.Effects.functionCaptionTextColor}
    override var textFont: NSFont {Fonts.Effects.unitFunctionFont}
    
    override var xOffset: CGFloat {8}
}

class ColorSchemesDialogCheckBoxCell: CheckRadioButtonCell {
    
    override var textFont: NSFont {return Fonts.Standard.mainFont_12}
}
