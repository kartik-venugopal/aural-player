/*
    Container for colors used by the UI
*/

import Cocoa

class Colors {
    
    // Color of text inside any of the container boxes
    static let boxTextColor: NSColor = NSColor(calibratedWhite: 0.7, alpha: 1)
    
    // Color of text inside the playlist (non-selected items)
    static let playlistTextColor: NSColor = NSColor(calibratedWhite: 0.7, alpha: 1)
    
    // Fill color of box drawn around selected playlist item
    static let playlistSelectionBoxColor: NSColor = NSColor(calibratedWhite: 0.45, alpha: 1)
    
    // Color of selected item text inside the playlist
    static let playlistSelectedTextColor: NSColor = NSColor(calibratedWhite: 0.9, alpha: 1)
    
    static let timeSliderKnobColor: NSColor = sliderKnobColor
    
    static let timeSliderKnobStrokeColor: NSColor = NSColor(calibratedWhite: 0.65, alpha: 1)
    
    static let sliderKnobColor: NSColor = NSColor(calibratedWhite: 0.8, alpha: 1)
    
    static let lightSliderKnobColor: NSColor = NSColor(calibratedWhite: 0.8, alpha: 1)
    
    static let sliderKnobOutlineColor: NSColor = NSColor.black
    
    static let modalDialogNavButtonOutlineColor: NSColor = NSColor(calibratedWhite: 0.65, alpha: 1)
    
    static let modalDialogResponseButtonOutlineColor: NSColor = NSColor(calibratedWhite: 0.5, alpha: 1)
    
    static let tabViewOutlineColor: NSColor = NSColor(calibratedWhite: 0.65, alpha: 1)
    
    static let tabViewTextColor: NSColor = NSColor(calibratedWhite: 0.9, alpha: 1)
    
    // Only for EQ slider knobs
    static let eqSliderKnobColor: NSColor = NSColor(calibratedWhite: 0.8, alpha: 1)
    
    static let tabViewEffectsButtonHighlightColor: NSColor = NSColor.green
    static let tabViewRecorderButtonHighlightColor: NSColor = NSColor.red
    
    static let sliderBarGradient: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.6, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.4, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        assert(barBackgroundGradient != nil, "Couldn't generate gradient.")
        
        return barBackgroundGradient!
    }()
    
    static let sliderKnobGradient: NSGradient = {
        
        let backgroundStart = NSColor(white: 1, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.5, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        assert(barBackgroundGradient != nil, "Couldn't generate gradient.")
        
        return barBackgroundGradient!
    }()
    
    static let sliderKnobGradient_reverse: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.5, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 1, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        assert(barBackgroundGradient != nil, "Couldn't generate gradient.")
        
        return barBackgroundGradient!
    }()
    
    // Pop up menu (reverb/EQ/recorder) color
    static let popupMenuColor: NSColor = NSColor(calibratedWhite: 0.6, alpha: 1)
    
    // Fill color of box drawn around selected tab view item
    static let tabViewSelectionBoxColor: NSColor = NSColor(calibratedWhite: 0.45, alpha: 1)
    
    // Fill color of modal dialog navigation buttons (search)
    static let modalDialogNavButtonColor: NSColor = NSColor(calibratedWhite: 0.45, alpha: 1)
    
    // Fill color of modal dialog navigation buttons (search)
    static let modalDialogNavButtonTextColor: NSColor = NSColor(calibratedWhite: 0.9, alpha: 1)
    
    // Color of cursor inside playlist search field
    static let searchFieldCursorColor: NSColor = NSColor(calibratedWhite: 0.5, alpha: 1)
    
    // Background color of the popover view
    static let popoverBackgroundColor: NSColor = NSColor(calibratedWhite: 0.3, alpha: 1)
    
    // Takes a color as input and darkens it by scaling up its RGB components by a certain factor
    private func lighten(_ color: NSColor, factor: CGFloat) -> NSColor {
        let r = color.redComponent
        let g = color.greenComponent
        let b = color.blueComponent
        
        return NSColor( deviceRed: r * factor, green: g * factor, blue: b * factor, alpha: CGFloat(1))
    }

    // Takes a color as input and darkens it by scaling down its RGB components by a certain factor
    private func darken(_ color: NSColor, factor: CGFloat) -> NSColor {
        let r = color.redComponent
        let g = color.greenComponent
        let b = color.blueComponent
        
        return NSColor( deviceRed: r / factor, green: g / factor, blue: b / factor, alpha: CGFloat(1))
    }
}
