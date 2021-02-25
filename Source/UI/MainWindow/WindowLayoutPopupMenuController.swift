import Cocoa

class WindowLayoutPopupMenuController: NSObject, NSMenuDelegate, StringInputReceiver {

    private lazy var layoutNamePopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)

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
        WindowManager.layout(sender.title)
    }
    
    @IBAction func saveWindowLayoutAction(_ sender: NSMenuItem) {
        layoutNamePopover.show(WindowManager.mainWindow.contentView!, NSRectEdge.maxX)
    }
    
    // MARK - StringInputReceiver functions
    
    var inputPrompt: String {
        return "Enter a layout name:"
    }
    
    var defaultValue: String? {
        return "<My custom layout>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        let valid = !WindowLayouts.layoutWithNameExists(string)
        
        if (!valid) {
            return (false, "A layout with this name already exists !")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new EQ preset name and saves the new preset
    func acceptInput(_ string: String) {
        WindowLayouts.addUserDefinedLayout(string, WindowManager.currentWindowLayout)
    }
}
