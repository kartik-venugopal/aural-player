import Cocoa

class RegularAppModeController: AppModeController {
    
    var mode: AppMode {return .regular}
//    private var constituentViews: [ConstituentView] = []
    
    func presentMode() {
        
        NSApp.setActivationPolicy(.regular)
        WindowManager.createInstance(preferences: ObjectGraph.preferences.viewPreferences)
        WindowManager.instance.loadWindows()
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    func dismissMode() {
        WindowManager.destroyInstance()
    }
    
    func registerConstituentView(_ view: ConstituentView) {
//        constituentViews.append(view)
    }
}
