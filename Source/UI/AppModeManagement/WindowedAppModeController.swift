import Cocoa

class WindowedAppModeController: AppModeController {
    
    var mode: AppMode {return .windowed}
    
    func presentMode(transitioningFromMode previousMode: AppMode?) {
        
        NSApp.setActivationPolicy(.regular)
        
        WindowManager.createInstance(preferences: ObjectGraph.preferences.viewPreferences).loadWindows()
        
//        WindowManager.instance.toggleTuneBrowser()
        
        // If this is not a transition from another app mode, we don't need to execute the hack below.
        if previousMode == nil {return}
        
        // HACK - Because of an Apple bug, the main menu will not be usable until the app loses and then regains focus.
        // The following code simulates the user action of activating another app and then activating this app after a
        // short time interval.
        NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dock").first?.activate(options: [])

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
            NSApp.activate(ignoringOtherApps: true)
        })
    }
    
    func dismissMode() {
        WindowManager.destroy()
    }
}
