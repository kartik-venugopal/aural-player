/*
    Customizes the look and feel of buttons that control tab groups
 */

import Cocoa

// Base class for all tab group button cells
class TabGroupButtonCell: NSButtonCell {
    
    // Highlighting colors the button text to indicate that the effects unit represented by this button is currently active
    var shouldHighlight: Bool = false
    var highlightColor: NSColor = Colors.tabViewButtonTextColor
    
    var fillBeforeBorder: Bool {return true}
    var backgroundFillColor: NSColor {return Colors.tabViewButtonBackgroundColor}
    var borderInsetX: CGFloat {return 1}
    var borderInsetY: CGFloat {return 1}
    var borderRadius: CGFloat {return 1}
    var borderLineWidth: CGFloat {return 2}
    var borderStrokeColor: NSColor {return Colors.tabViewButtonOutlineColor}
    var selectionBoxColor: NSColor {return Colors.tabViewSelectionBoxColor}
    
    var unselectedTextColor: NSColor {return Colors.tabViewButtonTextColor}
    var selectedTextColor: NSColor {return Colors.playlistSelectedTextColor}
    var textFont: NSFont {return Fonts.tabViewButtonFont}
    var boldTextFont: NSFont {return Fonts.tabViewButtonBoldFont}
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        // Background
        if (fillBeforeBorder) {
            
            backgroundFillColor.setFill()
            let backgroundPath = NSBezierPath.init(rect: cellFrame)
            backgroundPath.fill()
        }
        
        // Selection box
        if (state == 1) {
            
            let drawRect = cellFrame.insetBy(dx: borderInsetX, dy: borderInsetY)
            let roundedPath = NSBezierPath.init(roundedRect: drawRect, xRadius: borderRadius, yRadius: borderRadius)
            selectionBoxColor.setFill()
            roundedPath.fill()
        }
     
        // Title
        let textColor = shouldHighlight ? highlightColor : (state == 0 ? unselectedTextColor : selectedTextColor)
        let font = state == 1 ? boldTextFont : textFont
        
        GraphicsUtils.drawCenteredTextInRect(cellFrame, title, textColor, font)
    }
}

// Cell for the Effects unit tab group
class EffectsUnitButtonCell: TabGroupButtonCell {
    
    override var borderRadius: CGFloat {return 1.5}
    override var borderLineWidth: CGFloat {return 1.5}
}

class PlaylistViewsButtonCell: TabGroupButtonCell {
    
    override var borderRadius: CGFloat {return 2}
    override var selectionBoxColor: NSColor {return NSColor(calibratedWhite: 0.25, alpha: 1)}
}

// Cell for the Preferences tab group
class PrefsTabButtonCell: TabGroupButtonCell {
    
    override var fillBeforeBorder: Bool {return false}
    override var borderRadius: CGFloat {return 4}
    override var borderLineWidth: CGFloat {return 1.5}
    override var selectionBoxColor: NSColor {return NSColor.black}
}
