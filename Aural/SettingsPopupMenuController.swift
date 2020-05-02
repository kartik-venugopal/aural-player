import Cocoa

class SettingsPopupMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var applyColorSchemeMenuItem: NSMenuItem!
    @IBOutlet weak var saveColorSchemeMenuItem: NSMenuItem!
    
    private lazy var windowManager: WindowManagerProtocol = ObjectGraph.windowManager
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        [applyColorSchemeMenuItem, saveColorSchemeMenuItem].forEach({$0.enableIf(!windowManager.isShowingModalComponent)})
    }
}
