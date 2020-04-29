import Cocoa

class ColorSchemePopupMenuController: NSObject, NSMenuDelegate, StringInputClient {
    
    private lazy var colorsDialog: ModalDialogDelegate = WindowFactory.colorSchemesDialog
    
    lazy var userSchemesPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
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
        
        if let scheme = ColorSchemes.applyScheme(sender.title) {
            SyncMessenger.publishActionMessage(ColorSchemeActionMessage(scheme))
        }
    }
    
    @IBAction func customizeSchemeAction(_ sender: NSMenuItem) {
        _ = colorsDialog.showDialog()
    }
    
    // MARK - StringInputClient functions
    
    var inputPrompt: String {
        return "Enter a new color scheme name:"
    }
    
    var defaultValue: String? {
        return "<New color scheme>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        if ColorSchemes.schemeWithNameExists(string) {
            return (false, "Color scheme with this name already exists !")
        } else if string.trim().isEmpty {
            return (false, "Name must have at least 1 non-whitespace character.")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new color scheme name and saves the new scheme
    func acceptInput(_ string: String) {
        
        // Copy the current system scheme into the new scheme, and name it with the user's given scheme name
        let newScheme: ColorScheme = ColorScheme(string, false, ColorSchemes.systemScheme)
        ColorSchemes.addUserDefinedScheme(newScheme)
    }
    
    var inputFontSize: TextSize {
        return .normal
    }
}
