import Cocoa

class MiniBarAppModeController: AppModeController {
    
    var mode: AppMode {return .miniBar}
    
    private lazy var miniBarView: BarModeWindowController = BarModeWindowController()
    
    func presentMode() {
        print("Presenting Mini Bar")
        NSApp.setActivationPolicy(.regular)
        miniBarView.showWindow(self)
        print("Showing Window")
    }
    
    func dismissMode() {
        miniBarView.window?.close()
    }
}
