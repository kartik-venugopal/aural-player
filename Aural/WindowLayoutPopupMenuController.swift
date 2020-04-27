import Cocoa

class WindowLayoutPopupMenuController: NSObject, NSMenuDelegate {

    private lazy var windowManager: WindowManagerProtocol = ObjectGraph.windowManager

    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Remove all custom presets (all items before the first separator)
        while let item = menu.item(at: 0), !item.isSeparatorItem {
            menu.removeItem(at: 0)
        }
        
        // Recreate the custom layout items
        WindowLayouts.userDefinedLayouts.forEach({
            
            let item: NSMenuItem = NSMenuItem(title: $0.name, action: #selector(self.btnLayoutAction(_:)), keyEquivalent: "")
            item.target = self
            
            menu.insertItem(item, at: 0)
        })
    }

    @IBAction func btnLayoutAction(_ sender: NSMenuItem) {
        windowManager.layout(sender.title)
    }
}
