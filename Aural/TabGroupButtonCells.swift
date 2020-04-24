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
    var borderStrokeColor: NSColor {return Colors.tabViewButtonOutlineColor}
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
    
    override var textFont: NSFont {return Fonts.Playlist.tabsFont}
    override var boldTextFont: NSFont {return Fonts.Playlist.selectedTabFont}
    
    override var yOffset: CGFloat {

        switch PlaylistViewState.textSize {
            
        case .normal:   return 1
            
        case .larger:   return 0
            
        case .largest:  return -1
            
        }
    }
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
    
    override var unselectedTextColor: NSColor {return Colors.Constants.white70Percent}
    
    override var textFont: NSFont {return Fonts.Playlist.tabsFont_normal}
    override var boldTextFont: NSFont {return Fonts.Playlist.selectedTabFont_normal}
    
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
    
    override var selectionBoxColor: NSColor {return Colors.selectedTabButtonColor}
    
    override var unselectedTextColor: NSColor {return Colors.tabButtonTextColor}
    override var selectedTextColor: NSColor {return Colors.selectedTabButtonTextColor}
    
    override var yOffset: CGFloat {
        
        if isOff {
            return -1
        }
        
        switch EffectsViewState.textSize {
            
        case .normal:   return 1
            
        case .larger:   return 0
            
        case .largest:  return -1
            
        }
    }
}

class FilterBandsTabButtonCell: EQSelectorButtonCell {
    
    override var textFont: NSFont {return Fonts.Effects.unitFunctionFont}
    override var boldTextFont: NSFont {return Fonts.Effects.unitFunctionBoldFont}
    
    override var yOffset: CGFloat {
        
        if isOff {
            return -1
        }
        
        switch EffectsViewState.textSize {
            
        case .normal:   return 1
            
        case .larger:   return 0
            
        case .largest:  return 0
            
        }
    }
}
