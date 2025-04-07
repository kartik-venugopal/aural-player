//
//  ViewPreferences.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all user preferences pertaining to the user interface (view).
///
class ViewPreferences {
    
    @UserPreference(key: "view.windowMagnetism", defaultValue: Defaults.windowMagnetism)
    var windowMagnetism: Bool
    
    @UserPreference(key: "view.snap.toWindows", defaultValue: Defaults.snapToWindows)
    var snapToWindows: Bool
    
    @UserPreference(key: "view.snap.toScreen", defaultValue: Defaults.snapToScreen)
    var snapToScreen: Bool

    // Only used when snapToWindows == true
    @UserPreference(key: "view.snap.toWindows.gap", defaultValue: Defaults.windowGap)
    var windowGap: Float

    @UserPreference(key: "view.showLyricsTranslation", defaultValue: Defaults.showLyricsTranslation)
    var showLyricsTranslation: Bool

    init(legacyPreferences: LegacyViewPreferences? = nil) {
        legacyPreferences?.deleteAll()
    }
    
    ///
    /// An enumeration of default values for UI / view preferences.
    ///
    fileprivate struct Defaults {
        
        static let windowMagnetism: Bool = true
        static let snapToWindows: Bool = true
        static let snapToScreen: Bool = true
        static let windowGap: Float = 0
        static let showLyricsTranslation: Bool = false
    }
}
