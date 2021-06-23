/*
    Container for colors used by the UI
*/

import Cocoa

struct Colors {
    
    private static let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    struct Constants {
        
        static let white7Percent: NSColor = NSColor(white: 0.07, alpha: 1)
        static let white8Percent: NSColor = NSColor(white: 0.08, alpha: 1)
        static let white10Percent: NSColor = NSColor(white: 0.1, alpha: 1)
        static let white15Percent: NSColor = NSColor(white: 0.15, alpha: 1)
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
        
        static let green75Percent: NSColor = NSColor(red: 0, green: 0.75, blue: 0, alpha: 1)
        
        static let aqua: NSColor = NSColor(red: 0, green: 0.5, blue: 1, alpha: 1)
        
        static let lava: NSColor = NSColor(red: 0.73, green: 0.294, blue: 0.153, alpha: 1)
    }
    
    static var windowBackgroundColor: NSColor {
        return colorSchemesManager.systemScheme.general.backgroundColor
    }
    
    static var appLogoColor: NSColor {
        return colorSchemesManager.systemScheme.general.appLogoColor
    }
    
    static var viewControlButtonColor: NSColor {
        return colorSchemesManager.systemScheme.general.viewControlButtonColor
    }
    
    static var functionButtonColor: NSColor {
        return colorSchemesManager.systemScheme.general.functionButtonColor
    }
    
    static var textButtonMenuGradient: NSGradient {
        
        let color = colorSchemesManager.systemScheme.general.textButtonMenuColor
        return NSGradient(starting: color, ending: color.darkened(40))!
    }
    
    static var toggleButtonOffStateColor: NSColor {
        return colorSchemesManager.systemScheme.general.toggleButtonOffStateColor
    }
    
    static var mainCaptionTextColor: NSColor {
        return colorSchemesManager.systemScheme.general.mainCaptionTextColor
    }
    
    static var tabButtonTextColor: NSColor {
        return colorSchemesManager.systemScheme.general.tabButtonTextColor
    }
    
    static var selectedTabButtonTextColor: NSColor {
        return colorSchemesManager.systemScheme.general.selectedTabButtonTextColor
    }
    
    static var selectedTabButtonColor: NSColor {
        return colorSchemesManager.systemScheme.general.selectedTabButtonColor
    }
    
    static var buttonMenuTextColor: NSColor {
        return colorSchemesManager.systemScheme.general.buttonMenuTextColor
    }
    
    struct Player {
        
        static var trackInfoTitleTextColor: NSColor {
            return colorSchemesManager.systemScheme.player.trackInfoPrimaryTextColor
        }
        
        static var trackInfoArtistAlbumTextColor: NSColor {
            return colorSchemesManager.systemScheme.player.trackInfoSecondaryTextColor
        }
        
        static var trackInfoChapterTextColor: NSColor {
            return colorSchemesManager.systemScheme.player.trackInfoTertiaryTextColor
        }
        
        static var trackTimesTextColor: NSColor {
            return colorSchemesManager.systemScheme.player.sliderValueTextColor
        }
        
        static var feedbackTextColor: NSColor {
            return colorSchemesManager.systemScheme.player.sliderValueTextColor
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
            _sliderBackgroundGradient = computeSliderBackgroundGradient()
        }
        
        private static func computeSliderBackgroundGradient() -> NSGradient {
            
            let endColor = colorSchemesManager.systemScheme.player.sliderBackgroundColor
            
            switch colorSchemesManager.systemScheme.player.sliderBackgroundGradientType {
                
            case .none:
                
                return NSGradient(starting: endColor, ending: endColor)!
                
            case .darken:
                
                let amount = colorSchemesManager.systemScheme.player.sliderBackgroundGradientAmount
                let startColor = endColor.darkened(CGFloat(amount))
                
                return NSGradient(starting: startColor, ending: endColor)!
                
            case .brighten:
                
                let amount = colorSchemesManager.systemScheme.player.sliderBackgroundGradientAmount
                let startColor = endColor.brightened(CGFloat(amount))
                
                return NSGradient(starting: startColor, ending: endColor)!
            }
        }
        
        // Cached background gradient used by the player's seek slider (to avoid repeated recomputations)
        static var _sliderBackgroundGradient: NSGradient = computeSliderBackgroundGradient()
        
        static var sliderBackgroundGradient: NSGradient {
            return _sliderBackgroundGradient
        }
        
        static func updateSliderForegroundColor() {
            updateSliderForegroundGradient()
        }
        
        private static func updateSliderForegroundGradient() {
            _sliderForegroundGradient = computeSliderForegroundGradient()
        }
        
        private static func computeSliderForegroundGradient() -> NSGradient {
            
            let startColor = colorSchemesManager.systemScheme.player.sliderForegroundColor
            
            switch colorSchemesManager.systemScheme.player.sliderForegroundGradientType {
                
            case .none:
                
                return NSGradient(starting: startColor, ending: startColor)!
                
            case .darken:
                
                let amount = colorSchemesManager.systemScheme.player.sliderForegroundGradientAmount
                let endColor = startColor.darkened(CGFloat(amount))
                
                return NSGradient(starting: startColor, ending: endColor)!
                
            case .brighten:
                
                let amount = colorSchemesManager.systemScheme.player.sliderForegroundGradientAmount
                let endColor = startColor.brightened(CGFloat(amount))
                
                return NSGradient(starting: startColor, ending: endColor)!
            }
        }
        
        // Cached foreground gradient used by the player's seek slider (to avoid repeated recomputations)
        static var _sliderForegroundGradient: NSGradient = computeSliderForegroundGradient()
        
        static var sliderForegroundGradient: NSGradient {
            return _sliderForegroundGradient
        }
        
        static var sliderForegroundColor: NSColor {
            return colorSchemesManager.systemScheme.player.sliderForegroundColor
        }
        
        static var seekBarLoopColor: NSColor {
            return colorSchemesManager.systemScheme.player.sliderLoopSegmentColor
        }
        
        static var sliderKnobColor: NSColor {
            
            return colorSchemesManager.systemScheme.player.sliderKnobColorSameAsForeground ? colorSchemesManager.systemScheme.player.sliderForegroundColor : colorSchemesManager.systemScheme.player.sliderKnobColor
        }
    }
    
    struct Playlist {
        
        static var trackNameTextColor: NSColor {
            return colorSchemesManager.systemScheme.playlist.trackNameTextColor
        }
        
        static var groupNameTextColor: NSColor {
            return colorSchemesManager.systemScheme.playlist.groupNameTextColor
        }
        
        static var indexDurationTextColor: NSColor {
            return colorSchemesManager.systemScheme.playlist.indexDurationTextColor
        }
        
        static var trackNameSelectedTextColor: NSColor {
            return colorSchemesManager.systemScheme.playlist.trackNameSelectedTextColor
        }
        
        static var groupNameSelectedTextColor: NSColor {
            return colorSchemesManager.systemScheme.playlist.groupNameSelectedTextColor
        }
        
        static var indexDurationSelectedTextColor: NSColor {
            return colorSchemesManager.systemScheme.playlist.indexDurationSelectedTextColor
        }
        
        static var playingTrackIconColor: NSColor {
            return colorSchemesManager.systemScheme.playlist.playingTrackIconColor
        }
        
        static var selectionBoxColor: NSColor {
            return colorSchemesManager.systemScheme.playlist.selectionBoxColor
        }
        
        static var groupIconColor: NSColor {
            return colorSchemesManager.systemScheme.playlist.groupIconColor
        }
        
        static var groupDisclosureTriangleColor: NSColor {
            return colorSchemesManager.systemScheme.playlist.groupDisclosureTriangleColor
        }
        
        static var summaryInfoColor: NSColor {
            return colorSchemesManager.systemScheme.playlist.summaryInfoColor
        }
    }
    
    struct Effects {
        
        static var functionCaptionTextColor: NSColor {
            return colorSchemesManager.systemScheme.effects.functionCaptionTextColor
        }
        
        static var functionValueTextColor: NSColor {
            return colorSchemesManager.systemScheme.effects.functionValueTextColor
        }
        
        static var sliderBackgroundColor: NSColor {
            return colorSchemesManager.systemScheme.effects.sliderBackgroundColor
        }
        
        static func sliderKnobColorForState(_ state: EffectsUnitState) -> NSColor {
            
            let useForegroundColor: Bool = colorSchemesManager.systemScheme.effects.sliderKnobColorSameAsForeground
            let staticKnobColor: NSColor = colorSchemesManager.systemScheme.effects.sliderKnobColor
            
            switch state {
                
            case .active:   return useForegroundColor ? activeUnitStateColor : staticKnobColor
                
            case .bypassed: return useForegroundColor ? bypassedUnitStateColor : staticKnobColor
                
            case .suppressed:   return useForegroundColor ? suppressedUnitStateColor : staticKnobColor
                
            }
        }
        
        static var sliderTickColor: NSColor {
            return colorSchemesManager.systemScheme.effects.sliderTickColor
        }
        
        static var activeUnitStateColor: NSColor {
            return colorSchemesManager.systemScheme.effects.activeUnitStateColor
        }
        
        static var bypassedUnitStateColor: NSColor {
            return colorSchemesManager.systemScheme.effects.bypassedUnitStateColor
        }
        
        static var suppressedUnitStateColor: NSColor {
            return colorSchemesManager.systemScheme.effects.suppressedUnitStateColor
        }
        
        static var activeSliderGradient: NSGradient {
            
            let startColor = colorSchemesManager.systemScheme.effects.activeUnitStateColor
            
            switch colorSchemesManager.systemScheme.effects.sliderForegroundGradientType {
                
            case .none:
                
                return NSGradient(starting: startColor, ending: startColor)!
                
            case .darken:
                
                let amount = colorSchemesManager.systemScheme.effects.sliderForegroundGradientAmount
                let endColor = startColor.darkened(CGFloat(amount))
                
                return NSGradient(starting: startColor, ending: endColor)!
                
            case .brighten:
                
                let amount = colorSchemesManager.systemScheme.effects.sliderForegroundGradientAmount
                let endColor = startColor.brightened(CGFloat(amount))
                
                return NSGradient(starting: startColor, ending: endColor)!
            }
        }
        
        static var bypassedSliderGradient: NSGradient {
            
            let startColor = colorSchemesManager.systemScheme.effects.bypassedUnitStateColor
            
            switch colorSchemesManager.systemScheme.effects.sliderForegroundGradientType {
                
            case .none:
                
                return NSGradient(starting: startColor, ending: startColor)!
                
            case .darken:
                
                let amount = colorSchemesManager.systemScheme.effects.sliderForegroundGradientAmount
                let endColor = startColor.darkened(CGFloat(amount))
                
                return NSGradient(starting: startColor, ending: endColor)!
                
            case .brighten:
                
                let amount = colorSchemesManager.systemScheme.effects.sliderForegroundGradientAmount
                let endColor = startColor.brightened(CGFloat(amount))
                
                return NSGradient(starting: startColor, ending: endColor)!
            }
        }
        
        static var suppressedSliderGradient: NSGradient {
            
            let startColor = colorSchemesManager.systemScheme.effects.suppressedUnitStateColor
            
            switch colorSchemesManager.systemScheme.effects.sliderForegroundGradientType {
                
            case .none:
                
                return NSGradient(starting: startColor, ending: startColor)!
                
            case .darken:
                
                let amount = colorSchemesManager.systemScheme.effects.sliderForegroundGradientAmount
                let endColor = startColor.darkened(CGFloat(amount))
                
                return NSGradient(starting: startColor, ending: endColor)!
                
            case .brighten:
                
                let amount = colorSchemesManager.systemScheme.effects.sliderForegroundGradientAmount
                let endColor = startColor.brightened(CGFloat(amount))
                
                return NSGradient(starting: startColor, ending: endColor)!
            }
        }
        
        static var sliderBackgroundGradient: NSGradient {
            
            let endColor = colorSchemesManager.systemScheme.effects.sliderBackgroundColor
            
            switch colorSchemesManager.systemScheme.effects.sliderBackgroundGradientType {
                
            case .none:
                
                return NSGradient(starting: endColor, ending: endColor)!
                
            case .darken:
                
                let amount = colorSchemesManager.systemScheme.effects.sliderBackgroundGradientAmount
                let startColor = endColor.darkened(CGFloat(amount))
                
                return NSGradient(starting: startColor, ending: endColor)!
                
            case .brighten:
                
                let amount = colorSchemesManager.systemScheme.effects.sliderBackgroundGradientAmount
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
    
    static var filterChartTextColor: NSColor {
        return Effects.functionValueTextColor
    }
    
    // TODO: Rename these constants to reflect that they are constants (not dictated by the system color scheme).
    
    static let editorHeaderTextColor: NSColor = Constants.white85Percent
    
    // Color of text inside the playlist (non-selected items)
    static let defaultLightTextColor: NSColor = Constants.white60Percent
    
    // Color of selected item text inside the playlist
    static let defaultSelectedLightTextColor: NSColor = NSColor.white
    
    // Fill color of box drawn around selected playlist item
    static let playlistSelectionBoxColor: NSColor = Constants.white15Percent
    
    // Color used to outline tab view buttons
    static let tabViewButtonOutlineColor: NSColor = NSColor(white: 0.65, alpha: 1)
    
    // Color used for text in tab view buttons
    static let tabViewButtonTextColor: NSColor = Constants.white90Percent
    
    // Color of the arrow drawn on popup menus
    static let popupMenuArrowColor: NSColor = Constants.white10Percent
    
    // A lighter version of popupMenuArrowColor
    static let lightPopupMenuArrowColor: NSColor = Constants.white80Percent
    
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

    static let scrollerKnobColor: NSColor = Constants.white40Percent
    static let scrollerBarColor: NSColor = Constants.white25Percent
    
    // Color of the ticks/notches on sliders
    static let sliderNotchColor: NSColor = NSColor.black
    
    // Fill color of box drawn around selected tab view item
    static let tabViewSelectionBoxColor: NSColor = NSColor(white: 0.125, alpha: 1)
    
    // Text color of modal dialog buttons
    static let modalDialogButtonTextColor: NSColor = Constants.white90Percent
    
    static let modalDialogButtonGradient: NSGradient = {
        
        let backgroundStart = Constants.white50Percent
        let backgroundEnd =  Constants.white20Percent
        return NSGradient(starting: backgroundStart, ending: backgroundEnd)!
    }()
    
    // Text color of modal dialog buttons
    static let modalDialogButtonTextColor_disabled: NSColor = Constants.white50Percent
    
    static let modalDialogButtonGradient_disabled: NSGradient = {
        
        let backgroundStart = Constants.white25Percent
        let backgroundEnd =  Constants.white10Percent
        return NSGradient(starting: backgroundStart, ending: backgroundEnd)!
    }()
    
    // Fill color of text in modal dialog navigation buttons (search)
    static let modalDialogNavButtonTextColor: NSColor = Constants.white90Percent
    
    // Color of cursor inside text fields
    static let textFieldCursorColor: NSColor = Constants.white50Percent
    
    // Background color of the popover view
    static let popoverBackgroundColor: NSColor = Constants.white15Percent
    
    // Color of text inside any of the container boxes
    static let boxTextColor: NSColor = Constants.white70Percent
}
