/*
    Customizes the look n feel of buttons on modal dialogs
 */

import Cocoa

class ModalDialogButtonCell: NSButtonCell {
    
    var cellInsetX: CGFloat {return 0}
    var cellInsetY: CGFloat {return 0}
    
    var backgroundFillColor: NSColor {return Colors.modalDialogButtonColor}
    var borderRadius: CGFloat {return 1}
    var borderLineWidth: CGFloat {return 1}
    var borderStrokeColor: NSColor {return Colors.modalDialogButtonOutlineColor}
    
    var textColor: NSColor {return Colors.boxTextColor}
    var textFont: NSFont {return UIConstants.modalDialogButtonFont}
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let drawRect = cellFrame.insetBy(dx: cellInsetX, dy: cellInsetY)
        
        // Background
        backgroundFillColor.setFill()
        let borderPath = NSBezierPath.init(roundedRect: drawRect, xRadius: borderRadius, yRadius: borderRadius)
        borderPath.fill()
        
        // Border
        borderStrokeColor.setStroke()
        borderPath.lineWidth = borderLineWidth
        borderPath.stroke()
        
        // Title
        GraphicsUtils.drawCenteredTextInRect(cellFrame, title, textColor, textFont)
    }
}

class ModalDialogResponseButtonCell: ModalDialogButtonCell {
    
    override var cellInsetX: CGFloat {return 1}
    override var cellInsetY: CGFloat {return 1}
    
    override var borderRadius: CGFloat {return 2}
    override var borderLineWidth: CGFloat {return 0.5}
}

class ColoredNavigationButtonCell: ModalDialogButtonCell {
    
    override var cellInsetX: CGFloat {return 1}
    override var cellInsetY: CGFloat {return 1}
    
    override var backgroundFillColor: NSColor {return Colors.modalDialogNavButtonColor}
    
    override var borderRadius: CGFloat {return 3}
    override var borderLineWidth: CGFloat {return 1.5}
    
    override var textColor: NSColor {return Colors.modalDialogNavButtonTextColor}
    override var textFont: NSFont {return UIConstants.modalDialogNavButtonFont}
}
