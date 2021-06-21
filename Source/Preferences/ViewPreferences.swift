import Cocoa

class ViewPreferences: PersistentPreferencesProtocol {
    
    var appModeOnStartup: AppModeOnStartup
    var layoutOnStartup: LayoutOnStartup
    var snapToWindows: Bool
    var snapToScreen: Bool
    
    // Only used when snapToWindows == true
    var windowGap: Float
    
    private static let keyPrefix: String = "view"
    
    private static let key_appModeOnStartupOption: String = "\(ViewPreferences.keyPrefix).appModeOnStartup.option"
    private static let key_appModeOnStartupModeName: String = "\(ViewPreferences.keyPrefix).appModeOnStartup.mode"
    
    private static let key_layoutOnStartupOption: String = "\(ViewPreferences.keyPrefix).layoutOnStartup.option"
    private static let key_layoutOnStartupLayoutName: String = "\(ViewPreferences.keyPrefix).layoutOnStartup.layout"
    
    private static let key_snapToWindows: String = "\(ViewPreferences.keyPrefix).snap.toWindows"
    private static let key_windowGap: String = "\(ViewPreferences.keyPrefix).snap.toWindows.gap"
    private static let key_snapToScreen: String = "\(ViewPreferences.keyPrefix).snap.toScreen"
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        appModeOnStartup = PreferencesDefaults.View.appModeOnStartup
        layoutOnStartup = PreferencesDefaults.View.layoutOnStartup
        
        if let appModeOnStartupOption = defaultsDictionary.enumValue(forKey: Self.key_appModeOnStartupOption,
                                                                     ofType: AppModeStartupOptions.self) {
            
            appModeOnStartup.option = appModeOnStartupOption
        }
        
        if let appModeStr = defaultsDictionary[Self.key_appModeOnStartupModeName, String.self] {
            appModeOnStartup.modeName = appModeStr
        }
        
        if let layoutOnStartupOption = defaultsDictionary.enumValue(forKey: Self.key_layoutOnStartupOption,
                                                                    ofType: WindowLayoutStartupOptions.self) {
            
            layoutOnStartup.option = layoutOnStartupOption
        }
        
        if let layoutStr = defaultsDictionary[Self.key_layoutOnStartupLayoutName, String.self] {
            layoutOnStartup.layoutName = layoutStr
        }
        
        snapToWindows = defaultsDictionary[Self.key_snapToWindows, Bool.self] ?? PreferencesDefaults.View.snapToWindows
        windowGap = defaultsDictionary[Self.key_windowGap, Float.self] ?? PreferencesDefaults.View.windowGap
        snapToScreen = defaultsDictionary[Self.key_snapToScreen, Bool.self] ?? PreferencesDefaults.View.snapToScreen
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults.set(appModeOnStartup.option.rawValue, forKey: Self.key_appModeOnStartupOption)
        defaults.set(appModeOnStartup.modeName, forKey: Self.key_appModeOnStartupModeName)
        
        defaults.set(layoutOnStartup.option.rawValue, forKey: Self.key_layoutOnStartupOption)
        defaults.set(layoutOnStartup.layoutName, forKey: Self.key_layoutOnStartupLayoutName)
        
        defaults.set(snapToWindows, forKey: Self.key_snapToWindows)
        defaults.set(windowGap, forKey: Self.key_windowGap)
        defaults.set(snapToScreen, forKey: Self.key_snapToScreen)
    }
}
