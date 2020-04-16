/*
    Container for colors used by the UI
*/

import Cocoa

struct ColorConstants {
    
    static let white10Percent: NSColor = NSColor(calibratedWhite: 0.1, alpha: 1)
    static let white13_5Percent: NSColor = NSColor(calibratedWhite: 0.135, alpha: 1)
    static let white15Percent: NSColor = NSColor(calibratedWhite: 0.15, alpha: 1)
    static let white20Percent: NSColor = NSColor(calibratedWhite: 0.2, alpha: 1)
    static let white25Percent: NSColor = NSColor(calibratedWhite: 0.25, alpha: 1)
    static let white30Percent: NSColor = NSColor(calibratedWhite: 0.3, alpha: 1)
    static let white35Percent: NSColor = NSColor(calibratedWhite: 0.35, alpha: 1)
    static let white40Percent: NSColor = NSColor(calibratedWhite: 0.4, alpha: 1)
    static let white45Percent: NSColor = NSColor(calibratedWhite: 0.45, alpha: 1)
    static let white50Percent: NSColor = NSColor(calibratedWhite: 0.5, alpha: 1)
    static let white60Percent: NSColor = NSColor(calibratedWhite: 0.6, alpha: 1)
    static let white70Percent: NSColor = NSColor(calibratedWhite: 0.7, alpha: 1)
    static let white80Percent: NSColor = NSColor(calibratedWhite: 0.8, alpha: 1)
    static let white85Percent: NSColor = NSColor(calibratedWhite: 0.85, alpha: 1)
    static let white90Percent: NSColor = NSColor(calibratedWhite: 0.9, alpha: 1)
}

struct Colors {
    
    // Color of text inside any of the container boxes
    static let boxTextColor: NSColor = ColorConstants.white70Percent
    
    static let trackInfoTitleTextColor: NSColor = ColorConstants.white45Percent
    static let trackInfoArtistAlbumTextColor: NSColor = ColorConstants.white60Percent
    static let trackInfoChapterTextColor: NSColor = ColorConstants.white50Percent
    
    static let fxFunctionTextColor: NSColor = ColorConstants.white40Percent
    
    static let fxFunctionPopupMenuTextColor: NSColor = ColorConstants.white60Percent
    
    static let filterChartTextColor: NSColor = ColorConstants.white85Percent
    
    static let editorHeaderTextColor: NSColor = ColorConstants.white85Percent
    
    // Color of text inside the playlist (non-selected items)
    static let playlistTextColor: NSColor = ColorConstants.white60Percent
    
    // Color of selected item text inside the playlist
    static let playlistSelectedTextColor: NSColor = NSColor.white
    
    // Color of text inside the playlist (non-selected items)
    static let playlistIndexTextColor: NSColor = ColorConstants.white30Percent
    
    // Color of selected item text inside the playlist
    static let playlistSelectedIndexTextColor: NSColor = ColorConstants.white60Percent
    
    static let playlistGroupIndexTextColor: NSColor = ColorConstants.white45Percent
    
    // Color of selected item text inside the playlist
    static let playlistGroupSelectedIndexTextColor: NSColor = ColorConstants.white70Percent
    
    static let playlistGapTextColor: NSColor = ColorConstants.white80Percent
    static let playlistSelectedGapTextColor: NSColor = NSColor.white
    
    // Color for playlist grouped views
    static let playlistGroupNameTextColor: NSColor = ColorConstants.white50Percent
    static let playlistGroupNameSelectedTextColor: NSColor = ColorConstants.white80Percent
    
    static let playlistGroupItemTextColor: NSColor = ColorConstants.white60Percent
    static let playlistGroupItemSelectedTextColor: NSColor = NSColor.white
    
    // Fill color of box drawn around selected playlist item
    static let playlistSelectionBoxColor: NSColor = ColorConstants.white15Percent
    
    static let editorSelectionBoxColor: NSColor = NSColor(calibratedWhite: 0.55, alpha: 1)
    
    // Fill color of all slider knobs
    static let neutralKnobColor: NSColor = ColorConstants.white50Percent
    static let activeKnobColor: NSColor = NSColor(red: 0, green: 0.625, blue: 0, alpha: 1)
    static let bypassedKnobColor: NSColor = ColorConstants.white60Percent
    static let suppressedKnobColor: NSColor = NSColor(red: 0.8, green: 0.6, blue: 0, alpha: 1)
    
    // Outline color of buttons on modal dialogs
    static let modalDialogButtonOutlineColor: NSColor = NSColor(calibratedWhite: 0.575, alpha: 1)
    
    // Color used to fill tab view buttons
    static let tabViewButtonBackgroundColor: NSColor = NSColor.black
    static let tabViewButtonSelectionBoxColor: NSColor = ColorConstants.white13_5Percent
    
    static let transparentColor: NSColor = NSColor.white
    
    // Color used to outline tab view buttons
    static let tabViewButtonOutlineColor: NSColor = NSColor(calibratedWhite: 0.65, alpha: 1)
    
    // Color used for text in tab view buttons
    static let tabViewButtonTextColor: NSColor = ColorConstants.white90Percent
    
    // Color of the arrow drawn on popup menus
    static let popupMenuArrowColor: NSColor = ColorConstants.white10Percent
    
    // A lighter version of popupMenuArrowColor
    static let lightPopupMenuArrowColor: NSColor = ColorConstants.white80Percent
    
    // A lighter version of popupMenuArrowColor
    static let fxUnitPopupMenuArrowColor: NSColor = ColorConstants.white40Percent
    
    // Color of the displayed text in popup menus
    static let popupMenuTextColor: NSColor = ColorConstants.white90Percent

    static let sliderBarGradient: NSGradient = {
        
        let backgroundStart = ColorConstants.white70Percent
        let backgroundEnd =  ColorConstants.white20Percent
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let popupMenuGradient: NSGradient = {
        
        let backgroundStart = ColorConstants.white35Percent
        let backgroundEnd =  ColorConstants.white10Percent
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    // Gradient used to fill slider bars
    static let sliderBarPlainGradient: NSGradient = {
        
        let backgroundStart = ColorConstants.white40Percent
        let backgroundEnd =  ColorConstants.white10Percent
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let scrollerKnobColor: NSColor = ColorConstants.white40Percent
    static let scrollerBarColor: NSColor = ColorConstants.white25Percent
    
    static let neutralSliderBarColoredGradient: NSGradient = {
        
        let backgroundStart = ColorConstants.white60Percent
        let backgroundEnd =  ColorConstants.white40Percent
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
        
        let backgroundStart = ColorConstants.white60Percent
        let backgroundEnd =  ColorConstants.white30Percent
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
        
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let seekBarPlainGradient: NSGradient = {
        
        let backgroundStart = ColorConstants.white40Percent
        let backgroundEnd =  ColorConstants.white20Percent
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let progressBarColoredGradient: NSGradient = {
        
        let backgroundStart = ColorConstants.white70Percent
        let backgroundEnd =  ColorConstants.white40Percent
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let seekBarColoredGradient: NSGradient = Colors.neutralSliderBarColoredGradient
    
    // Color of the ticks/notches on sliders
    static let sliderNotchColor: NSColor = NSColor.black
    
    // Pop up menu (reverb/EQ/recorder) color
    static let popupMenuColor: NSColor = ColorConstants.white60Percent
    
    // Fill color of box drawn around selected tab view item
    static let tabViewSelectionBoxColor: NSColor = NSColor(calibratedWhite: 0.125, alpha: 1)
    
    // Text color of modal dialog buttons
    static let modalDialogButtonTextColor: NSColor = ColorConstants.white90Percent
    
    // Text color of modal dialog buttons
    static let fxUnitButtonTextColor: NSColor = ColorConstants.white60Percent
    
    static let modalDialogButtonGradient: NSGradient = {
        
        let backgroundStart = ColorConstants.white50Percent
        let backgroundEnd =  ColorConstants.white20Percent
        return NSGradient(starting: backgroundStart, ending: backgroundEnd)!
    }()
    
    static let fxUnitButtonGradient: NSGradient = {
        
        let backgroundStart = ColorConstants.white35Percent
        let backgroundEnd =  ColorConstants.white10Percent
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let fxUnitButtonGradient_disabled: NSGradient = {
        
        let backgroundStart = NSColor(calibratedWhite: 0.175, alpha: 1)
        let backgroundEnd =  ColorConstants.white10Percent
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    // Text color of modal dialog buttons
    static let modalDialogButtonTextColor_disabled: NSColor = ColorConstants.white50Percent
    
    // Text color of modal dialog buttons
    static let fxUnitButtonTextColor_disabled: NSColor = ColorConstants.white45Percent
    
    static let modalDialogButtonGradient_disabled: NSGradient = {
        
        let backgroundStart = ColorConstants.white25Percent
        let backgroundEnd =  ColorConstants.white10Percent
        return NSGradient(starting: backgroundStart, ending: backgroundEnd)!
    }()
    
    // Fill color of modal dialog navigation buttons (search)
    static let modalDialogNavButtonColor: NSColor = ColorConstants.white45Percent
    
    // Fill color of text in modal dialog navigation buttons (search)
    static let modalDialogNavButtonTextColor: NSColor = ColorConstants.white90Percent
    
    // Color of cursor inside text fields
    static let textFieldCursorColor: NSColor = ColorConstants.white50Percent
    
    // Background color of the popover view
    static let popoverBackgroundColor: NSColor = ColorConstants.white15Percent
}
