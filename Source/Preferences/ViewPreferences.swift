import Cocoa

class ViewPreferences: PersistentPreferencesProtocol {
    
    var layoutOnStartup: LayoutOnStartup
    var snapToWindows: Bool
    var snapToScreen: Bool
    
    // Only used when snapToWindows == true
    var windowGap: Float
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        layoutOnStartup = PreferencesDefaults.View.layoutOnStartup
        snapToWindows = PreferencesDefaults.View.snapToWindows
        snapToScreen = PreferencesDefaults.View.snapToScreen
        windowGap = PreferencesDefaults.View.windowGap
        
        if let layoutOnStartupOptionStr = defaultsDictionary["view.layoutOnStartup.option"] as? String {
            layoutOnStartup.option = WindowLayoutStartupOptions(rawValue: layoutOnStartupOptionStr)!
        }
        
        if let layoutStr = defaultsDictionary["view.layoutOnStartup.layout"] as? String {
            layoutOnStartup.layoutName = layoutStr
        }
        
        if let snap2Windows = defaultsDictionary["view.snap.toWindows"] as? Bool {
            snapToWindows = snap2Windows
        }
        
        if let gap = defaultsDictionary["view.snap.toWindows.gap"] as? Float {
            windowGap = gap
        }
        
        if let snap2Screen = defaultsDictionary["view.snap.toScreen"] as? Bool {
            snapToScreen = snap2Screen
        }
    }
    
    func persist(defaults: UserDefaults) {
        
        defaults.set(layoutOnStartup.option.rawValue, forKey: "view.layoutOnStartup.option")
        defaults.set(layoutOnStartup.layoutName, forKey: "view.layoutOnStartup.layout")
        defaults.set(snapToWindows, forKey: "view.snap.toWindows")
        defaults.set(windowGap, forKey: "view.snap.toWindows.gap")
        defaults.set(snapToScreen, forKey: "view.snap.toScreen")
    }
}
