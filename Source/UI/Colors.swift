/*
    Container for colors used by the UI
*/

import Cocoa

struct Colors {
    
    struct Constants {
        
        static let white7Percent: NSColor = NSColor(white: 0.07, alpha: 1)
        static let white8Percent: NSColor = NSColor(white: 0.08, alpha: 1)
        static let white10Percent: NSColor = NSColor(white: 0.1, alpha: 1)
        static let white13_5Percent: NSColor = NSColor(white: 0.135, alpha: 1)
        static let white15Percent: NSColor = NSColor(white: 0.15, alpha: 1)
        static let white17Percent: NSColor = NSColor(white: 0.17, alpha: 1)
        static let white20Percent: NSColor = NSColor(white: 0.2, alpha: 1)
        static let white22Percent: NSColor = NSColor(white: 0.22, alpha: 1)
        static let white25Percent: NSColor = NSColor(white: 0.25, alpha: 1)
        static let white30Percent: NSColor = NSColor(white: 0.3, alpha: 1)
        static let white35Percent: NSColor = NSColor(white: 0.35, alpha: 1)
        static let white37Percent: NSColor = NSColor(white: 0.37, alpha: 1)
        static let white40Percent: NSColor = NSColor(white: 0.4, alpha: 1)
        static let white45Percent: NSColor = NSColor(white: 0.45, alpha: 1)
        static let white50Percent: NSColor = NSColor(white: 0.5, alpha: 1)
        static let white55Percent: NSColor = NSColor(white: 0.55, alpha: 1)
        static let white60Percent: NSColor = NSColor(white: 0.6, alpha: 1)
        static let white65Percent: NSColor = NSColor(white: 0.65, alpha: 1)
        static let white70Percent: NSColor = NSColor(white: 0.7, alpha: 1)
        static let white75Percent: NSColor = NSColor(white: 0.75, alpha: 1)
        static let white80Percent: NSColor = NSColor(white: 0.8, alpha: 1)
        static let white85Percent: NSColor = NSColor(white: 0.85, alpha: 1)
        static let white90Percent: NSColor = NSColor(white: 0.9, alpha: 1)
        
        static let green60Percent: NSColor = NSColor(red: 0, green: 0.6, blue: 0, alpha: 1)
        static let green75Percent: NSColor = NSColor(red: 0, green: 0.75, blue: 0, alpha: 1)
        
        static let aqua: NSColor = NSColor(red: 0, green: 0.5, blue: 1, alpha: 1)
        
        static let lava: NSColor = NSColor(red: 0.73, green: 0.294, blue: 0.153, alpha: 1)
    }
    
    static var windowBackgroundColor: NSColor {
        return ColorSchemes.systemScheme.general.backgroundColor
    }
    
    static var appLogoColor: NSColor {
        return ColorSchemes.systemScheme.general.appLogoColor
    }
    
    static var viewControlButtonColor: NSColor {
        return ColorSchemes.systemScheme.general.viewControlButtonColor
    }
    
    static var functionButtonColor: NSColor {
        return ColorSchemes.systemScheme.general.functionButtonColor
    }
    
    static var functionButtonGradient: NSGradient {
        
        let color = ColorSchemes.systemScheme.general.functionButtonColor
        return NSGradient(starting: color, ending: color.darkened(40))!
    }
    
    static var functionButtonGradient_disabled: NSGradient {
        
        let color = ColorSchemes.systemScheme.general.functionButtonColor.darkened(50)
        return NSGradient(starting: color, ending: color.darkened(50))!
    }
    
    static var textButtonMenuGradient: NSGradient {
        
        let color = ColorSchemes.systemScheme.general.textButtonMenuColor
        return NSGradient(starting: color, ending: color.darkened(40))!
    }
    
    static var textButtonMenuGradient_disabled: NSGradient {
        
        let color = ColorSchemes.systemScheme.general.textButtonMenuColor
        return NSGradient(starting: color, ending: color.darkened(50))!
    }
    
    static var toggleButtonOffStateColor: NSColor {
        return ColorSchemes.systemScheme.general.toggleButtonOffStateColor
    }
    
    static var mainCaptionTextColor: NSColor {
        return ColorSchemes.systemScheme.general.mainCaptionTextColor
    }
    
    static var tabButtonTextColor: NSColor {
        return ColorSchemes.systemScheme.general.tabButtonTextColor
    }
    
    static var selectedTabButtonTextColor: NSColor {
        return ColorSchemes.systemScheme.general.selectedTabButtonTextColor
    }
    
    static var selectedTabButtonColor: NSColor {
        return ColorSchemes.systemScheme.general.selectedTabButtonColor
    }
    
    static var buttonMenuTextColor: NSColor {
        return ColorSchemes.systemScheme.general.buttonMenuTextColor
    }
    
    static var disabledFunctionButtonTextColor: NSColor {
        return ColorSchemes.systemScheme.general.buttonMenuTextColor.darkened(70)
    }
    
    static var tabViewButtonSelectionBoxColor: NSColor {
        return ColorSchemes.systemScheme.general.selectedTabButtonColor
    }
    
    struct Player {
        
        static var trackInfoTitleTextColor: NSColor {
            return ColorSchemes.systemScheme.player.trackInfoPrimaryTextColor
        }
        
        static var trackInfoArtistAlbumTextColor: NSColor {
            return ColorSchemes.systemScheme.player.trackInfoSecondaryTextColor
        }
        
        static var trackInfoChapterTextColor: NSColor {
            return ColorSchemes.systemScheme.player.trackInfoTertiaryTextColor
        }
        
        static var trackTimesTextColor: NSColor {
            return ColorSchemes.systemScheme.player.sliderValueTextColor
        }
        
        static var feedbackTextColor: NSColor {
            return ColorSchemes.systemScheme.player.sliderValueTextColor
        }
        
        static var progressArcTextColor: NSColor {
            return ColorSchemes.systemScheme.player.trackInfoSecondaryTextColor
        }
        
        static var progressArcForegroundColor: NSColor {
            return ColorSchemes.systemScheme.player.sliderForegroundColor
        }
        
        static var progressArcBackgroundColor: NSColor {
            return ColorSchemes.systemScheme.player.sliderBackgroundColor
        }
        
        // Updates the cached NSGradient objects used by the player's seek slider
        static func updateSliderColors() {
            
            updateSliderBackgroundGradient()
            updateSliderForegroundGradient()
        }
        
        static func updateSliderBackgroundColor() {
            updateSliderBackgroundGradient()
        }
        
        private static func updateSliderBackgroundGradient() {
            
            let endColor = ColorSchemes.systemScheme.player.sliderBackgroundColor
            
            switch ColorSchemes.systemScheme.player.sliderBackgroundGradientType {
                
            case .none:
                
                _sliderBackgroundGradient = NSGradient(starting: endColor, ending: endColor)!
                
            case .darken:
                
                let amount = ColorSchemes.systemScheme.player.sliderBackgroundGradientAmount
                let startColor = endColor.darkened(CGFloat(amount))
                
                _sliderBackgroundGradient = NSGradient(starting: startColor, ending: endColor)!
                
            case .brighten:
                
                let amount = ColorSchemes.systemScheme.player.sliderBackgroundGradientAmount
                let startColor = endColor.brightened(CGFloat(amount))
                
                _sliderBackgroundGradient = NSGradient(starting: startColor, ending: endColor)!
            }
        }
        
        // Cached background gradient used by the player's seek slider (to avoid repeated recomputations)
        static var _sliderBackgroundGradient: NSGradient = {
            
            // Default value
            
            let backgroundStart = Constants.white20Percent
            let backgroundEnd =  Constants.white40Percent
            return NSGradient(starting: backgroundStart, ending: backgroundEnd)!
        }()
        
        static var sliderBackgroundGradient: NSGradient {
            return _sliderBackgroundGradient
        }
        
        static func updateSliderForegroundColor() {
            updateSliderForegroundGradient()
        }
        
        private static func updateSliderForegroundGradient() {
            
            let startColor = ColorSchemes.systemScheme.player.sliderForegroundColor
            
            switch ColorSchemes.systemScheme.player.sliderForegroundGradientType {
                
            case .none:
                
                _sliderForegroundGradient = NSGradient(starting: startColor, ending: startColor)!
                
            case .darken:
                
                let amount = ColorSchemes.systemScheme.player.sliderForegroundGradientAmount
                let endColor = startColor.darkened(CGFloat(amount))
                
                _sliderForegroundGradient = NSGradient(starting: startColor, ending: endColor)!
                
            case .brighten:
                
                let amount = ColorSchemes.systemScheme.player.sliderForegroundGradientAmount
                let endColor = startColor.brightened(CGFloat(amount))
                
                _sliderForegroundGradient = NSGradient(starting: startColor, ending: endColor)!
            }
        }
        
        // Cached foreground gradient used by the player's seek slider (to avoid repeated recomputations)
        static var _sliderForegroundGradient: NSGradient = {
            
            // Default value
            
            let foregroundStart = Constants.white70Percent
            let foregroundEnd =  Constants.white50Percent
            return NSGradient(starting: foregroundStart, ending: foregroundEnd)!
        }()
        
        static var sliderForegroundGradient: NSGradient {
            return _sliderForegroundGradient
        }
        
        static var sliderForegroundColor: NSColor {
            return ColorSchemes.systemScheme.player.sliderForegroundColor
        }
        
        static var seekBarLoopColor: NSColor {
            return ColorSchemes.systemScheme.player.sliderLoopSegmentColor
        }
        
        static var sliderKnobColor: NSColor {
            
            return ColorSchemes.systemScheme.player.sliderKnobColorSameAsForeground ? ColorSchemes.systemScheme.player.sliderForegroundColor : ColorSchemes.systemScheme.player.sliderKnobColor
        }
    }
    
    struct Playlist {
        
        static var trackNameTextColor: NSColor {
            return ColorSchemes.systemScheme.playlist.trackNameTextColor
        }
        
        static var groupNameTextColor: NSColor {
            return ColorSchemes.systemScheme.playlist.groupNameTextColor
        }
        
        static var indexDurationTextColor: NSColor {
            return ColorSchemes.systemScheme.playlist.indexDurationTextColor
        }
        
        static var trackNameSelectedTextColor: NSColor {
            return ColorSchemes.systemScheme.playlist.trackNameSelectedTextColor
        }
        
        static var groupNameSelectedTextColor: NSColor {
            return ColorSchemes.systemScheme.playlist.groupNameSelectedTextColor
        }
        
        static var indexDurationSelectedTextColor: NSColor {
            return ColorSchemes.systemScheme.playlist.indexDurationSelectedTextColor
        }
        
        static var playingTrackIconColor: NSColor {
            return ColorSchemes.systemScheme.playlist.playingTrackIconColor
        }
        
        static var playingTrackIconSelectedRowsColor: NSColor {
            return ColorSchemes.systemScheme.playlist.playingTrackIconSelectedRowsColor
        }
        
        static var selectionBoxColor: NSColor {
            return ColorSchemes.systemScheme.playlist.selectionBoxColor
        }
        
        static var groupIconColor: NSColor {
            return ColorSchemes.systemScheme.playlist.groupIconColor
        }
        
        static var groupIconSelectedRowsColor: NSColor {
            return ColorSchemes.systemScheme.playlist.groupIconSelectedRowsColor
        }
        
        static var groupDisclosureTriangleColor: NSColor {
            return ColorSchemes.systemScheme.playlist.groupDisclosureTriangleColor
        }
        
        static var groupDisclosureTriangleSelectedRowsColor: NSColor {
            return ColorSchemes.systemScheme.playlist.groupDisclosureTriangleSelectedRowsColor
        }
        
        static var summaryInfoColor: NSColor {
            return ColorSchemes.systemScheme.playlist.summaryInfoColor
        }
    }
    
    struct Effects {
        
        static var functionCaptionTextColor: NSColor {
            return ColorSchemes.systemScheme.effects.functionCaptionTextColor
        }
        
        static var functionValueTextColor: NSColor {
            return ColorSchemes.systemScheme.effects.functionValueTextColor
        }
        
        static var sliderBackgroundColor: NSColor {
            return ColorSchemes.systemScheme.effects.sliderBackgroundColor
        }
        
        static func sliderKnobColorForState(_ state: EffectsUnitState) -> NSColor {
            
            let useForegroundColor: Bool = ColorSchemes.systemScheme.effects.sliderKnobColorSameAsForeground
            
            switch state {
                
            case .active:   return useForegroundColor ? Colors.Effects.activeUnitStateColor : ColorSchemes.systemScheme.effects.sliderKnobColor
                
            case .bypassed: return useForegroundColor ? Colors.Effects.bypassedUnitStateColor : ColorSchemes.systemScheme.effects.sliderKnobColor
                
            case .suppressed:   return useForegroundColor ? Colors.Effects.suppressedUnitStateColor : ColorSchemes.systemScheme.effects.sliderKnobColor
                
            }
        }
        
        static var sliderTickColor: NSColor {
            return ColorSchemes.systemScheme.effects.sliderTickColor
        }
        
        static var activeUnitStateColor: NSColor {
            return ColorSchemes.systemScheme.effects.activeUnitStateColor
        }
        
        static var bypassedUnitStateColor: NSColor {
            return ColorSchemes.systemScheme.effects.bypassedUnitStateColor
        }
        
        static var suppressedUnitStateColor: NSColor {
            return ColorSchemes.systemScheme.effects.suppressedUnitStateColor
        }
        
        static var activeSliderGradient: NSGradient {
            
            let startColor = ColorSchemes.systemScheme.effects.activeUnitStateColor
            
            switch ColorSchemes.systemScheme.effects.sliderForegroundGradientType {
                
            case .none:
                
                return NSGradient(starting: startColor, ending: startColor)!
                
            case .darken:
                
                let amount = ColorSchemes.systemScheme.effects.sliderForegroundGradientAmount
                let endColor = startColor.darkened(CGFloat(amount))
                
                return NSGradient(starting: startColor, ending: endColor)!
                
            case .brighten:
                
                let amount = ColorSchemes.systemScheme.effects.sliderForegroundGradientAmount
                let endColor = startColor.brightened(CGFloat(amount))
                
                return NSGradient(starting: startColor, ending: endColor)!
            }
        }
        
        static var bypassedSliderGradient: NSGradient {
            
            let startColor = ColorSchemes.systemScheme.effects.bypassedUnitStateColor
            
            switch ColorSchemes.systemScheme.effects.sliderForegroundGradientType {
                
            case .none:
                
                return NSGradient(starting: startColor, ending: startColor)!
                
            case .darken:
                
                let amount = ColorSchemes.systemScheme.effects.sliderForegroundGradientAmount
                let endColor = startColor.darkened(CGFloat(amount))
                
                return NSGradient(starting: startColor, ending: endColor)!
                
            case .brighten:
                
                let amount = ColorSchemes.systemScheme.effects.sliderForegroundGradientAmount
                let endColor = startColor.brightened(CGFloat(amount))
                
                return NSGradient(starting: startColor, ending: endColor)!
            }
        }
        
        static var suppressedSliderGradient: NSGradient {
            
            let startColor = ColorSchemes.systemScheme.effects.suppressedUnitStateColor
            
            switch ColorSchemes.systemScheme.effects.sliderForegroundGradientType {
                
            case .none:
                
                return NSGradient(starting: startColor, ending: startColor)!
                
            case .darken:
                
                let amount = ColorSchemes.systemScheme.effects.sliderForegroundGradientAmount
                let endColor = startColor.darkened(CGFloat(amount))
                
                return NSGradient(starting: startColor, ending: endColor)!
                
            case .brighten:
                
                let amount = ColorSchemes.systemScheme.effects.sliderForegroundGradientAmount
                let endColor = startColor.brightened(CGFloat(amount))
                
                return NSGradient(starting: startColor, ending: endColor)!
            }
        }
        
        static var sliderBackgroundGradient: NSGradient {
            
            let endColor = ColorSchemes.systemScheme.effects.sliderBackgroundColor
            
            switch ColorSchemes.systemScheme.effects.sliderBackgroundGradientType {
                
            case .none:
                
                return NSGradient(starting: endColor, ending: endColor)!
                
            case .darken:
                
                let amount = ColorSchemes.systemScheme.effects.sliderBackgroundGradientAmount
                let startColor = endColor.darkened(CGFloat(amount))
                
                return NSGradient(starting: startColor, ending: endColor)!
                
            case .brighten:
                
                let amount = ColorSchemes.systemScheme.effects.sliderBackgroundGradientAmount
                let startColor = endColor.brightened(CGFloat(amount))
                
                return NSGradient(starting: startColor, ending: endColor)!
            }
        }
        
        static var defaultSliderBackgroundGradient: NSGradient {
            return NSGradient(starting: Constants.white40Percent, ending: Constants.white20Percent)!
        }
        
        // Fill color of all slider knobs
        static let defaultActiveUnitColor: NSColor = NSColor(red: 0, green: 0.8, blue: 0, alpha: 1)
        static let defaultBypassedUnitColor: NSColor = Constants.white60Percent
        static let defaultSuppressedUnitColor: NSColor = NSColor(red: 0.8, green: 0.6, blue: 0, alpha: 1)
        
        static let defaultActiveSliderGradient: NSGradient = {
            return NSGradient(starting: defaultActiveUnitColor, ending: defaultActiveUnitColor)!
        }()
        
        static let defaultBypassedSliderGradient: NSGradient = {
            return NSGradient(starting: defaultBypassedUnitColor, ending: defaultBypassedUnitColor)!
        }()
        
        static let defaultSuppressedSliderGradient: NSGradient = {
            return NSGradient(starting: defaultSuppressedUnitColor, ending: defaultSuppressedUnitColor)!
        }()
        
        static let defaultPopupMenuGradient: NSGradient = {
            
            let backgroundStart = Constants.white40Percent
            let backgroundEnd =  Constants.white20Percent
            return NSGradient(starting: backgroundStart, ending: backgroundEnd)!
        }()
        
        // Color of the displayed text in popup menus
        static let defaultPopupMenuTextColor: NSColor = Constants.white90Percent
        
        static let defaultTickColor: NSColor = NSColor.black
    }
    
    static let fxFunctionTextColor: NSColor = Constants.white40Percent
    
    static let fxFunctionPopupMenuTextColor: NSColor = Constants.white60Percent
    
    static var filterChartTextColor: NSColor {
        return Effects.functionValueTextColor
    }
    
    static let editorHeaderTextColor: NSColor = Constants.white85Percent
    
    // Color of text inside the playlist (non-selected items)
    static let playlistTextColor: NSColor = Constants.white60Percent
    
    // Color of selected item text inside the playlist
    static let playlistSelectedTextColor: NSColor = NSColor.white
    
    // Color of text inside the playlist (non-selected items)
    static let playlistIndexTextColor: NSColor = Constants.white30Percent
    
    // Color of selected item text inside the playlist
    static let playlistSelectedIndexTextColor: NSColor = Constants.white60Percent
    
    static let playlistGroupIndexTextColor: NSColor = Constants.white45Percent
    
    // Color of selected item text inside the playlist
    static let playlistGroupSelectedIndexTextColor: NSColor = Constants.white70Percent
    
    // Color for playlist grouped views
    static let playlistGroupNameTextColor: NSColor = Constants.white50Percent
    static let playlistGroupNameSelectedTextColor: NSColor = Constants.white80Percent
    
    static let playlistGroupItemTextColor: NSColor = Constants.white60Percent
    static let playlistGroupItemSelectedTextColor: NSColor = NSColor.white
    
    // Fill color of box drawn around selected playlist item
    static let playlistSelectionBoxColor: NSColor = Constants.white15Percent
    
    static let editorSelectionBoxColor: NSColor = NSColor(white: 0.55, alpha: 1)
    
    // Outline color of buttons on modal dialogs
    static let modalDialogButtonOutlineColor: NSColor = NSColor(white: 0.575, alpha: 1)
    
    // Color used to fill tab view buttons
    static let tabViewButtonBackgroundColor: NSColor = NSColor.black
    
    static let transparentColor: NSColor = NSColor.white
    
    // Color used to outline tab view buttons
    static let tabViewButtonOutlineColor: NSColor = NSColor(white: 0.65, alpha: 1)
    
    // Color used for text in tab view buttons
    static let tabViewButtonTextColor: NSColor = Constants.white90Percent
    
    // Color of the arrow drawn on popup menus
    static let popupMenuArrowColor: NSColor = Constants.white10Percent
    
    // A lighter version of popupMenuArrowColor
    static let lightPopupMenuArrowColor: NSColor = Constants.white80Percent
    
    // A lighter version of popupMenuArrowColor
    static let fxUnitPopupMenuArrowColor: NSColor = Constants.white40Percent
    
    static let sliderBarGradient: NSGradient = {
        
        let backgroundStart = Constants.white70Percent
        let backgroundEnd =  Constants.white20Percent
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let popupMenuGradient: NSGradient = {
        
        let backgroundStart = Constants.white35Percent
        let backgroundEnd =  Constants.white10Percent
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    // Gradient used to fill slider bars
    static let sliderBarPlainGradient: NSGradient = {
        
        let backgroundStart = Constants.white40Percent
        let backgroundEnd =  Constants.white10Percent
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let scrollerKnobColor: NSColor = Constants.white40Percent
    static let scrollerBarColor: NSColor = Constants.white25Percent
    
    static let activeSliderBarColoredGradient: NSGradient = {
        
        let backgroundStart = NSColor(red: 0, green: 0.625, blue: 0, alpha: 1)
        let backgroundEnd =  NSColor(red: 0, green: 0.2, blue: 0, alpha: 1)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let bypassedSliderBarColoredGradient: NSGradient = {
        
        let backgroundStart = Constants.white60Percent
        let backgroundEnd =  Constants.white30Percent
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
    
    static let progressBarColoredGradient: NSGradient = {
        
        let backgroundStart = Constants.white70Percent
        let backgroundEnd =  Constants.white40Percent
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let seekBarColoredGradient: NSGradient = Colors.Effects.defaultSliderBackgroundGradient
    
    // Color of the ticks/notches on sliders
    static let sliderNotchColor: NSColor = NSColor.black
    
    // Pop up menu (reverb/EQ/recorder) color
    static let popupMenuColor: NSColor = Constants.white60Percent
    
    // Fill color of box drawn around selected tab view item
    static let tabViewSelectionBoxColor: NSColor = NSColor(white: 0.125, alpha: 1)
    
    // Text color of modal dialog buttons
    static let modalDialogButtonTextColor: NSColor = Constants.white90Percent
    
    // Text color of modal dialog buttons
    static let fxUnitButtonTextColor: NSColor = Constants.white60Percent
    
    static let modalDialogButtonGradient: NSGradient = {
        
        let backgroundStart = Constants.white50Percent
        let backgroundEnd =  Constants.white20Percent
        return NSGradient(starting: backgroundStart, ending: backgroundEnd)!
    }()
    
    static let fxUnitButtonGradient: NSGradient = {
        
        let backgroundStart = Constants.white35Percent
        let backgroundEnd =  Constants.white10Percent
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let fxUnitButtonGradient_disabled: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.175, alpha: 1)
        let backgroundEnd =  Constants.white10Percent
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    // Text color of modal dialog buttons
    static let modalDialogButtonTextColor_disabled: NSColor = Constants.white50Percent
    
    // Text color of modal dialog buttons
    static let fxUnitButtonTextColor_disabled: NSColor = Constants.white45Percent
    
    static let modalDialogButtonGradient_disabled: NSGradient = {
        
        let backgroundStart = Constants.white25Percent
        let backgroundEnd =  Constants.white10Percent
        return NSGradient(starting: backgroundStart, ending: backgroundEnd)!
    }()
    
    // Fill color of modal dialog navigation buttons (search)
    static let modalDialogNavButtonColor: NSColor = Constants.white45Percent
    
    // Fill color of text in modal dialog navigation buttons (search)
    static let modalDialogNavButtonTextColor: NSColor = Constants.white90Percent
    
    // Color of cursor inside text fields
    static let textFieldCursorColor: NSColor = Constants.white50Percent
    
    // Background color of the popover view
    static let popoverBackgroundColor: NSColor = Constants.white15Percent
    
    // Color of text inside any of the container boxes
    static let boxTextColor: NSColor = Constants.white70Percent
}
