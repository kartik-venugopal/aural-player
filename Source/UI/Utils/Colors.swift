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
//        // Fill color of all slider knobs
//        static let defaultActiveUnitColor: NSColor = NSColor(red: 0, green: 0.8, blue: 0)
//        static let defaultBypassedUnitColor: NSColor = .white60Percent
//        static let defaultSuppressedUnitColor: NSColor = NSColor(red: 0.8, green: 0.6, blue: 0)
//
//        // Color of the displayed text in popup menus
//        static let defaultPopupMenuTextColor: NSColor = .white90Percent
//
//        static let defaultTickColor: NSColor = NSColor.black
//    }
}
