import Cocoa

class ColorSchemePopupMenuController: NSObject, NSMenuDelegate {
    
    private lazy var colorsDialog: ModalDialogDelegate = WindowFactory.colorSchemesDialog
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        while let item = menu.item(at: 0), !item.isSeparatorItem {
            menu.removeItem(at: 0)
        }
        
        // Recreate the custom scheme items
        ColorSchemes.userDefinedSchemes.forEach({
            
            let item: NSMenuItem = NSMenuItem(title: $0.name, action: #selector(self.applySchemeAction(_:)), keyEquivalent: "")
            item.target = self
            
            menu.insertItem(item, at: 0)
        })
    }
    
    @IBAction func applySchemeAction(_ sender: NSMenuItem) {
        
        if let scheme = ColorSchemes.schemeByName(sender.title) {
            
            ColorSchemes.systemScheme = scheme
            SyncMessenger.publishActionMessage(ColorSchemeActionMessage(scheme))
        }
    }
    
    @IBAction func customizeSchemeAction(_ sender: NSMenuItem) {
        _ = colorsDialog.showDialog()
    }
}
