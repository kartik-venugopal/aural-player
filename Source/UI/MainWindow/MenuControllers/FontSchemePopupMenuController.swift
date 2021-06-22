import Cocoa

/*
    Controller for the popup menu that lists the available font schemes and opens the font scheme editor panel.
 */
class FontSchemePopupMenuController: NSObject, NSMenuDelegate, StringInputReceiver {
    
    private lazy var editorDialogController: FontSchemesWindowController = FontSchemesWindowController.instance
    
    private lazy var userSchemesPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    private lazy var editorWindowController: EditorWindowController = EditorWindowController.instance
    
    private lazy var fontSchemesManager: FontSchemesManager = ObjectGraph.fontSchemesManager
    
    @IBOutlet weak var theMenu: NSMenu!
    
    override func awakeFromNib() {
        
        theMenu.insertItem(NSMenuItem.createDescriptor(title: "Built-in schemes"), at: 0)
        theMenu.insertItem(NSMenuItem.separator(), at: 0)
        
        theMenu.insertItem(NSMenuItem.separator(), at: 0)
        theMenu.insertItem(NSMenuItem.createDescriptor(title: "Custom schemes"), at: 0)
        theMenu.insertItem(NSMenuItem.separator(), at: 0)
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Remove all user-defined scheme items (i.e. all items before the first separator)
        while let item = menu.item(at: 3), !item.isSeparatorItem {
            menu.removeItem(at: 3)
        }
        
        // Recreate the user-defined font scheme items
        fontSchemesManager.userDefinedPresets.forEach {
            
            let item: NSMenuItem = NSMenuItem(title: $0.name, action: #selector(self.applySchemeAction(_:)), keyEquivalent: "")
            item.target = self
            item.indentationLevel = 1
            
            menu.insertItem(item, at: 3)
        }
        
        for index in 0...2 {
            menu.item(at: index)?.showIf_elseHide(fontSchemesManager.numberOfUserDefinedPresets > 0)
        }
    }
    
    @IBAction func applySchemeAction(_ sender: NSMenuItem) {
        
        if let fontScheme = fontSchemesManager.applyScheme(named: sender.title) {
            Messenger.publish(.applyFontScheme, payload: fontScheme)
        }
    }
    
    @IBAction func customizeFontSchemeAction(_ sender: NSMenuItem) {
        _ = editorDialogController.showDialog()
    }
    
    @IBAction func saveSchemeAction(_ sender: NSMenuItem) {
        userSchemesPopover.show(WindowManager.instance.mainWindow.contentView!, NSRectEdge.maxX)
    }
    
    @IBAction func manageSchemesAction(_ sender: NSMenuItem) {
        editorWindowController.showFontSchemesEditor()
    }
    
    // MARK - StringInputReceiver functions (to receive the name of a new user-defined font scheme)
    
    var inputPrompt: String {
        return "Enter a new font scheme name:"
    }
    
    var defaultValue: String? {
        return "<New font scheme>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        if fontSchemesManager.presetExists(named: string) {
            return (false, "Font scheme with this name already exists !")
        } else if string.trim().isEmpty {
            return (false, "Name must have at least 1 character.")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new font scheme name and saves the new scheme
    func acceptInput(_ string: String) {
        
        // Copy the current system scheme into the new scheme, and name it with the user's given scheme name
        let newScheme: FontScheme = FontScheme(string, false, fontSchemesManager.systemScheme)
        fontSchemesManager.addPreset(newScheme)
    }
    
    deinit {
        FontSchemesWindowController.destroy()
    }
}
