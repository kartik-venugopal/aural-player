/*
    Container for colors used by the UI
*/

import Cocoa

struct ColorConstants {
    
    static let white10Percent: NSColor = NSColor(calibratedWhite: 0.1, alpha: 1)
    static let white15Percent: NSColor = NSColor(calibratedWhite: 0.15, alpha: 1)
    static let white20Percent: NSColor = NSColor(calibratedWhite: 0.2, alpha: 1)
    static let white40Percent: NSColor = NSColor(calibratedWhite: 0.4, alpha: 1)
    static let white45Percent: NSColor = NSColor(calibratedWhite: 0.45, alpha: 1)
    static let white50Percent: NSColor = NSColor(calibratedWhite: 0.5, alpha: 1)
    static let white60Percent: NSColor = NSColor(calibratedWhite: 0.6, alpha: 1)
    static let white70Percent: NSColor = NSColor(calibratedWhite: 0.7, alpha: 1)
    static let white80Percent: NSColor = NSColor(calibratedWhite: 0.8, alpha: 1)
    static let white85Percent: NSColor = NSColor(calibratedWhite: 0.85, alpha: 1)
    static let white90Percent: NSColor = NSColor(calibratedWhite: 0.9, alpha: 1)
}

enum ColorScheme: String {

    case darkBackground_lightText
    case lightBackground_darkText
    
}

struct Colors {
    
    static var scheme: ColorScheme = .lightBackground_darkText
    
    static var windowBackgroundColor: NSColor {
        
        switch scheme {
            
        case .darkBackground_lightText:     return NSColor.black
            
        case .lightBackground_darkText:     return ColorConstants.white70Percent
            
        }
    }
    
    static var fxUnitCaptionColor: NSColor {
        
        switch scheme {
            
        case .darkBackground_lightText:     return ColorConstants.white50Percent
            
        case .lightBackground_darkText:     return NSColor.black
            
        }
    }
    
    static var fxUnitFunctionColor: NSColor {
        
        switch scheme {
            
        case .darkBackground_lightText:     return ColorConstants.white40Percent
            
        case .lightBackground_darkText:     return ColorConstants.white10Percent
            
        }
    }
    
    struct Player {
        
        static var titleColor: NSColor {
            
            switch Colors.scheme {
                
            case .darkBackground_lightText: return ColorConstants.white45Percent
                
            case .lightBackground_darkText: return NSColor.black
                
            }
        }
        
        static var artistColor: NSColor {
            
            switch Colors.scheme {
                
            case .darkBackground_lightText: return ColorConstants.white60Percent
                
            case .lightBackground_darkText: return ColorConstants.white15Percent
                
            }
        }
        
        static var trackTimesColor: NSColor {
            
            switch Colors.scheme {
                
            case .darkBackground_lightText: return ColorConstants.white60Percent
                
            case .lightBackground_darkText: return ColorConstants.white10Percent
                
            }
        }
        
        static var infoBoxOverlayColor: NSColor {
            
            switch Colors.scheme {
                
            case .darkBackground_lightText: return NSColor(calibratedWhite: 0, alpha: 0.75)
                
            case .lightBackground_darkText: return NSColor(calibratedWhite: 0.7, alpha: 0.75)
                
            }
        }
    }
    
    // Color of text inside any of the container boxes
    static var boxTextColor: NSColor {
        
        switch scheme {
            
        case .darkBackground_lightText:     return ColorConstants.white70Percent
            
        case .lightBackground_darkText:     return NSColor.black
            
        }
    }
    
    static var fxFunctionTextColor: NSColor {
        
        switch scheme {
            
        case .darkBackground_lightText:     return ColorConstants.white40Percent
            
        case .lightBackground_darkText:     return NSColor.black
            
        }
    }
    
    static let fxFunctionPopupMenuTextColor: NSColor = ColorConstants.white60Percent
    
    static var filterChartTextColor: NSColor {
        
        switch scheme {
            
        case .darkBackground_lightText:     return filterChartTextColor_0
            
        case .lightBackground_darkText:     return filterChartTextColor_1
            
        }
    }
    
    private static let filterChartTextColor_0: NSColor = ColorConstants.white85Percent
    private static let filterChartTextColor_1: NSColor = NSColor.black
    
    static let editorHeaderTextColor: NSColor = ColorConstants.white85Percent
    
    // Color of text inside the playlist (non-selected items)
    static var playlistTextColor: NSColor {
        
        switch scheme {
            
        case .darkBackground_lightText: return playlistTextColor_darkBackground
            
        case .lightBackground_darkText: return playlistTextColor_lightBackground
            
        }
    }
    
    static let playlistTextColor_darkBackground: NSColor = NSColor(calibratedWhite: 0.6, alpha: 1)
    static let playlistTextColor_lightBackground: NSColor = NSColor.black
    
    // Color of selected item text inside the playlist
    
    static var playlistSelectedTextColor: NSColor {
        
        switch scheme {
            
        case .darkBackground_lightText: return playlistSelectedTextColor_darkBackground
            
        case .lightBackground_darkText: return playlistSelectedTextColor_lightBackground
            
        }
    }
    
    private static let playlistSelectedTextColor_darkBackground: NSColor = NSColor(calibratedWhite: 1, alpha: 1)
    private static let playlistSelectedTextColor_lightBackground: NSColor = NSColor.black
    
    // Color of text inside the playlist (non-selected items)
    static var playlistIndexTextColor: NSColor {
        
        switch scheme {
            
        case .darkBackground_lightText: return playlistIndexTextColor_0
            
        case .lightBackground_darkText: return playlistIndexTextColor_1
            
        }
    }
    
    private static let playlistIndexTextColor_0: NSColor = NSColor(calibratedWhite: 0.3, alpha: 1)
    private static let playlistIndexTextColor_1: NSColor = NSColor.black
    
    // Color of selected item text inside the playlist
    static var playlistSelectedIndexTextColor: NSColor {
        
        switch scheme {
            
        case .darkBackground_lightText: return playlistSelectedIndexTextColor_0
            
        case .lightBackground_darkText: return playlistSelectedIndexTextColor_1
            
        }
    }
    
    private static let playlistSelectedIndexTextColor_0: NSColor = NSColor(calibratedWhite: 0.6, alpha: 1)
    private static let playlistSelectedIndexTextColor_1: NSColor = NSColor.black
    
    static let playlistGroupIndexTextColor: NSColor = NSColor(calibratedWhite: 0.45, alpha: 1)
    // Color of selected item text inside the playlist
    static let playlistGroupSelectedIndexTextColor: NSColor = NSColor(calibratedWhite: 0.7, alpha: 1)
    
    static let overlayBackgroundColor: NSColor = NSColor(calibratedWhite: 0, alpha: 0.8)

    static let playlistGapTextColor: NSColor = NSColor(calibratedWhite: 0.8, alpha: 1)
    static let playlistSelectedGapTextColor: NSColor = NSColor(calibratedWhite: 1, alpha: 1)
    
    // Color for playlist grouped views
    static var playlistGroupNameTextColor: NSColor {
        
        switch scheme {
            
        case .darkBackground_lightText: return playlistGroupNameTextColor_darkBackground
            
        case .lightBackground_darkText: return playlistGroupNameTextColor_lightBackground
            
        }
    }
    
    static let playlistGroupNameTextColor_darkBackground: NSColor = NSColor(calibratedWhite: 0.5, alpha: 1)
    static let playlistGroupNameTextColor_lightBackground: NSColor = ColorConstants.white10Percent
    
    static var playlistGroupNameSelectedTextColor: NSColor {
        
        switch scheme {
            
        case .darkBackground_lightText: return playlistGroupNameSelectedTextColor_darkBackground
            
        case .lightBackground_darkText: return playlistGroupNameSelectedTextColor_lightBackground
            
        }
    }
    
    static let playlistGroupNameSelectedTextColor_darkBackground: NSColor = NSColor(calibratedWhite: 0.8, alpha: 1)
    static let playlistGroupNameSelectedTextColor_lightBackground: NSColor = ColorConstants.white70Percent
    
    static var playlistGroupItemTextColor: NSColor {
        
        switch scheme {
            
        case .darkBackground_lightText: return playlistGroupItemTextColor_darkBackground
            
        case .lightBackground_darkText: return playlistGroupItemTextColor_lightBackground
            
        }
    }
    
    static let playlistGroupItemTextColor_darkBackground: NSColor = NSColor(calibratedWhite: 0.6, alpha: 1)
    static let playlistGroupItemTextColor_lightBackground: NSColor = NSColor.black
    
    static var playlistGroupItemSelectedTextColor: NSColor {
        
        switch scheme {
            
        case .darkBackground_lightText: return playlistGroupItemSelectedTextColor_darkBackground
            
        case .lightBackground_darkText: return playlistGroupItemSelectedTextColor_lightBackground
            
        }
    }
    
    static let playlistGroupItemSelectedTextColor_darkBackground: NSColor = NSColor(calibratedWhite: 1, alpha: 1)
    static let playlistGroupItemSelectedTextColor_lightBackground: NSColor = ColorConstants.white80Percent
    
    // Fill color of box drawn around selected playlist item
    
    static var playlistSelectionBoxColor: NSColor {
        
        switch scheme {
            
        case .darkBackground_lightText: return playlistSelectionBoxColor_darkBackground
            
        case .lightBackground_darkText: return playlistSelectionBoxColor_lightBackground
            
        }
    }
    
    static let playlistSelectionBoxColor_darkBackground: NSColor = NSColor(calibratedWhite: 0.15, alpha: 1)
    static let playlistSelectionBoxColor_lightBackground: NSColor = NSColor(calibratedWhite: 0.5, alpha: 1)
    
    static let editorSelectionBoxColor: NSColor = NSColor(calibratedWhite: 0.55, alpha: 1)
    
    // Fill color of all slider knobs
    static var neutralKnobColor: NSColor {
        
        switch scheme {
            
        case .darkBackground_lightText: return neutralKnobColor_darkBackground
            
        case .lightBackground_darkText: return neutralKnobColor_lightBackground
            
        }
    }
    
    static let neutralKnobColor_darkBackground: NSColor = NSColor(white: 0.5, alpha: 1.0)
    static let neutralKnobColor_lightBackground: NSColor = NSColor(white: 0, alpha: 1.0)
    
    static var seekBarPlainGradient: NSGradient {
        
        switch scheme {
            
        case .darkBackground_lightText: return seekBarPlainGradient_darkBackground
            
        case .lightBackground_darkText: return seekBarPlainGradient_lightBackground
            
        }
    }
    
    static let seekBarPlainGradient_darkBackground: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.4, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.2, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let seekBarPlainGradient_lightBackground: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.3, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.4, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static var seekBarColoredGradient: NSGradient {
        
        switch scheme {
            
        case .darkBackground_lightText: return seekBarColoredGradient_darkBackground
            
        case .lightBackground_darkText: return seekBarColoredGradient_lightBackground
            
        }
    }
    
    static let seekBarColoredGradient_darkBackground: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.6, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.4, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let seekBarColoredGradient_lightBackground: NSGradient = {
        
        let backgroundStart = NSColor(white: 0, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.2, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static var activeKnobColor: NSColor {
        
        switch scheme {
            
        case .darkBackground_lightText:     return activeKnobColor_darkBackground
            
        case .lightBackground_darkText:     return activeKnobColor_lightBackground
            
        }
    }
    
    static let activeKnobColor_darkBackground: NSColor = NSColor(red: 0, green: 0.625, blue: 0, alpha: 1)
    
    static let activeKnobColor_lightBackground: NSColor = NSColor(red: 0, green: 0.5, blue: 0, alpha: 1)
    
    static let bypassedKnobColor: NSColor = NSColor(calibratedWhite: 0.4, alpha: 1)
    
    static var suppressedKnobColor: NSColor {
        
        switch scheme {
            
        case .darkBackground_lightText:     return suppressedKnobColor_darkBackground
            
        case .lightBackground_darkText:     return suppressedKnobColor_lightBackground
            
        }
    }
    
    static let suppressedKnobColor_darkBackground: NSColor = NSColor(red: 0.8, green: 0.6, blue: 0, alpha: 1)
    
    static let suppressedKnobColor_lightBackground: NSColor = NSColor(red: 0.66, green: 0.5, blue: 0, alpha: 1)
    
    // Outline color of buttons on modal dialogs
    static let modalDialogButtonOutlineColor: NSColor = NSColor(calibratedWhite: 0.575, alpha: 1)
    
    // Color used to fill tab view buttons
    static var tabViewButtonBackgroundColor: NSColor {return Colors.windowBackgroundColor}
    
    static let transparentColor: NSColor = NSColor.white
    
    // Color used to outline tab view buttons
    static let tabViewButtonOutlineColor: NSColor = NSColor(calibratedWhite: 0.65, alpha: 1)
    
    // Color used for text in tab view buttons
    static let tabViewButtonTextColor: NSColor = ColorConstants.white90Percent
    
    // Color of the arrow drawn on popup menus
    static var popupMenuArrowColor: NSColor {
    
        switch scheme {
            
        case .darkBackground_lightText:     return popupMenuArrowColor_darkBackground
            
        case .lightBackground_darkText:     return popupMenuArrowColor_lightBackground
            
        }
    }
    
    private static let popupMenuArrowColor_darkBackground: NSColor = ColorConstants.white10Percent
    private static let popupMenuArrowColor_lightBackground: NSColor = ColorConstants.white70Percent
    
    // A lighter version of popupMenuArrowColor
    static let lightPopupMenuArrowColor: NSColor = NSColor(calibratedWhite: 0.8, alpha: 1)
    
    // A lighter version of popupMenuArrowColor
    static let fxUnitPopupMenuArrowColor: NSColor = NSColor(calibratedWhite: 0.4, alpha: 1)
    
    // Color of the displayed text in popup menus
    static let popupMenuTextColor: NSColor = ColorConstants.white90Percent

    static let sliderBarGradient: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.4, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.1, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let popupMenuGradient: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.35, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.1, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static var presetsPopupMenuGradient: NSGradient {
        
        switch scheme {
            
        case .darkBackground_lightText:     return presetsPopupMenuGradient_darkBackground
            
        case .lightBackground_darkText:     return presetsPopupMenuGradient_lightBackground
            
        }
    }
    
    private static let presetsPopupMenuGradient_darkBackground: NSGradient = {
        
        let backgroundStart = ColorConstants.white70Percent
        let backgroundEnd =  ColorConstants.white20Percent
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    private static let presetsPopupMenuGradient_lightBackground: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.35, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.1, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    // Gradient used to fill slider bars
    static var sliderBarPlainGradient: NSGradient {
        
        switch scheme {
            
        case .darkBackground_lightText:     return sliderBarPlainGradient_darkBackground
            
        case .lightBackground_darkText:     return sliderBarPlainGradient_lightBackground
            
        }
    }
    
    // Gradient used to fill slider bars
    static let sliderBarPlainGradient_darkBackground: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.4, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.1, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    // Gradient used to fill slider bars
    static let sliderBarPlainGradient_lightBackground: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.2, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let scrollerKnobColor: NSColor = NSColor(white: 0.4, alpha: 1.0)
    static let scrollerBarColor: NSColor = NSColor(white: 0.25, alpha: 1.0)
    
    static let neutralSliderBarColoredGradient: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.6, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.4, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static var activeSliderBarColoredGradient: NSGradient {
        
        switch scheme {
            
        case .darkBackground_lightText:     return activeSliderBarColoredGradient_darkBackground
            
        case .lightBackground_darkText:     return activeSliderBarColoredGradient_lightBackground
            
        }
    }
    
    static let activeSliderBarColoredGradient_darkBackground: NSGradient = {
        
        let backgroundStart = NSColor(red: 0, green: 0.625, blue: 0, alpha: 1)
        let backgroundEnd =  NSColor(red: 0, green: 0.2, blue: 0, alpha: 1)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let activeSliderBarColoredGradient_lightBackground: NSGradient = {
        
        let backgroundStart = NSColor(red: 0, green: 0.5, blue: 0, alpha: 1)
        let backgroundEnd =  NSColor(red: 0, green: 0.3, blue: 0, alpha: 1)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static var bypassedSliderBarColoredGradient: NSGradient {
        
        switch scheme {
            
        case .darkBackground_lightText:     return bypassedSliderBarColoredGradient_darkBackground
            
        case .lightBackground_darkText:     return bypassedSliderBarColoredGradient_lightBackground
            
        }
    }
    
    static let bypassedSliderBarColoredGradient_darkBackground: NSGradient = {
        
        let backgroundStart = NSColor(calibratedWhite: 0.6, alpha: 1)
        let backgroundEnd =  NSColor(calibratedWhite: 0.3, alpha: 1)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let bypassedSliderBarColoredGradient_lightBackground: NSGradient = {
        
        let backgroundStart = NSColor(calibratedWhite: 0.4, alpha: 1)
        let backgroundEnd =  NSColor(calibratedWhite: 0.2, alpha: 1)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static var suppressedSliderBarColoredGradient: NSGradient {
     
        switch scheme {
            
        case .darkBackground_lightText:     return suppressedSliderBarColoredGradient_darkBackground
            
        case .lightBackground_darkText:     return suppressedSliderBarColoredGradient_lightBackground
        }
        
    }
    
    static let suppressedSliderBarColoredGradient_darkBackground: NSGradient = {
        
        let backgroundStart = NSColor(red: 0.8, green: 0.6, blue: 0, alpha: 1)
        let backgroundEnd =  NSColor(red: 0.27, green: 0.2, blue: 0, alpha: 1)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let suppressedSliderBarColoredGradient_lightBackground: NSGradient = {
        
        let backgroundStart = NSColor(red: 0.66, green: 0.5, blue: 0, alpha: 1)
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
        
        let backgroundStart = NSColor(red: 0, green: 0.6, blue: 0, alpha: 1)
        let backgroundEnd =  NSColor(red: 0, green: 0.3, blue: 0, alpha: 1)
        
//        let backgroundStart = NSColor(calibratedWhite: 1, alpha: 1)
//        let backgroundEnd =  NSColor(calibratedWhite: 0.6, alpha: 1)
        
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    
    
    static let progressBarColoredGradient: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.7, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.4, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    // Color of the ticks/notches on sliders
//    static let sliderNotchColor: NSColor = NSColor(calibratedWhite: 0, alpha: 1)
    
    // Color of the ticks/notches on sliders
    static var sliderNotchColor: NSColor {
    
        switch scheme {
            
        case .darkBackground_lightText:     return sliderNotchColor_0
            
        case .lightBackground_darkText:     return sliderNotchColor_1
            
        }
    }
    
    private static let sliderNotchColor_0: NSColor = NSColor(calibratedWhite: 0, alpha: 1)
    private static let sliderNotchColor_1: NSColor = NSColor(calibratedWhite: 0.75, alpha: 1)
    
    // Pop up menu (reverb/EQ/recorder) color
    static let popupMenuColor: NSColor = NSColor(calibratedWhite: 0.6, alpha: 1)
    
    // Fill color of box drawn around selected tab view item
    static var tabViewSelectionBoxColor: NSColor {
    
        switch scheme {
            
        case .darkBackground_lightText:     return tabViewSelectionBoxColor_0
            
        case .lightBackground_darkText:     return tabViewSelectionBoxColor_1
            
        }
    }
    
    private static let tabViewSelectionBoxColor_0: NSColor = NSColor(calibratedWhite: 0.125, alpha: 1)
    private static let tabViewSelectionBoxColor_1: NSColor = ColorConstants.white50Percent
    
    // Text color of modal dialog buttons
    static let modalDialogButtonTextColor: NSColor = NSColor(calibratedWhite: 0.9, alpha: 1)
    
    // Text color of modal dialog buttons
    static let fxUnitButtonTextColor: NSColor = NSColor(calibratedWhite: 0.6, alpha: 1)
    
    static let modalDialogButtonGradient: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.5, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.2, alpha: 1.0)
        return NSGradient(starting: backgroundStart, ending: backgroundEnd)!
    }()
    
    static let fxUnitButtonGradient: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.35, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.1, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let fxUnitButtonGradient_disabled: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.175, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.1, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    // Text color of modal dialog buttons
    static let modalDialogButtonTextColor_disabled: NSColor = NSColor(calibratedWhite: 0.5, alpha: 1)
    
    // Text color of modal dialog buttons
    static let fxUnitButtonTextColor_disabled: NSColor = NSColor(calibratedWhite: 0.45, alpha: 1)
    
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
    
    static var eqSelector_unselectedTextColor: NSColor {
        
        switch scheme {
            
        case .darkBackground_lightText:     return ColorConstants.white40Percent
            
        case .lightBackground_darkText:     return Colors.fxFunctionTextColor
            
        }
    }
    
    static var eqSelector_selectedTextColor: NSColor {
        
        switch scheme {
            
        case .darkBackground_lightText:     return ColorConstants.white60Percent
            
        case .lightBackground_darkText:     return ColorConstants.white60Percent
            
        }
    }
}
