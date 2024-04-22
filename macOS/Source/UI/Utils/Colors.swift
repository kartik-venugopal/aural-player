//
//  Colors.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    Container for colors used by the UI
*/

import Cocoa

struct Colors {
    
    private static let colorSchemesManager: ColorSchemesManager = colorSchemesManager
    
    static var defaultSliderForegroundColor: NSColor {
        .white70Percent
    }
    
//    static var windowBackgroundColor: NSColor {
//        return systemColorScheme.backgroundColor
//    }
//
//    static var appLogoColor: NSColor {
//        return systemColorScheme.general.appLogoColor
//    }
//
//    static var functionButtonColor: NSColor {
//        return systemColorScheme.buttonColor
//    }
//
//    static var textButtonMenuGradient: NSGradient {
//
//        let color = systemColorScheme.general.textButtonMenuColor
//        return NSGradient(starting: color, ending: color.darkened(40))!
//    }
//
//    static var toggleButtonOffStateColor: NSColor {
//        return systemColorScheme.inactiveControlColor
//    }
//
//    static var mainCaptionTextColor: NSColor {
//        return systemColorScheme.secondaryTextColor
//    }
//
//    static var tabButtonTextColor: NSColor {
//        return systemColorScheme.general.tabButtonTextColor
//    }
//
//    static var selectedTabButtonTextColor: NSColor {
//        return systemColorScheme.general.selectedTabButtonTextColor
//    }
//
//    static var selectedTabButtonColor: NSColor {
//        return systemColorScheme.general.selectedTabButtonColor
//    }
//
//    static var buttonMenuTextColor: NSColor {
//        return systemColorScheme.general.buttonMenuTextColor
//    }
//
//    struct Player {
//
//        static var trackInfoTitleTextColor: NSColor {
//            return systemColorScheme.player.trackInfoPrimaryTextColor
//        }
//
//        static var trackInfoArtistAlbumTextColor: NSColor {
//            return systemColorScheme.player.trackInfoSecondaryTextColor
//        }
//
//        static var trackInfoChapterTextColor: NSColor {
//            return systemColorScheme.player.trackInfoTertiaryTextColor
//        }
//
//        // Updates the cached NSGradient objects used by the player's seek slider
//        static func updateSliderColors() {
//
//            updateSliderBackgroundGradient()
//            updateSliderForegroundGradient()
//        }
//
//        static func updateSliderBackgroundColor() {
//            updateSliderBackgroundGradient()
//        }
//
//        private static func updateSliderBackgroundGradient() {
//            _sliderBackgroundGradient = computeSliderBackgroundGradient()
//        }
//
//        private static func computeSliderBackgroundGradient() -> NSGradient {
//
//            let endColor = systemColorScheme.player.inactiveControlColor
//
//            switch systemColorScheme.player.sliderBackgroundGradientType {
//
//            case .none:
//
//                return NSGradient(starting: endColor, ending: endColor)!
//
//            case .darken:
//
//                let amount = systemColorScheme.player.sliderBackgroundGradientAmount
//                let startColor = endColor.darkened(CGFloat(amount))
//
//                return NSGradient(starting: startColor, ending: endColor)!
//
//            case .brighten:
//
//                let amount = systemColorScheme.player.sliderBackgroundGradientAmount
//                let startColor = endColor.brightened(CGFloat(amount))
//
//                return NSGradient(starting: startColor, ending: endColor)!
//            }
//        }
//
//        // Cached background gradient used by the player's seek slider (to avoid repeated recomputations)
//        static var _sliderBackgroundGradient: NSGradient = computeSliderBackgroundGradient()
//
//        static var sliderBackgroundGradient: NSGradient {
//            return _sliderBackgroundGradient
//        }
//
//        static func updateSliderForegroundColor() {
//            updateSliderForegroundGradient()
//        }
//
//        private static func updateSliderForegroundGradient() {
//            _sliderForegroundGradient = computeSliderForegroundGradient()
//        }
//
//        private static func computeSliderForegroundGradient() -> NSGradient {
//
//            let startColor = systemColorScheme.player.sliderForegroundColor
//
//            switch systemColorScheme.player.sliderForegroundGradientType {
//
//            case .none:
//
//                return NSGradient(starting: startColor, ending: startColor)!
//
//            case .darken:
//
//                let amount = systemColorScheme.player.sliderForegroundGradientAmount
//                let endColor = startColor.darkened(CGFloat(amount))
//
//                return NSGradient(starting: startColor, ending: endColor)!
//
//            case .brighten:
//
//                let amount = systemColorScheme.player.sliderForegroundGradientAmount
//                let endColor = startColor.brightened(CGFloat(amount))
//
//                return NSGradient(starting: startColor, ending: endColor)!
//            }
//        }
//
//        // Cached foreground gradient used by the player's seek slider (to avoid repeated recomputations)
//        static var _sliderForegroundGradient: NSGradient = computeSliderForegroundGradient()
//
//        static var sliderForegroundGradient: NSGradient {
//            return _sliderForegroundGradient
//        }
//
//        static var sliderForegroundColor: NSColor {
//            return systemColorScheme.player.sliderForegroundColor
//        }
//
//        static var seekBarLoopColor: NSColor {
//            return systemColorScheme.player.sliderLoopSegmentColor
//        }
//
//        static var sliderKnobColor: NSColor {
//
//            return systemColorScheme.player.sliderKnobColorSameAsForeground ? systemColorScheme.player.sliderForegroundColor : systemColorScheme.player.sliderKnobColor
//        }
//    }
//
//    struct Playlist {
//
//        static var trackNameTextColor: NSColor {
//            return systemColorScheme.playlist.trackNameTextColor
//        }
//
//        static var groupNameTextColor: NSColor {
//            return systemColorScheme.playlist.groupNameTextColor
//        }
//
//        static var indexDurationTextColor: NSColor {
//            return systemColorScheme.playlist.indexDurationTextColor
//        }
//
//        static var trackNameSelectedTextColor: NSColor {
//            return systemColorScheme.playlist.trackNameSelectedTextColor
//        }
//
//        static var groupNameSelectedTextColor: NSColor {
//            return systemColorScheme.playlist.groupNameSelectedTextColor
//        }
//
//        static var indexDurationSelectedTextColor: NSColor {
//            return systemColorScheme.playlist.indexDurationSelectedTextColor
//        }
//
//        static var playingTrackIconColor: NSColor {
//            return systemColorScheme.playlist.playingTrackIconColor
//        }
//
//        static var selectionBoxColor: NSColor {
//            return systemColorScheme.playlist.selectionBoxColor
//        }
//
//        static var groupIconColor: NSColor {
//            return systemColorScheme.playlist.groupIconColor
//        }
//
//        static var groupDisclosureTriangleColor: NSColor {
//            return systemColorScheme.playlist.groupDisclosureTriangleColor
//        }
//
//        static var summaryInfoColor: NSColor {
//            return systemColorScheme.playlist.summaryInfoColor
//        }
//    }
//
//    struct Effects {
//
//        static var functionCaptionTextColor: NSColor {
//            return systemColorScheme.secondaryTextColor
//        }
//
//        static var functionValueTextColor: NSColor {
//            return systemColorScheme.primaryTextColor
//        }
//
//        static var inactiveControlColor: NSColor {
//            return systemColorScheme.effects.inactiveControlColor
//        }
//
//        static func sliderKnobColorForState(_ state: EffectsUnitState) -> NSColor {
//
//            let useForegroundColor: Bool = systemColorScheme.effects.sliderKnobColorSameAsForeground
//            let staticKnobColor: NSColor = systemColorScheme.effects.sliderKnobColor
//
//            switch state {
//
//            case .active:   return useForegroundColor ? activeUnitStateColor : staticKnobColor
//
//            case .bypassed: return useForegroundColor ? bypassedUnitStateColor : staticKnobColor
//
//            case .suppressed:   return useForegroundColor ? suppressedUnitStateColor : staticKnobColor
//
//            }
//        }
//
//        static var sliderTickColor: NSColor {
//            return systemColorScheme.effects.sliderTickColor
//        }
//
//        static var activeUnitStateColor: NSColor {
//            return systemColorScheme.activeControlColor
//        }
//
//        static var bypassedUnitStateColor: NSColor {
//            return systemColorScheme.inactiveControlColor
//        }
//
//        static var suppressedUnitStateColor: NSColor {
//            return systemColorScheme.suppressedControlColor
//        }
//
//        static var activeSliderGradient: NSGradient {
//
//            let startColor = systemColorScheme.activeControlColor
//
//            switch systemColorScheme.effects.sliderForegroundGradientType {
//
//            case .none:
//
//                return NSGradient(starting: startColor, ending: startColor)!
//
//            case .darken:
//
//                let amount = systemColorScheme.effects.sliderForegroundGradientAmount
//                let endColor = startColor.darkened(CGFloat(amount))
//
//                return NSGradient(starting: startColor, ending: endColor)!
//
//            case .brighten:
//
//                let amount = systemColorScheme.effects.sliderForegroundGradientAmount
//                let endColor = startColor.brightened(CGFloat(amount))
//
//                return NSGradient(starting: startColor, ending: endColor)!
//            }
//        }
//
//        static var bypassedSliderGradient: NSGradient {
//
//            let startColor = systemColorScheme.inactiveControlColor
//
//            switch systemColorScheme.effects.sliderForegroundGradientType {
//
//            case .none:
//
//                return NSGradient(starting: startColor, ending: startColor)!
//
//            case .darken:
//
//                let amount = systemColorScheme.effects.sliderForegroundGradientAmount
//                let endColor = startColor.darkened(CGFloat(amount))
//
//                return NSGradient(starting: startColor, ending: endColor)!
//
//            case .brighten:
//
//                let amount = systemColorScheme.effects.sliderForegroundGradientAmount
//                let endColor = startColor.brightened(CGFloat(amount))
//
//                return NSGradient(starting: startColor, ending: endColor)!
//            }
//        }
//
//        static var suppressedSliderGradient: NSGradient {
//
//            let startColor = systemColorScheme.suppressedControlColor
//
//            switch systemColorScheme.effects.sliderForegroundGradientType {
//
//            case .none:
//
//                return NSGradient(starting: startColor, ending: startColor)!
//
//            case .darken:
//
//                let amount = systemColorScheme.effects.sliderForegroundGradientAmount
//                let endColor = startColor.darkened(CGFloat(amount))
//
//                return NSGradient(starting: startColor, ending: endColor)!
//
//            case .brighten:
//
//                let amount = systemColorScheme.effects.sliderForegroundGradientAmount
//                let endColor = startColor.brightened(CGFloat(amount))
//
//                return NSGradient(starting: startColor, ending: endColor)!
//            }
//        }
//
//        static var sliderBackgroundGradient: NSGradient {
//
//            let endColor = systemColorScheme.effects.inactiveControlColor
//
//            switch systemColorScheme.effects.sliderBackgroundGradientType {
//
//            case .none:
//
//                return NSGradient(starting: endColor, ending: endColor)!
//
//            case .darken:
//
//                let amount = systemColorScheme.effects.sliderBackgroundGradientAmount
//                let startColor = endColor.darkened(CGFloat(amount))
//
//                return NSGradient(starting: startColor, ending: endColor)!
//
//            case .brighten:
//
//                let amount = systemColorScheme.effects.sliderBackgroundGradientAmount
//                let startColor = endColor.brightened(CGFloat(amount))
//
//                return NSGradient(starting: startColor, ending: endColor)!
//            }
//        }
//
//        static var defaultSliderBackgroundGradient: NSGradient {
//            return NSGradient(starting: .white40Percent, ending: .white20Percent)!
//        }
//
//        // Fill color of all slider knobs
//        static let defaultActiveUnitColor: NSColor = NSColor(red: 0, green: 0.8, blue: 0)
//        static let defaultBypassedUnitColor: NSColor = .white60Percent
//        static let defaultSuppressedUnitColor: NSColor = NSColor(red: 0.8, green: 0.6, blue: 0)
//
//        static let defaultActiveSliderGradient: NSGradient = {
//            return NSGradient(starting: defaultActiveUnitColor, ending: defaultActiveUnitColor)!
//        }()
//
//        static let defaultBypassedSliderGradient: NSGradient = {
//            return NSGradient(starting: defaultBypassedUnitColor, ending: defaultBypassedUnitColor)!
//        }()
//
//        static let defaultSuppressedSliderGradient: NSGradient = {
//            return NSGradient(starting: defaultSuppressedUnitColor, ending: defaultSuppressedUnitColor)!
//        }()
//
//        static let defaultPopupMenuGradient: NSGradient = NSGradient(starting: .white40Percent, ending: .white20Percent)!
//
//        // Color of the displayed text in popup menus
//        static let defaultPopupMenuTextColor: NSColor = .white90Percent
//
//        static let defaultTickColor: NSColor = NSColor.black
//    }
}
