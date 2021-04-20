import Cocoa

class AppModeManager {
    
    static var mode: AppMode = AppDefaults.appMode
    
    private static var regularMode: RegularAppModeController = RegularAppModeController()
    
    private static var statusBarMode: StatusBarAppModeController = StatusBarAppModeController()
    
    static func presentApp(lastPresentedAppMode: AppMode, preferences: ViewPreferences) {
        
        if preferences.appModeOnStartup.option == .rememberFromLastAppLaunch {
            presentMode(lastPresentedAppMode)
            
        } else {    // Specific mode
            presentMode(AppMode(rawValue: preferences.appModeOnStartup.modeName) ?? AppDefaults.appMode)
        }
    }
    
    static func presentMode(_ newMode: AppMode) {
        
        dismissCurrentMode()
        
        mode = newMode
        
        switch mode {
            
        case .regular:  regularMode.presentMode()
        
        case .statusBar: statusBarMode.presentMode()
        
        }
    }
    
    private static func dismissCurrentMode() {
        
        switch mode {
            
        case .regular:  regularMode.dismissMode()
            
        case .statusBar: statusBarMode.dismissMode()
            
        }
    }
}

enum AppMode: String {
    
    case regular
    case statusBar
}

protocol AppModeController {
    
    var mode: AppMode {get}
    
    func presentMode()
    
    func dismissMode()
}
