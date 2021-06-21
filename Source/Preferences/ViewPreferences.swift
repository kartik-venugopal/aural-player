import Cocoa

class ViewPreferences: PersistentPreferencesProtocol {
    
    var appModeOnStartup: AppModeOnStartup
    var layoutOnStartup: LayoutOnStartup
    var snapToWindows: Bool
    var snapToScreen: Bool
    
    // Only used when snapToWindows == true
    var windowGap: Float
    
    private static let keyPrefix: String = "view"
    
    private static let key_appModeOnStartupOption: String = "\(keyPrefix).appModeOnStartup.option"
    private static let key_appModeOnStartupModeName: String = "\(keyPrefix).appModeOnStartup.mode"
    
    private static let key_layoutOnStartupOption: String = "\(keyPrefix).layoutOnStartup.option"
    private static let key_layoutOnStartupLayoutName: String = "\(keyPrefix).layoutOnStartup.layout"
    
    private static let key_snapToWindows: String = "\(keyPrefix).snap.toWindows"
    private static let key_windowGap: String = "\(keyPrefix).snap.toWindows.gap"
    private static let key_snapToScreen: String = "\(keyPrefix).snap.toScreen"
    
    private typealias Defaults = PreferencesDefaults.View
    
    internal required init(_ dict: [String: Any]) {
        
        appModeOnStartup = Defaults.appModeOnStartup
        layoutOnStartup = Defaults.layoutOnStartup
        
        if let appModeOnStartupOption = dict.enumValue(forKey: Self.key_appModeOnStartupOption,
                                                       ofType: AppModeStartupOptions.self) {
            
            appModeOnStartup.option = appModeOnStartupOption
        }
        
        if let appModeStr = dict[Self.key_appModeOnStartupModeName, String.self] {
            appModeOnStartup.modeName = appModeStr
        }
        
        if let layoutOnStartupOption = dict.enumValue(forKey: Self.key_layoutOnStartupOption,
                                                      ofType: WindowLayoutStartupOptions.self) {
            
            layoutOnStartup.option = layoutOnStartupOption
        }
        
        if let layoutStr = dict[Self.key_layoutOnStartupLayoutName, String.self] {
            layoutOnStartup.layoutName = layoutStr
        }
        
        snapToWindows = dict[Self.key_snapToWindows, Bool.self] ?? Defaults.snapToWindows
        windowGap = dict[Self.key_windowGap, Float.self] ?? Defaults.windowGap
        snapToScreen = dict[Self.key_snapToScreen, Bool.self] ?? Defaults.snapToScreen
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults[Self.key_appModeOnStartupOption] = appModeOnStartup.option.rawValue 
        defaults[Self.key_appModeOnStartupModeName] = appModeOnStartup.modeName 
        
        defaults[Self.key_layoutOnStartupOption] = layoutOnStartup.option.rawValue 
        defaults[Self.key_layoutOnStartupLayoutName] = layoutOnStartup.layoutName 
        
        defaults[Self.key_snapToWindows] = snapToWindows 
        defaults[Self.key_windowGap] = windowGap 
        defaults[Self.key_snapToScreen] = snapToScreen 
    }
}

// Window layout on startup preference
class LayoutOnStartup {
    
    var option: WindowLayoutStartupOptions = .rememberFromLastAppLaunch
    
    // This is used only if option == .specific
    var layoutName: String = ""
    
    // NOTE: This is mutable. Potentially unsafe
    static let defaultInstance: LayoutOnStartup = LayoutOnStartup()
}

// All options for the view at startup
enum WindowLayoutStartupOptions: String {
    
    case specific
    case rememberFromLastAppLaunch
}

// Window layout on startup preference
class AppModeOnStartup {
    
    var option: AppModeStartupOptions = .rememberFromLastAppLaunch
    
    // This is used only if option == .specific
    var modeName: String = ""
    
    // NOTE: This is mutable. Potentially unsafe
    static let defaultInstance: AppModeOnStartup = AppModeOnStartup()
}

// All options for the view at startup
enum AppModeStartupOptions: String {
    
    case specific
    case rememberFromLastAppLaunch
}
