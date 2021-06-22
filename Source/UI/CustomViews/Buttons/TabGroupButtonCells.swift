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
    var borderInsetX: CGFloat {return 1}
    var borderInsetY: CGFloat {return 1}
    var borderRadius: CGFloat {return 1}
    var borderLineWidth: CGFloat {return 2}
    var selectionBoxColor: NSColor {return Colors.tabViewSelectionBoxColor}
    
    var unselectedTextColor: NSColor {return Colors.tabViewButtonTextColor}
    var selectedTextColor: NSColor {return Colors.playlistSelectedTextColor}
    var textFont: NSFont {return Fonts.tabViewButtonFont}
    var boldTextFont: NSFont {return Fonts.tabViewButtonBoldFont}
    
    var yOffset: CGFloat {return 0}
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        drawInterior(withFrame: cellFrame, in: controlView)
    }
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        var drawRect: NSRect = cellFrame
        
        // Selection box
        if isOn {
            
            drawRect = cellFrame.insetBy(dx: borderInsetX, dy: borderInsetY)
            let roundedPath = NSBezierPath.init(roundedRect: drawRect, xRadius: borderRadius, yRadius: borderRadius)
            selectionBoxColor.setFill()
            roundedPath.fill()
        }
     
        // Title
        let textColor = shouldHighlight ? highlightColor : (isOff ? unselectedTextColor : selectedTextColor)
        let font = isOn ? boldTextFont : textFont
        
        GraphicsUtils.drawCenteredTextInRect(drawRect, title, textColor, font, yOffset)
    }
}

class PlaylistViewsButtonCell: TabGroupButtonCell {
    
    override var unselectedTextColor: NSColor {return Colors.tabButtonTextColor}
    override var selectedTextColor: NSColor {return Colors.selectedTabButtonTextColor}
    
    override var borderRadius: CGFloat {return 3}
    override var selectionBoxColor: NSColor {return Colors.selectedTabButtonColor}
    
    override var textFont: NSFont {Fonts.Playlist.tabButtonTextFont}
    override var boldTextFont: NSFont {Fonts.Playlist.tabButtonTextFont}
    
    override var borderInsetY: CGFloat {return 0}
    
    override var yOffset: CGFloat {0}
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let font = isOn ? boldTextFont : textFont
        
        // Selection underline
        if isOn {
            
            let underlineWidth = title.size(withFont: font).width
            let selRect = NSRect(x: cellFrame.centerX - (underlineWidth / 2), y: cellFrame.maxY - 2, width: underlineWidth, height: 2)
            
            selectionBoxColor.setFill()
            selRect.fill()
        }
        
        // Title
        let textColor = shouldHighlight ? highlightColor : (isOff ? unselectedTextColor : selectedTextColor)
        GraphicsUtils.drawCenteredTextInRect(cellFrame, title, textColor, font, yOffset - (isOn ? 2 : 0))
    }
}

// Cell for the Preferences tab group
class PrefsTabButtonCell: TabGroupButtonCell {
    
    override var fillBeforeBorder: Bool {return false}
    override var borderRadius: CGFloat {return 4}
    override var borderLineWidth: CGFloat {return 1.5}
    override var selectionBoxColor: NSColor {.black}
}

class ContrastedPrefsTabButtonCell: TabGroupButtonCell {
    
//    override var fillBeforeBorder: Bool {return false}
//    override var borderRadius: CGFloat {return 4}
//    override var borderLineWidth: CGFloat {return 1.5}
    override var selectionBoxColor: NSColor {Colors.Constants.white70Percent}
    override var selectedTextColor: NSColor {.black}
}

class EQPreviewTabButtonCell: TabGroupButtonCell {
    override var selectionBoxColor: NSColor {return Colors.Constants.white15Percent}
}

class TrackInfoPopoverTabButtonCell: TabGroupButtonCell {
    
    private let _selectionBoxColor: NSColor = NSColor.black
    
    override var unselectedTextColor: NSColor {return Colors.Constants.white70Percent}
    
    override var textFont: NSFont {return Fonts.largeTabButtonFont}
    override var boldTextFont: NSFont {return Fonts.largeTabButtonFont}
    
    override var fillBeforeBorder: Bool {return false}
    override var borderRadius: CGFloat {return 4}
    override var borderLineWidth: CGFloat {return 1.5}
    override var selectionBoxColor: NSColor {return _selectionBoxColor}
}

class EQSelectorButtonCell: TabGroupButtonCell {
    
    override var textFont: NSFont {Fonts.Effects.unitFunctionFont}
    override var boldTextFont: NSFont {Fonts.Effects.unitFunctionFont}
    
    override var borderRadius: CGFloat {return 1}
    
    override var selectionBoxColor: NSColor {return Colors.selectedTabButtonColor}
    
    override var unselectedTextColor: NSColor {return Colors.tabButtonTextColor}
    override var selectedTextColor: NSColor {return Colors.selectedTabButtonTextColor}
    
    override var yOffset: CGFloat {0}
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let font = isOn ? boldTextFont : textFont
        
        // Selection dot
        if isOn {
            
            let textWidth = title.size(withFont: font).width
            let markerSize: CGFloat = 6
            let markerX = cellFrame.centerX - (textWidth / 2) - 5 - markerSize
            let markerRect = NSRect(x: markerX, y: cellFrame.centerY - (markerSize / 2) + yOffset + 1, width: markerSize, height: markerSize)
            let roundedPath = NSBezierPath.init(roundedRect: markerRect, xRadius: borderRadius, yRadius: borderRadius)
            
            selectionBoxColor.setFill()
            roundedPath.fill()
        }
        
        // Title
        let textColor = shouldHighlight ? highlightColor : (isOff ? unselectedTextColor : selectedTextColor)
        GraphicsUtils.drawCenteredTextInRect(cellFrame, title, textColor, font, yOffset)
    }
}

class FilterBandsTabButtonCell: EQSelectorButtonCell {
    
    override var yOffset: CGFloat {0}
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let font = isOn ? boldTextFont : textFont
        
        // Selection underline
        if isOn {
            
            let underlineWidth = title.size(withFont: font).width
            let selRect = NSRect(x: cellFrame.centerX - (underlineWidth / 2), y: cellFrame.minY + 2, width: underlineWidth, height: 1)
            selectionBoxColor.setFill()
            selRect.fill()
        }
        
        // Title
        let textColor = shouldHighlight ? highlightColor : (isOff ? unselectedTextColor : selectedTextColor)
        GraphicsUtils.drawCenteredTextInRect(cellFrame, title, textColor, font, yOffset - (isOn ? -1 : 0))
    }
}
