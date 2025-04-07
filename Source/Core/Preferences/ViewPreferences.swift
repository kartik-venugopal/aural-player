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
    
    private static let keyPrefix: String = "view"
    private typealias Defaults = PreferencesDefaults.View
    
    lazy var windowMagnetism: UserMuthu<Bool> = .init(defaultsKey: "\(Self.keyPrefix).windowMagnetism",
                                                                    defaultValue: Defaults.windowMagnetism)
    
    lazy var snapToWindows: UserMuthu<Bool> = .init(defaultsKey: "\(Self.keyPrefix).snap.toWindows",
                                                                    defaultValue: Defaults.snapToWindows)
    
    lazy var snapToScreen: UserMuthu<Bool> = .init(defaultsKey: "\(Self.keyPrefix).snap.toScreen",
                                                                    defaultValue: Defaults.snapToScreen)

    // Only used when snapToWindows == true
    lazy var windowGap: UserMuthu<Float> = .init(defaultsKey: "\(Self.keyPrefix).snap.toWindows.gap",
                                                                    defaultValue: Defaults.windowGap)

    lazy var showLyricsTranslation: UserMuthu<Bool> = .init(
        defaultsKey: "\(Self.keyPrefix).showLyricsTranslation",
        defaultValue: Defaults.showLyricsTranslation
    )

    init(legacyPreferences: LegacyViewPreferences? = nil) {
        legacyPreferences?.deleteAll()
    }
}
