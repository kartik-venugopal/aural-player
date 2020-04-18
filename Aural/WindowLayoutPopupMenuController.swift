import Cocoa

class WindowLayoutPopupMenuController: NSObject, NSMenuDelegate {

    @IBOutlet weak var btnLayout: NSPopUpButton!
    
    private lazy var windowManager: WindowManagerProtocol = ObjectGraph.windowManager

    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Remove all custom presets (all items before the first separator)
        while !btnLayout.item(at: 1)!.isSeparatorItem {
            btnLayout.removeItem(at: 1)
        }
        
        // Recreate the custom layout items
        WindowLayouts.userDefinedLayouts.forEach({
            self.btnLayout.insertItem(withTitle: $0.name, at: 1)
        })
    }

    @IBAction func btnLayoutAction(_ sender: NSPopUpButton) {
        windowManager.layout(sender.titleOfSelectedItem!)
    }
}
