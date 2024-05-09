//
//  ViewPreferences.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
#if os(macOS)

import Foundation

///
/// Encapsulates all user preferences pertaining to the user interface (view).
///
class ViewPreferences {
    
    private static let keyPrefix: String = "view"
    private typealias Defaults = PreferencesDefaults.View
    
    lazy var snapToWindows: UserPreference<Bool> = .init(defaultsKey: "\(Self.keyPrefix).snap.toWindows",
                                                                    defaultValue: Defaults.snapToWindows)
    
    lazy var snapToScreen: UserPreference<Bool> = .init(defaultsKey: "\(Self.keyPrefix).snap.toScreen",
                                                                    defaultValue: Defaults.snapToScreen)
    
    // Only used when snapToWindows == true
    lazy var windowGap: UserPreference<Float> = .init(defaultsKey: "\(Self.keyPrefix).snap.toWindows.gap",
                                                                    defaultValue: Defaults.windowGap)
    init() {}
}

#endif
