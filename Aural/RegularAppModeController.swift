import Cocoa

class RegularAppModeController: AppModeController {
    
    var mode: AppMode {return .regular}
    private lazy var layoutManager: LayoutManager = ObjectGraph.layoutManager
    private var constituentViews: [ConstituentView] = []
    
    func presentMode() {
        NSApp.setActivationPolicy(.regular)
        constituentViews.forEach({$0.activate()})
        layoutManager.initialLayout()
    }
    
    func dismissMode() {
//        layoutManager.closeWindows()
        constituentViews.forEach({$0.deactivate()})
    }
    
    func registerConstituentView(_ view: ConstituentView) {
        constituentViews.append(view)
    }
}
