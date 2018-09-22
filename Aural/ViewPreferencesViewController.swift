import Cocoa

class ViewPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var btnStartWithLayout: NSButton!
    @IBOutlet weak var btnRememberLayout: NSButton!
    @IBOutlet weak var layoutMenu: NSPopUpButton!
    
    @IBOutlet weak var btnSnapToWindows: NSButton!
    @IBOutlet weak var btnSnapToScreen: NSButton!
    
    override var nibName: String? {return "ViewPreferences"}
    
    func getView() -> NSView {
        return self.view
    }
    
    override func viewDidLoad() {
        
        // Add all user layouts to the menu
        WindowLayouts.userDefinedLayouts.forEach({
        
            layoutMenu.insertItem(withTitle: $0.name, at: 0)
        })
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let viewPrefs = preferences.viewPreferences
     
        if (viewPrefs.layoutOnStartup.option == .specific) {
            btnStartWithLayout.state = 1
        } else {
            btnRememberLayout.state = 1
        }
        
        if let item = layoutMenu.item(withTitle: viewPrefs.layoutOnStartup.layoutName) {
            layoutMenu.select(item)
        } else {
            // Default
            layoutMenu.select(layoutMenu.item(withTitle: WindowLayouts.defaultLayout.name))
        }
        layoutMenu.isEnabled = Bool(btnStartWithLayout.state)
        
        btnSnapToWindows.state = viewPrefs.snapToWindows ? 1 : 0
        btnSnapToScreen.state = viewPrefs.snapToScreen ? 1 : 0
    }
    
    @IBAction func layoutOnStartupAction(_ sender: Any) {
        layoutMenu.isEnabled = Bool(btnStartWithLayout.state)
    }

    func save(_ preferences: Preferences) {
        
        let viewPrefs = preferences.viewPreferences
        
        viewPrefs.layoutOnStartup.option = btnStartWithLayout.state == 1 ? .specific : .rememberFromLastAppLaunch
        viewPrefs.layoutOnStartup.layoutName = layoutMenu.selectedItem!.title
        
        viewPrefs.snapToWindows = Bool(btnSnapToWindows.state)
        viewPrefs.snapToScreen = Bool(btnSnapToScreen.state)
    }
}
