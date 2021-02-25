/*
    Customizes the look n feel of buttons on modal dialogs
 */

import Cocoa

// Base class for all modal dialog button cells
class ModalDialogButtonCell: NSButtonCell {
    
    var cellInsetX: CGFloat {return 0}
    var cellInsetY: CGFloat {return 0}
    
    var backgroundFillGradient: NSGradient {return Colors.modalDialogButtonGradient}
    var backgroundFillGradient_disabled: NSGradient {return Colors.modalDialogButtonGradient_disabled}
    var borderRadius: CGFloat {return 2}
    
    var textColor: NSColor {return Colors.modalDialogButtonTextColor}
    var textColor_disabled: NSColor {return Colors.modalDialogButtonTextColor_disabled}
    
    var textFont: NSFont {return Fonts.modalDialogButtonFont}
    
    var yOffset: CGFloat {return 0}
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let drawRect = cellFrame.insetBy(dx: cellInsetX, dy: cellInsetY)
        
        // Background
        let borderPath = NSBezierPath.init(roundedRect: drawRect, xRadius: borderRadius, yRadius: borderRadius)
        
        if isEnabled {
            backgroundFillGradient.draw(in: borderPath, angle: -UIConstants.verticalGradientDegrees)
        } else {
            backgroundFillGradient_disabled.draw(in: borderPath, angle: -UIConstants.verticalGradientDegrees)
        }
        
        // Title
        GraphicsUtils.drawCenteredTextInRect(drawRect, title, isEnabled ? textColor : textColor_disabled, textFont, yOffset)
    }
}

// Cell for all response buttons (Save/Cancel, etc)
class ModalDialogResponseButtonCell: ModalDialogButtonCell {
    
    override var cellInsetX: CGFloat {return 1}
    override var cellInsetY: CGFloat {return 1}
    
    override var borderRadius: CGFloat {return 2.5}
}

class StringInputPopoverResponseButtonCell: ModalDialogResponseButtonCell {
    override var textFont: NSFont {return Fonts.stringInputPopoverFont}
}

// Cell for all response buttons (Save/Cancel, etc)
class ModalDialogControlButtonCell: ModalDialogButtonCell {
    
    override var cellInsetX: CGFloat {return 1}
    override var cellInsetY: CGFloat {return 0}
    
    override var textFont: NSFont {return Fonts.modalDialogControlButtonFont}
}

// Browse button in Playlist preferences
class ModalDialogSmallControlButtonCell: ModalDialogButtonCell {
    
    override var cellInsetX: CGFloat {return 1}
    override var cellInsetY: CGFloat {return 0}
    
    override var textFont: NSFont {return Fonts.Standard.mainFont_10}
}

// Cell for search results navigation buttons (next/previous)
class ColoredNavigationButtonCell: ModalDialogButtonCell {
    
    override var cellInsetX: CGFloat {return 1}
    override var cellInsetY: CGFloat {return 1}
    
    override var borderRadius: CGFloat {return 3}
    
    override var textColor: NSColor {return Colors.modalDialogNavButtonTextColor}
    override var textFont: NSFont {return Fonts.modalDialogNavButtonFont}
}

class ChaptersListSearchNavigationButtonCell: ColoredNavigationButtonCell {
    
    override var backgroundFillGradient: NSGradient {return Colors.functionButtonGradient}
    override var backgroundFillGradient_disabled: NSGradient {return Colors.functionButtonGradient_disabled}
    
    override var textColor: NSColor {return Colors.buttonMenuTextColor}
    override var textColor_disabled: NSColor {return Colors.disabledFunctionButtonTextColor}
}

class ColorAwareButtonCell: ModalDialogButtonCell {
    
    override var textColor: NSColor {return Colors.buttonMenuTextColor}
    override var textColor_disabled: NSColor {return Colors.buttonMenuTextColor}
    
    override var backgroundFillGradient: NSGradient {return Colors.textButtonMenuGradient}
    override var backgroundFillGradient_disabled: NSGradient {return Colors.textButtonMenuGradient}
}

class FXTextButtonCell: ColorAwareButtonCell {
    
    override var textFont: NSFont {return FontSchemes.systemScheme.effects.unitFunctionFont}
    
    override var yOffset: CGFloat {
        
        return -1
        
//        if isOff {
//            return -1
//        }
//
//        switch EffectsViewState.textSize {
//
//        case .normal:   return -1
//
//        case .larger:   return -1
//
//        case .largest:  return -2
//
//        }
    }
}
