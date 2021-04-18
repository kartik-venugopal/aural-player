import Cocoa

/*
    Controller for the popup menu that lists the available color schemes and opens the color scheme editor panel.
 */
class ThemePopupMenuController: NSObject, NSMenuDelegate, StringInputReceiver {
    
    private lazy var createThemeDialog: ModalDialogDelegate = WindowFactory.createThemeDialog
    private lazy var userThemesPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    private lazy var editorWindowController: EditorWindowController = WindowFactory.editorWindowController
    
    @IBOutlet weak var theMenu: NSMenu!
    
    override func awakeFromNib() {
        
        theMenu.insertItem(NSMenuItem.createDescriptor(title: "Built-in themes"), at: 0)
        theMenu.insertItem(NSMenuItem.separator(), at: 0)
        
        theMenu.insertItem(NSMenuItem.separator(), at: 0)
        theMenu.insertItem(NSMenuItem.createDescriptor(title: "Custom themes"), at: 0)
        theMenu.insertItem(NSMenuItem.separator(), at: 0)
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Remove all user-defined scheme items (i.e. all items before the first separator)
        while let item = menu.item(at: 3), !item.isSeparatorItem {
            menu.removeItem(at: 3)
        }
        
        // Recreate the user-defined color scheme items
        Themes.userDefinedThemes.forEach {

            let item: NSMenuItem = NSMenuItem(title: $0.name, action: #selector(self.applyThemeAction(_:)), keyEquivalent: "")
            item.target = self
            item.indentationLevel = 1

            menu.insertItem(item, at: 3)
        }

        for index in 0...2 {
            menu.item(at: index)?.showIf_elseHide(Themes.numberOfUserDefinedThemes > 0)
        }
    }
    
    @IBAction func applyThemeAction(_ sender: NSMenuItem) {
        
        if Themes.applyTheme(named: sender.title) {
            Messenger.publish(.applyTheme)
        }
    }
    
    @IBAction func saveThemeAction(_ sender: NSMenuItem) {
        userThemesPopover.show(WindowManager.instance.mainWindow.contentView!, NSRectEdge.maxX)
    }
    
    @IBAction func createThemeAction(_ sender: NSMenuItem) {
        _ = createThemeDialog.showDialog()
    }
    
    @IBAction func manageThemesAction(_ sender: NSMenuItem) {
        editorWindowController.showThemesEditor()
    }
    
    // MARK - StringInputReceiver functions (to receive the name of a new user-defined color scheme)
    
    var inputPrompt: String {
        return "Enter a new theme name:"
    }
    
    var defaultValue: String? {
        return "<New theme>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        if Themes.themeWithNameExists(string) {
            return (false, "Theme with this name already exists !")
        } else if string.trim().isEmpty {
            return (false, "Name must have at least 1 character.")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new color scheme name and saves the new scheme
    func acceptInput(_ string: String) {
        
        // Copy the current system scheme into the new scheme, and name it with the user's given scheme name
        let fontScheme: FontScheme = FontScheme("Font scheme for theme '\(string)'", false, FontSchemes.systemScheme)
        let colorScheme: ColorScheme = ColorScheme("Color scheme for theme '\(string)'", false, ColorSchemes.systemScheme)
        let windowAppearance: WindowAppearance = WindowAppearance(cornerRadius: WindowAppearanceState.cornerRadius)
        
        Themes.addUserDefinedTheme(Theme(name: string, fontScheme: fontScheme, colorScheme: colorScheme, windowAppearance: windowAppearance))
    }
}
