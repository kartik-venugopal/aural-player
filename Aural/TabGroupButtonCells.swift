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
        if isOn() {
            
            let drawRect = cellFrame.insetBy(dx: borderInsetX, dy: borderInsetY)
            let roundedPath = NSBezierPath.init(roundedRect: drawRect, xRadius: borderRadius, yRadius: borderRadius)
            selectionBoxColor.setFill()
            roundedPath.fill()
        }
     
        // Title
        let textColor = shouldHighlight ? highlightColor : (isOff() ? unselectedTextColor : selectedTextColor)
        let font = isOn() ? boldTextFont : textFont
        
        GraphicsUtils.drawCenteredTextInRect(cellFrame, title, textColor, font)
    }
}

class PlaylistViewsButtonCell: TabGroupButtonCell {
    
    override var borderRadius: CGFloat {return 2}
    override var selectionBoxColor: NSColor {return NSColor(calibratedWhite: 0.135, alpha: 1)}
}

// Cell for the Preferences tab group
class PrefsTabButtonCell: TabGroupButtonCell {
    
    override var fillBeforeBorder: Bool {return false}
    override var borderRadius: CGFloat {return 4}
    override var borderLineWidth: CGFloat {return 1.5}
    override var selectionBoxColor: NSColor {return NSColor.black}
}

class PrefsNestedTabButtonCell: PrefsTabButtonCell {
    
    override var borderRadius: CGFloat {return 2.5}
    override var selectionBoxColor: NSColor {return Colors.tabViewSelectionBoxColor}
}

class EQSelectorButtonCell: TabGroupButtonCell {
    
    override var textFont: NSFont {return Fonts.gillSans11Font}
    override var boldTextFont: NSFont {return Fonts.gillSansSemiBold11Font}
    override var borderRadius: CGFloat {return 2}
    override var selectionBoxColor: NSColor {return NSColor(calibratedWhite: 0.235, alpha: 1)}
}

class FilterBandsTabButtonCell: EQSelectorButtonCell {
    
    override var textFont: NSFont {return Fonts.gillSans10Font}
    override var boldTextFont: NSFont {return Fonts.gillSansSemiBold10Font}
}
