import Cocoa

class RegularAppModeController: AppModeController {
    
    var mode: AppMode {return .regular}
    
    func presentMode() {
        
        NSApp.setActivationPolicy(.regular)
        
        WindowManager.createInstance(preferences: ObjectGraph.preferences.viewPreferences)
        WindowManager.instance.loadWindows()
        
        // TODO: Here, set the main menu
        
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    func dismissMode() {
        
        WindowManager.destroyInstance()
        NSApp.mainMenu = nil
    }
}
