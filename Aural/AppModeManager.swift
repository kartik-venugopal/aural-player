import Cocoa

class AppModeManager {
    
    static var mode: AppMode = AppDefaults.appMode
    
//    private static var mainWindow: NSWindow!
//    private static var playlistWindow: NSWindow!
    
//    private static var barModeWindowController: NSWindow!
//    
//    private static var statusBarView: StatusBarPopoverViewController!
    
    private static var regMode: RegularAppModeController!
    
    static func switchToMode(_ newMode: AppMode) {
        mode = newMode
    }
    
    static func load() {
        regMode = RegularAppModeController()
        regMode.presentMode()
    }
    
    // Shows the main application window
//    static func showMainWindow() {
//        mainWindowController.showWindow(NSApp.delegate)
//    }
//    
//    static func showWindows() {
//        mainWindowController.showWindows()
//    }
//    
//    static func showBarModeWindow() {
//        barModeWindowController.showWindow(NSApp.delegate)
//    }
//    
//    private static func regularMode() {
//        
//    }
//    
//    private static func statusBarMode() {
//        
//        [mainWindow, playlistWindow].forEach({$0.close()})
//        
//        NSApp.setActivationPolicy(.accessory)
//        
//        if (statusBarView == nil) {
//            statusBarView = StatusBarPopoverViewController.create()
//        }
//        statusBarView.show()
//        
//        if eventMonitor != nil {
//            NSEvent.removeMonitor(eventMonitor!)
//            eventMonitor = nil
//        }
//    }
}

enum AppMode: String {
    
    case regular
    case statusBar
    case miniBar
}

protocol AppModeController {
    
    var mode: AppMode {get}
    
    func presentMode()
    
    func dismissMode()
}
