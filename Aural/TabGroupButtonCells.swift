/*
    Customizes the look and feel of buttons that control the effects tab view
 */

import Cocoa

class TabGroupButtonCell: NSButtonCell {
    
    // Highlighting colors the button text to indicate that the effects unit represented by this button is currently active
    var shouldHighlight: Bool = false
    var highlightColor: NSColor = Colors.tabViewButtonTextColor
    
    var fillBeforeBorder: Bool {return true}
    var backgroundFillColor: NSColor {return NSColor.black}
    var borderInsetX: CGFloat {return 1}
    var borderInsetY: CGFloat {return 1}
    var borderRadius: CGFloat {return 2}
    var borderLineWidth: CGFloat {return 1.5}
    var borderStrokeColor: NSColor {return Colors.tabViewButtonOutlineColor}
    var selectionBoxColor: NSColor {return Colors.tabViewSelectionBoxColor}
    
    var unselectedTextColor: NSColor {return Colors.tabViewButtonTextColor}
    var selectedTextColor: NSColor {return Colors.playlistSelectedTextColor}
    var textFont: NSFont {return UIConstants.tabViewButtonFont}
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        if (fillBeforeBorder) {
            backgroundFillColor.setFill()
            let backgroundPath = NSBezierPath.init(rect: cellFrame)
            backgroundPath.fill()
        }
        
        // Draw border
        let drawRect = cellFrame.insetBy(dx: borderInsetX, dy: borderInsetY)
        let roundedPath = NSBezierPath.init(roundedRect: drawRect, xRadius: borderRadius, yRadius: borderRadius)
        borderStrokeColor.setStroke()
        roundedPath.lineWidth = borderLineWidth
        roundedPath.stroke()
        
        // If selected, fill in the rect
        if (self.state == 1) {
            let roundedPath = NSBezierPath.init(roundedRect: drawRect, xRadius: borderRadius, yRadius: borderRadius)
            selectionBoxColor.setFill()
            roundedPath.fill()
        }
        
        drawTitle(cellFrame)
    }
    
    internal func drawTitle(_ cellFrame: NSRect) {
        
        // Draw the title
        let textColor = shouldHighlight ? highlightColor : (state == 0 ? unselectedTextColor : selectedTextColor)
        let attrs: [String: AnyObject] = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor]
        
        let size: CGSize = title!.size(withAttributes: attrs)
        let sx = (cellFrame.width - size.width) / 2
        let sy = (cellFrame.height - size.height) / 2 - 2
        
        let textRect = NSRect(x: sx, y: sy, width: size.width, height: size.height)
        title!.draw(in: textRect, withAttributes: attrs)
    }
}

class EffectsUnitButtonCell: TabGroupButtonCell {
}

class PrefsTabButtonCell: TabGroupButtonCell {
    
    override var fillBeforeBorder: Bool {return false}
    override var borderRadius: CGFloat {return 4}
    override var selectionBoxColor: NSColor {return NSColor.black}
}
