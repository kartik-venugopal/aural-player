/*
    Container for colors used by the UI
*/

import Cocoa

struct Colors {
    
    // Color of text inside any of the container boxes
    static let boxTextColor: NSColor = NSColor(calibratedWhite: 0.7, alpha: 1)
    
    static let editorHeaderTextColor: NSColor = NSColor(calibratedWhite: 0.85, alpha: 1)
    
    // Color of text inside the playlist (non-selected items)
    static let playlistTextColor: NSColor = NSColor(calibratedWhite: 0.75, alpha: 1)
    // Color of selected item text inside the playlist
    static let playlistSelectedTextColor: NSColor = NSColor(calibratedWhite: 1, alpha: 1)
    
    // Color of text inside the playlist (non-selected items)
    static let playlistIndexTextColor: NSColor = NSColor(calibratedWhite: 0.3, alpha: 1)
    // Color of selected item text inside the playlist
    static let playlistSelectedIndexTextColor: NSColor = NSColor(calibratedWhite: 0.6, alpha: 1)
    
    static let playlistGroupIndexTextColor: NSColor = NSColor(calibratedWhite: 0.45, alpha: 1)
    // Color of selected item text inside the playlist
    static let playlistGroupSelectedIndexTextColor: NSColor = NSColor(calibratedWhite: 0.7, alpha: 1)
    
    static let overlayBackgroundColor: NSColor = NSColor(calibratedWhite: 0, alpha: 0.8)

    static let playlistGapTextColor: NSColor = NSColor(calibratedWhite: 0.8, alpha: 1)
    static let playlistSelectedGapTextColor: NSColor = NSColor(calibratedWhite: 1, alpha: 1)
    
    // Color for playlist grouped views
    static let playlistGroupNameTextColor: NSColor = NSColor(calibratedWhite: 0.6, alpha: 1)
    static let playlistGroupNameSelectedTextColor: NSColor = NSColor(calibratedWhite: 0.8, alpha: 1)
    static let playlistGroupItemTextColor: NSColor = NSColor(calibratedWhite: 0.7, alpha: 1)
    static let playlistGroupItemSelectedTextColor: NSColor = NSColor(calibratedWhite: 1, alpha: 1)
    
    // Fill color of box drawn around selected playlist item
    static let playlistSelectionBoxColor: NSColor = NSColor(calibratedWhite: 0.15, alpha: 1)
    
    static let editorSelectionBoxColor: NSColor = NSColor(calibratedWhite: 0.55, alpha: 1)
    
    // Fill color of all slider knobs
    static let neutralKnobColor: NSColor = NSColor(white: 0.5, alpha: 1.0)
    static let activeKnobColor: NSColor = NSColor(red: 0, green: 0.625, blue: 0, alpha: 1)
    static let bypassedKnobColor: NSColor = NSColor(calibratedWhite: 0.6, alpha: 1)
    static let suppressedKnobColor: NSColor = NSColor(red: 0.8, green: 0.6, blue: 0, alpha: 1)
    
    // Outline color of buttons on modal dialogs
    static let modalDialogButtonOutlineColor: NSColor = NSColor(calibratedWhite: 0.575, alpha: 1)
    
    // Color used to fill tab view buttons
    static let tabViewButtonBackgroundColor: NSColor = NSColor(calibratedWhite: 0, alpha: 1)
    
    static let transparentColor: NSColor = NSColor(calibratedWhite: 1, alpha: 0)
    
    // Color used to outline tab view buttons
    static let tabViewButtonOutlineColor: NSColor = NSColor(calibratedWhite: 0.65, alpha: 1)
    
    // Color used for text in tab view buttons
    static let tabViewButtonTextColor: NSColor = NSColor(calibratedWhite: 0.9, alpha: 1)
    
    // Color of the arrow drawn on popup menus
    static let popupMenuArrowColor: NSColor = NSColor(calibratedWhite: 0.2, alpha: 1)
    
    // A lighter version of popupMenuArrowColor
    static let lightPopupMenuArrowColor: NSColor = NSColor(calibratedWhite: 0.8, alpha: 1)
    
    // Color of the displayed text in popup menus
    static let popupMenuTextColor: NSColor = NSColor(calibratedWhite: 0.9, alpha: 1)

    static let sliderBarGradient: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.7, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.2, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    // Gradient used to fill slider bars
    static let sliderBarPlainGradient: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.4, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.1, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let scrollerKnobColor: NSColor = NSColor(white: 0.3, alpha: 1.0)
    static let scrollerBarColor: NSColor = NSColor(white: 0.25, alpha: 1.0)
    
    static let neutralSliderBarColoredGradient: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.6, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.4, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let activeSliderBarColoredGradient: NSGradient = {
        
        let backgroundStart = NSColor(red: 0, green: 0.625, blue: 0, alpha: 1)
        let backgroundEnd =  NSColor(red: 0, green: 0.2, blue: 0, alpha: 1)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let bypassedSliderBarColoredGradient: NSGradient = {
        
        let backgroundStart = NSColor(calibratedWhite: 0.6, alpha: 1)
        let backgroundEnd =  NSColor(calibratedWhite: 0.3, alpha: 1)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let suppressedSliderBarColoredGradient: NSGradient = {
        
        let backgroundStart = NSColor(red: 0.8, green: 0.6, blue: 0, alpha: 1)
        let backgroundEnd =  NSColor(red: 0.27, green: 0.2, blue: 0, alpha: 1)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let bandStopGradient: NSGradient = {
        
        let backgroundStart = NSColor(red: 0.75, green: 0, blue: 0, alpha: 1)
        let backgroundEnd =  NSColor(red: 0.2, green: 0, blue: 0, alpha: 1)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let playbackLoopGradient: NSGradient = {
        
        let backgroundStart = NSColor(red: 1, green: 0, blue: 0, alpha: 1)
        let backgroundEnd =  NSColor(red: 0.5, green: 0, blue: 0, alpha: 1)
        
//        let backgroundStart = NSColor(calibratedWhite: 1, alpha: 1)
//        let backgroundEnd =  NSColor(calibratedWhite: 0.6, alpha: 1)
        
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let seekBarPlainGradient: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.4, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.2, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let progressBarColoredGradient: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.7, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.4, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let seekBarColoredGradient: NSGradient = Colors.neutralSliderBarColoredGradient
    
    // Color of the ticks/notches on sliders
    static let sliderNotchColor: NSColor = NSColor(calibratedWhite: 0, alpha: 1)
    
    // Pop up menu (reverb/EQ/recorder) color
    static let popupMenuColor: NSColor = NSColor(calibratedWhite: 0.6, alpha: 1)
    
    // Fill color of box drawn around selected tab view item
    static let tabViewSelectionBoxColor: NSColor = NSColor(calibratedWhite: 0.125, alpha: 1)
    
    // Text color of modal dialog buttons
    static let modalDialogButtonTextColor: NSColor = NSColor(calibratedWhite: 0.9, alpha: 1)
    
    static let modalDialogButtonGradient: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.5, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.2, alpha: 1.0)
        return NSGradient(starting: backgroundStart, ending: backgroundEnd)!
    }()
    
    // Text color of modal dialog buttons
    static let modalDialogButtonTextColor_disabled: NSColor = NSColor(calibratedWhite: 0.5, alpha: 1)
    
    static let modalDialogButtonGradient_disabled: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.25, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.1, alpha: 1.0)
        return NSGradient(starting: backgroundStart, ending: backgroundEnd)!
    }()
    
    // Fill color of modal dialog navigation buttons (search)
    static let modalDialogNavButtonColor: NSColor = NSColor(calibratedWhite: 0.45, alpha: 1)
    
    // Fill color of text in modal dialog navigation buttons (search)
    static let modalDialogNavButtonTextColor: NSColor = NSColor(calibratedWhite: 0.9, alpha: 1)
    
    // Color of cursor inside text fields
    static let textFieldCursorColor: NSColor = NSColor(calibratedWhite: 0.5, alpha: 1)
    
    // Background color of the popover view
    static let popoverBackgroundColor: NSColor = NSColor(calibratedWhite: 0.1, alpha: 1)
}
