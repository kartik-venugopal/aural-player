import Cocoa

/*
    Controller for the settings popup menu on the main window.
 */
class SettingsPopupMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var applyColorSchemeMenuItem: NSMenuItem!
    @IBOutlet weak var saveColorSchemeMenuItem: NSMenuItem!
    
    private lazy var windowManager: WindowManagerProtocol = ObjectGraph.windowManager
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // These items should be enabled only if there is no modal component currently shown.
        [applyColorSchemeMenuItem, saveColorSchemeMenuItem].forEach({$0.enableIf(!windowManager.isShowingModalComponent)})
    }
}
