import Cocoa

class MiniBarAppModeController: AppModeController {
    
    var mode: AppMode {return .miniBar}
    
    private lazy var miniBarView: BarModeWindowController = BarModeWindowController()
    
    func presentMode() {
        NSApp.setActivationPolicy(.regular)
        miniBarView.showWindow(self)
    }
    
    func dismissMode() {
        miniBarView.window?.close()
    }
    
    func registerConstituentView(_ view: ConstituentView) {
        
    }
}
