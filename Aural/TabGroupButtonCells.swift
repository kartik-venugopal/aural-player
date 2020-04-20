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
        if isOn {
            
            let drawRect = cellFrame.insetBy(dx: borderInsetX, dy: borderInsetY)
            let roundedPath = NSBezierPath.init(roundedRect: drawRect, xRadius: borderRadius, yRadius: borderRadius)
            selectionBoxColor.setFill()
            roundedPath.fill()
        }
     
        // Title
        let textColor = shouldHighlight ? highlightColor : (isOff ? unselectedTextColor : selectedTextColor)
        let font = isOn ? boldTextFont : textFont
        
        GraphicsUtils.drawCenteredTextInRect(cellFrame, title, textColor, font)
    }
}

class PlaylistViewsButtonCell: TabGroupButtonCell {
    
    private var _unselectedTextColor: NSColor = Colors.Constants.white50Percent
    private var _selectedTextColor: NSColor = Colors.Constants.white80Percent
    
    override var unselectedTextColor: NSColor {return _unselectedTextColor}
    override var selectedTextColor: NSColor {return _selectedTextColor}
    
    override var borderRadius: CGFloat {return 3}
    override var selectionBoxColor: NSColor {return Colors.tabViewButtonSelectionBoxColor}
    
    override var textFont: NSFont {return Fonts.Playlist.tabsFont}
    override var boldTextFont: NSFont {return Fonts.Playlist.selectedTabFont}
}

// Cell for the Preferences tab group
class PrefsTabButtonCell: TabGroupButtonCell {
    
    override var fillBeforeBorder: Bool {return false}
    override var borderRadius: CGFloat {return 4}
    override var borderLineWidth: CGFloat {return 1.5}
    override var selectionBoxColor: NSColor {return NSColor.black}
}

class TrackInfoPopoverTabButtonCell: TabGroupButtonCell {
    
    private let _selectionBoxColor: NSColor = NSColor.black
    
    override var fillBeforeBorder: Bool {return false}
    override var borderRadius: CGFloat {return 4}
    override var borderLineWidth: CGFloat {return 1.5}
    override var selectionBoxColor: NSColor {return _selectionBoxColor}
}

class PrefsNestedTabButtonCell: PrefsTabButtonCell {
    
    override var borderRadius: CGFloat {return 2.5}
    override var selectionBoxColor: NSColor {return Colors.tabViewSelectionBoxColor}
}

class EQSelectorButtonCell: TabGroupButtonCell {
    
    override var textFont: NSFont {return Fonts.Effects.unitFunctionFont}
    override var boldTextFont: NSFont {return Fonts.Effects.unitFunctionBoldFont}
    override var borderRadius: CGFloat {return 2}
    override var selectionBoxColor: NSColor {return Colors.tabViewButtonSelectionBoxColor}
    
    override var unselectedTextColor: NSColor {return Colors.Constants.white40Percent}
    override var selectedTextColor: NSColor {return Colors.Constants.white60Percent}
}

class FilterBandsTabButtonCell: EQSelectorButtonCell {
    
    override var textFont: NSFont {return Fonts.Effects.unitFunctionFont}
    override var boldTextFont: NSFont {return Fonts.Effects.unitFunctionBoldFont}
}
