import Cocoa

class WindowLayoutPopupMenuController: NSObject, NSMenuDelegate, StringInputReceiver {

    private lazy var layoutNamePopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    private lazy var editorWindowController: EditorWindowController = EditorWindowController.instance
    
    @IBOutlet weak var theMenu: NSMenu!
    
    override func awakeFromNib() {
        
        theMenu.insertItem(NSMenuItem.createDescriptor(title: "Built-in layouts"), at: 0)
        theMenu.insertItem(NSMenuItem.separator(), at: 0)
        
        theMenu.insertItem(NSMenuItem.separator(), at: 0)
        theMenu.insertItem(NSMenuItem.createDescriptor(title: "Custom layouts"), at: 0)
        theMenu.insertItem(NSMenuItem.separator(), at: 0)
    }

    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Remove all custom presets (all items before the first separator)
        while let item = menu.item(at: 3), !item.isSeparatorItem {
            menu.removeItem(at: 3)
        }
        
        // Recreate the custom layout items
        WindowLayouts.userDefinedLayouts.forEach({
            
            let item: NSMenuItem = NSMenuItem(title: $0.name, action: #selector(self.applyLayoutAction(_:)), keyEquivalent: "")
            item.target = self
            item.indentationLevel = 1
            
            menu.insertItem(item, at: 3)
        })
        
        for index in 0...2 {
            menu.item(at: index)?.showIf_elseHide(WindowLayouts.userDefinedLayouts.count > 0)
        }
    }

    @IBAction func applyLayoutAction(_ sender: NSMenuItem) {
        WindowManager.instance.layout(sender.title)
    }
    
    @IBAction func saveWindowLayoutAction(_ sender: NSMenuItem) {
        layoutNamePopover.show(WindowManager.instance.mainWindow.contentView!, NSRectEdge.maxX)
    }
    
    @IBAction func manageLayoutsAction(_ sender: Any) {
        editorWindowController.showLayoutsEditor()
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
        WindowLayouts.addUserDefinedLayout(string, WindowManager.instance.currentWindowLayout)
    }
}
