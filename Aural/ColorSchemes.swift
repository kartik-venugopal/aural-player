/*
    Enumeration of color schemes for use by the UI. Used by AppDelegate when loading the app.
*/

import Cocoa

enum ColorSchemes {
    
    case darkOutLightIn
    
    case lightOutDarkIn
    
    case brown
    
    case gray
    
    // Background color of the main window
    var windowColor: NSColor {
        
        switch self {
            
        case .darkOutLightIn: return NSColor(deviceRed: CGFloat(0.5), green: CGFloat(0.5), blue: CGFloat(0.5), alpha: CGFloat(1))
            
        case .lightOutDarkIn: return NSColor(deviceRed: CGFloat(0.8), green: CGFloat(0.8), blue: CGFloat(0.8), alpha: CGFloat(1))
            
        case .brown: return NSColor(deviceRed: CGFloat(0.3), green: CGFloat(0.2), blue: CGFloat(0.1), alpha: CGFloat(1))
            
        case .gray: return NSColor(deviceRed: CGFloat(0.7), green: CGFloat(0.7), blue: CGFloat(0.7), alpha: CGFloat(1))
        }
    }
    
    // Fill color of the container "boxes"
    var boxColor: NSColor {
        
        switch self {
            
        case .darkOutLightIn: return NSColor(deviceRed: CGFloat(0.8), green: CGFloat(0.8), blue: CGFloat(0.8), alpha: CGFloat(1))
            
        case .lightOutDarkIn: return NSColor.black
            
        case .brown: return NSColor(deviceRed: CGFloat(0.9), green: CGFloat(0.6), blue: CGFloat(0.3), alpha: CGFloat(1))
            
        case .gray: return NSColor(deviceRed: CGFloat(0.85), green: CGFloat(0.85), blue: CGFloat(0.85), alpha: CGFloat(1))
        }
    }
    
    // Color of text on the main window
    var windowTextColor: NSColor {
        
        switch self {
            
        case .darkOutLightIn: return NSColor(deviceRed: CGFloat(0.7), green: CGFloat(0.7), blue: CGFloat(0.7), alpha: CGFloat(1))
            
        case .lightOutDarkIn: return NSColor.black
            
        case .brown: return NSColor(deviceRed: CGFloat(0.9), green: CGFloat(0.6), blue: CGFloat(0.3), alpha: CGFloat(1))
            
        case .gray: return NSColor.black
        }
    }
    
    // Color of text inside any of the container "boxes"
    var boxTextColor: NSColor {
        
        switch self {
            
        case .darkOutLightIn: return NSColor(deviceRed: CGFloat(0.2), green: CGFloat(0.2), blue: CGFloat(0.2), alpha: CGFloat(1))
            
        case .lightOutDarkIn: return NSColor(deviceRed: CGFloat(0.9), green: CGFloat(0.9), blue: CGFloat(0.9), alpha: CGFloat(1))
            
        case .brown: return windowColor
            
        case .gray: return NSColor.black
        }
    }
    
    // Color of text inside the playlist (non-selected items)
    var playlistTextColor: NSColor {
        
        switch self {
            
        case .darkOutLightIn: return NSColor.black
            
        case .lightOutDarkIn: return NSColor.lightGray
            
        case .brown: return windowColor
            
        case .gray: return boxTextColor
        }
    }
    
    // Fill color of box drawn around selected playlist item
    var playlistSelectionBoxColor: NSColor {
        
        switch self {
            
        case .darkOutLightIn: return NSColor.gray
            
        case .lightOutDarkIn: return NSColor.lightGray
            
        case .brown: return NSColor(deviceRed: CGFloat(0.7), green: CGFloat(0.1), blue: CGFloat(0.1), alpha: CGFloat(1))
            
        case .gray: return NSColor(deviceRed: CGFloat(0.3), green: CGFloat(0.3), blue: CGFloat(0.3), alpha: CGFloat(1))
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
    
    // Color of the part of the slider bar that is to the left of (or below) the knob (darker)
    var sliderBarDarkColor: NSColor {
        return NSColor(deviceRed: CGFloat(0.25), green: CGFloat(0.25), blue: CGFloat(0.25), alpha: CGFloat(1))
    }
    
    // Color of the part of the slider bar that is to the right of (or above) the knob (lighter)
    var sliderBarLightColor: NSColor {
        return NSColor(deviceRed: CGFloat(0.5), green: CGFloat(0.5), blue: CGFloat(0.5), alpha: CGFloat(1))
    }
    
    // Pop up menu (reverb/EQ/recorder) color
    var popupMenuColor: NSColor {
        return NSColor(deviceRed: CGFloat(0.6), green: CGFloat(0.6), blue: CGFloat(0.6), alpha: CGFloat(1))
    }
    
    // Color of selected item text inside the playlist
    var playlistSelectedTextColor: NSColor {
        
        switch self {
            
        case .darkOutLightIn: return NSColor.lightGray
            
        case .lightOutDarkIn: return NSColor.black
            
        case .brown: return NSColor.brown
            
        case .gray: return NSColor(deviceRed: CGFloat(0.85), green: CGFloat(0.85), blue: CGFloat(0.85), alpha: CGFloat(1))
        }
    }
    
    // Takes a color as input and darkens it by scaling up its RGB components by a certain factor
    fileprivate func lighten(_ color: NSColor, factor: CGFloat) -> NSColor {
        let r = color.redComponent
        let g = color.greenComponent
        let b = color.blueComponent
        
        return NSColor( deviceRed: r * factor, green: g * factor, blue: b * factor, alpha: CGFloat(1))
    }

    // Takes a color as input and darkens it by scaling down its RGB components by a certain factor
    fileprivate func darken(_ color: NSColor, factor: CGFloat) -> NSColor {
        let r = color.redComponent
        let g = color.greenComponent
        let b = color.blueComponent
        
        return NSColor( deviceRed: r / factor, green: g / factor, blue: b / factor, alpha: CGFloat(1))
    }
}
