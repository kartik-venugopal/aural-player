import Cocoa

class ViewPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var btnStartWithLayout: NSButton!
    @IBOutlet weak var btnRememberLayout: NSButton!
    @IBOutlet weak var layoutMenu: NSPopUpButton!
    
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
        
        layoutMenu.selectItem(withTitle: viewPrefs.layoutOnStartup.layoutName)
        layoutMenu.isEnabled = Bool(btnStartWithLayout.state)
    }
    
    @IBAction func layoutOnStartupAction(_ sender: Any) {
        layoutMenu.isEnabled = Bool(btnStartWithLayout.state)
    }

    func save(_ preferences: Preferences) {
        
        let viewPrefs = preferences.viewPreferences
        
        viewPrefs.layoutOnStartup.option = btnStartWithLayout.state == 1 ? .specific : .rememberFromLastAppLaunch
        viewPrefs.layoutOnStartup.layoutName = layoutMenu.selectedItem!.title
    }
}
