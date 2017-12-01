import Cocoa

class StatusBarAppModeController: AppModeController {
    
    var mode: AppMode {return .statusBar}
    
    private lazy var statusBarView: StatusBarPopoverViewController = ViewFactory.getStatusBarPopover()
    
    func presentMode() {
        NSApp.setActivationPolicy(.accessory)
        statusBarView.show()
    }
    
    func dismissMode() {
        statusBarView.dismiss()
    }
}
