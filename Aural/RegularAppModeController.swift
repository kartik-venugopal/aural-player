import Cocoa

class RegularAppModeController: AppModeController {
    
    var mode: AppMode {return .regular}
    private lazy var layoutManager: LayoutManager = ObjectGraph.getLayoutManager()
    private var constituentViews: [ConstituentView] = []
    
    func presentMode() {
        NSApp.setActivationPolicy(.regular)
        layoutManager.initialLayout()
        constituentViews.forEach({$0.activate()})
    }
    
    func dismissMode() {
//        layoutManager.closeWindows()
        constituentViews.forEach({$0.deactivate()})
    }
    
    func registerConstituentView(_ view: ConstituentView) {
        constituentViews.append(view)
    }
}
