import Cocoa

class RegularAppModeController: AppModeController {
    
    var mode: AppMode {return .regular}
    
    func presentMode() {
        
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        WindowManager.createInstance(preferences: ObjectGraph.preferences.viewPreferences).loadWindows()
    }
    
    func dismissMode() {
        WindowManager.destroy()
    }
}
