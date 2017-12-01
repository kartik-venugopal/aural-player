import Cocoa

class RegularAppModeController: AppModeController {
    
    var mode: AppMode {return .regular}
    private lazy var layoutManager: WindowLayoutManager = WindowLayoutManager()
    
    func presentMode() {
        NSApp.setActivationPolicy(.regular)
        layoutManager.initialWindowLayout()
    }
    
    func dismissMode() {
        layoutManager.closeWindows()
    }
}
