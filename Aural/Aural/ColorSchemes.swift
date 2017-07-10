/*
    Enumeration of color schemes for use by the UI. Used by AppDelegate when loading the app.
*/

import Cocoa

enum ColorSchemes {
    
    case DarkOutLightIn
    
    case LightOutDarkIn
    
    case Brown
    
    case Gray
    
    // Background color of the main window
    var windowColor: NSColor {
        
        switch self {
            
        case .DarkOutLightIn: return NSColor(deviceRed: CGFloat(0.5), green: CGFloat(0.5), blue: CGFloat(0.5), alpha: CGFloat(1))
            
        case .LightOutDarkIn: return NSColor(deviceRed: CGFloat(0.8), green: CGFloat(0.8), blue: CGFloat(0.8), alpha: CGFloat(1))
            
        case Brown: return NSColor(deviceRed: CGFloat(0.3), green: CGFloat(0.2), blue: CGFloat(0.1), alpha: CGFloat(1))
            
        case Gray: return NSColor(deviceRed: CGFloat(0.7), green: CGFloat(0.7), blue: CGFloat(0.7), alpha: CGFloat(1))
        }
    }
    
    // Fill color of the container "boxes"
    var boxColor: NSColor {
        
        switch self {
            
        case .DarkOutLightIn: return NSColor(deviceRed: CGFloat(0.8), green: CGFloat(0.8), blue: CGFloat(0.8), alpha: CGFloat(1))
            
        case .LightOutDarkIn: return NSColor.blackColor()
            
        case Brown: return NSColor(deviceRed: CGFloat(0.9), green: CGFloat(0.6), blue: CGFloat(0.3), alpha: CGFloat(1))
            
        case Gray: return NSColor(deviceRed: CGFloat(0.85), green: CGFloat(0.85), blue: CGFloat(0.85), alpha: CGFloat(1))
        }
    }
    
    // Color of text on the main window
    var windowTextColor: NSColor {
        
        switch self {
            
        case .DarkOutLightIn: return NSColor(deviceRed: CGFloat(0.7), green: CGFloat(0.7), blue: CGFloat(0.7), alpha: CGFloat(1))
            
        case .LightOutDarkIn: return NSColor.blackColor()
            
        case Brown: return NSColor(deviceRed: CGFloat(0.9), green: CGFloat(0.6), blue: CGFloat(0.3), alpha: CGFloat(1))
            
        case Gray: return NSColor.blackColor()
        }
    }
    
    // Color of text inside any of the container "boxes"
    var boxTextColor: NSColor {
        
        switch self {
            
        case .DarkOutLightIn: return NSColor(deviceRed: CGFloat(0.2), green: CGFloat(0.2), blue: CGFloat(0.2), alpha: CGFloat(1))
            
        case .LightOutDarkIn: return NSColor(deviceRed: CGFloat(0.9), green: CGFloat(0.9), blue: CGFloat(0.9), alpha: CGFloat(1))
            
        case Brown: return windowColor
            
        case Gray: return NSColor.blackColor()
        }
    }
    
    // Color of text inside the playlist (non-selected items)
    var playlistTextColor: NSColor {
        
        switch self {
            
        case .DarkOutLightIn: return NSColor.blackColor()
            
        case .LightOutDarkIn: return NSColor.lightGrayColor()
            
        case Brown: return windowColor
            
        case Gray: return boxTextColor
        }
    }
    
    // Fill color of box drawn around selected playlist item
    var playlistSelectionBoxColor: NSColor {
        
        switch self {
            
        case .DarkOutLightIn: return NSColor.grayColor()
            
        case .LightOutDarkIn: return NSColor.lightGrayColor()
            
        case Brown: return NSColor(deviceRed: CGFloat(0.7), green: CGFloat(0.1), blue: CGFloat(0.1), alpha: CGFloat(1))
            
        case Gray: return NSColor(deviceRed: CGFloat(0.3), green: CGFloat(0.3), blue: CGFloat(0.3), alpha: CGFloat(1))
        }
    }
    
    // Slider knob color
    var sliderKnobColor: NSColor {
        return playlistSelectionBoxColor
    }
    
    // Only for EQ slider knobs
    var eqSliderKnobColor: NSColor {
        return NSColor(deviceRed: CGFloat(0.2), green: CGFloat(0.2), blue: CGFloat(0.2), alpha: CGFloat(1))
    }
    
    // Slider bar for equalizer
    var eqSliderBarColor: NSColor {
        return NSColor(deviceRed: CGFloat(0.4), green: CGFloat(0.4), blue: CGFloat(0.4), alpha: CGFloat(1))
    }
    
    // Pop up menu (reverb/EQ) color
    var popupMenuColor: NSColor {
        return NSColor(deviceRed: CGFloat(0.6), green: CGFloat(0.6), blue: CGFloat(0.6), alpha: CGFloat(1))
    }
    
    // Color of selected item text inside the playlist
    var playlistSelectedTextColor: NSColor {
        
        switch self {
            
        case .DarkOutLightIn: return NSColor.lightGrayColor()
            
        case .LightOutDarkIn: return NSColor.blackColor()
            
        case Brown: return NSColor.brownColor()
            
        case Gray: return NSColor(deviceRed: CGFloat(0.85), green: CGFloat(0.85), blue: CGFloat(0.85), alpha: CGFloat(1))
        }
    }
    
    // Takes a color as input and darkens it by scaling up its RGB components by a certain factor
    private func lighten(color: NSColor, factor: CGFloat) -> NSColor {
        let r = color.redComponent
        let g = color.greenComponent
        let b = color.blueComponent
        
        return NSColor( deviceRed: r * factor, green: g * factor, blue: b * factor, alpha: CGFloat(1))
    }

    // Takes a color as input and darkens it by scaling down its RGB components by a certain factor
    private func darken(color: NSColor, factor: CGFloat) -> NSColor {
        let r = color.redComponent
        let g = color.greenComponent
        let b = color.blueComponent
        
        return NSColor( deviceRed: r / factor, green: g / factor, blue: b / factor, alpha: CGFloat(1))
    }
}