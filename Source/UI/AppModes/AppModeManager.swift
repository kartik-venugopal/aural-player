import Cocoa

class AppModeManager {
    
    static var mode: AppMode!
    
    private static var windowedMode: WindowedAppModeController = WindowedAppModeController()
    
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
        
        switch newMode {
        
        case .windowed:  windowedMode.presentMode(transitioningFromMode: mode)
        
        case .statusBar: statusBarMode.presentMode(transitioningFromMode: mode)
        
        }
        
        mode = newMode
    }
    
    private static func dismissCurrentMode() {
        
        guard let currentMode = self.mode else {return}
        
        switch currentMode {
            
        case .windowed:  windowedMode.dismissMode()
            
        case .statusBar: statusBarMode.dismissMode()
            
        }
    }
}

enum AppMode: String {
    
    case windowed
    case statusBar
}

protocol AppModeController {
    
    var mode: AppMode {get}
    
    func presentMode(transitioningFromMode previousMode: AppMode?)
    
    func dismissMode()
}
