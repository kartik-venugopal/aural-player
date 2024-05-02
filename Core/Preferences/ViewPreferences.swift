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
    
    var snapToWindows: Bool = true
    var snapToScreen: Bool = true
    
    // Only used when snapToWindows == true
    var windowGap: Float = 1
    
    private static let keyPrefix: String = "view"
    
    static let key_snapToWindows: String = "\(keyPrefix).snap.toWindows"
    static let key_windowGap: String = "\(keyPrefix).snap.toWindows.gap"
    static let key_snapToScreen: String = "\(keyPrefix).snap.toScreen"
    
    private typealias Defaults = PreferencesDefaults.View

    init() {}
}

// Window layout on startup preference
class LayoutOnStartup {
    
    var option: WindowLayoutStartupOptions = .rememberFromLastAppLaunch
    
    // This is used only if option == .specific
    var layoutName: String? = nil
    
    // NOTE: This is mutable. Potentially unsafe
    static let defaultInstance: LayoutOnStartup = LayoutOnStartup()
}

// All options for the view at startup
enum WindowLayoutStartupOptions: String, CaseIterable {
    
    case specific
    case rememberFromLastAppLaunch
}

// Window layout on startup preference
class AppModeOnStartup {
    
    var option: AppModeStartupOptions = .rememberFromLastAppLaunch
    
    // This is used only if option == .specific
    var modeName: String? = nil
    
    var mode: AppMode? {
        modeName == nil ? nil : AppMode(rawValue: modeName!)
    }
    
    // NOTE: This is mutable. Potentially unsafe
    static let defaultInstance: AppModeOnStartup = AppModeOnStartup()
}

// All options for the view at startup
enum AppModeStartupOptions: String, CaseIterable {
    
    case specific
    case rememberFromLastAppLaunch
}

#endif
