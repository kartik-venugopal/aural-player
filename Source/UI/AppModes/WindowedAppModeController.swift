import Cocoa

class WindowedAppModeController: AppModeController {
    
    var mode: AppMode {return .windowed}
    
    func presentMode() {
        
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        WindowManager.createInstance(preferences: ObjectGraph.preferences.viewPreferences).loadWindows()
    }
    
    func dismissMode() {
        WindowManager.destroy()
    }
}
