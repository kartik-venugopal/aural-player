import Cocoa

class MiniBarAppModeController: AppModeController {
    
    var mode: AppMode {return .miniBar}
    
    private lazy var miniBarView: BarModeWindowController = BarModeWindowController()
    private var constituentViews: [ConstituentView] = []
    
    func presentMode() {
        NSApp.setActivationPolicy(.regular)
        miniBarView.showWindow(self)
        constituentViews.forEach({$0.activate()})
    }
    
    func dismissMode() {
        miniBarView.window?.close()
        constituentViews.forEach({$0.deactivate()})
    }
    
    func registerConstituentView(_ view: ConstituentView) {
        constituentViews.append(view)
    }
}
