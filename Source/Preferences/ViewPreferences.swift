//
//  ViewPreferences.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class ViewPreferences: PersistentPreferencesProtocol {
    
    var appModeOnStartup: AppModeOnStartup
    var layoutOnStartup: LayoutOnStartup
    var snapToWindows: Bool
    var snapToScreen: Bool
    
    // Only used when snapToWindows == true
    var windowGap: Float
    
    private static let keyPrefix: String = "view"
    
    static let key_appModeOnStartup_option: String = "\(keyPrefix).appModeOnStartup.option"
    static let key_appModeOnStartup_modeName: String = "\(keyPrefix).appModeOnStartup.mode"
    
    static let key_layoutOnStartup_option: String = "\(keyPrefix).layoutOnStartup.option"
    static let key_layoutOnStartup_layoutName: String = "\(keyPrefix).layoutOnStartup.layout"
    
    static let key_snapToWindows: String = "\(keyPrefix).snap.toWindows"
    static let key_windowGap: String = "\(keyPrefix).snap.toWindows.gap"
    static let key_snapToScreen: String = "\(keyPrefix).snap.toScreen"
    
    private typealias Defaults = PreferencesDefaults.View
    
    internal required init(_ dict: [String: Any]) {
        
        appModeOnStartup = Defaults.appModeOnStartup
        layoutOnStartup = Defaults.layoutOnStartup
        
        if let appModeOnStartupOption = dict.enumValue(forKey: Self.key_appModeOnStartup_option,
                                                       ofType: AppModeStartupOptions.self) {
            
            appModeOnStartup.option = appModeOnStartupOption
        }
        
        appModeOnStartup.modeName = dict[Self.key_appModeOnStartup_modeName, String.self]
        
        if let layoutOnStartupOption = dict.enumValue(forKey: Self.key_layoutOnStartup_option,
                                                      ofType: WindowLayoutStartupOptions.self) {
            
            layoutOnStartup.option = layoutOnStartupOption
        }
        
        layoutOnStartup.layoutName = dict[Self.key_layoutOnStartup_layoutName, String.self]
        
        snapToWindows = dict[Self.key_snapToWindows, Bool.self] ?? Defaults.snapToWindows
        windowGap = dict.floatValue(forKey: Self.key_windowGap) ?? Defaults.windowGap
        snapToScreen = dict[Self.key_snapToScreen, Bool.self] ?? Defaults.snapToScreen
        
        if appModeOnStartup.option == .specific && appModeOnStartup.modeName == nil {
            appModeOnStartup.option = Defaults.appModeOnStartup.option
        }
        
        if layoutOnStartup.option == .specific && layoutOnStartup.layoutName == nil {
            layoutOnStartup.option = Defaults.layoutOnStartup.option
        }
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults[Self.key_appModeOnStartup_option] = appModeOnStartup.option.rawValue 
        defaults[Self.key_appModeOnStartup_modeName] = appModeOnStartup.modeName 
        
        defaults[Self.key_layoutOnStartup_option] = layoutOnStartup.option.rawValue 
        defaults[Self.key_layoutOnStartup_layoutName] = layoutOnStartup.layoutName 
        
        defaults[Self.key_snapToWindows] = snapToWindows 
        defaults[Self.key_windowGap] = windowGap 
        defaults[Self.key_snapToScreen] = snapToScreen 
    }
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
