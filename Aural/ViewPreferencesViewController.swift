import Cocoa

class ViewPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var btnStartWithView: NSButton!
    @IBOutlet weak var startWithViewMenu: NSPopUpButton!
    @IBOutlet weak var btnRememberView: NSButton!
    
    @IBOutlet weak var btnRememberWindowLocation: NSButton!
    @IBOutlet weak var btnStartAtWindowLocation: NSButton!
    @IBOutlet weak var startWindowLocationMenu: NSPopUpButton!
    
    @IBOutlet weak var btnRememberPlaylistLocation: NSButton!
    @IBOutlet weak var btnStartAtPlaylistLocation: NSButton!
    @IBOutlet weak var startPlaylistLocationMenu: NSPopUpButton!
    
    override var nibName: String? {return "ViewPreferences"}
    
    func getView() -> NSView {
        return self.view
    }
    
    override func viewDidLoad() {
        
        // Add all user layouts to the menu
        WindowLayouts.userDefinedLayouts.forEach({
        
            startWithViewMenu.insertItem(withTitle: $0.name, at: 0)
        })
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let viewPrefs = preferences.viewPreferences
     
        if (viewPrefs.viewOnStartup.option == .specific) {
            btnStartWithView.state = 1
        } else {
            btnRememberView.state = 1
        }
        
        startWithViewMenu.selectItem(withTitle: viewPrefs.viewOnStartup.layoutName)
        startWithViewMenu.isEnabled = Bool(btnStartWithView.state)
    }
    
    @IBAction func viewOnStartupAction(_ sender: Any) {
        startWithViewMenu.isEnabled = Bool(btnStartWithView.state)
    }
    
    @IBAction func windowLocationOnStartupAction(_ sender: Any) {
        startWindowLocationMenu.isEnabled = Bool(btnStartAtWindowLocation.state)
    }
    
    @IBAction func playlistLocationOnStartupAction(_ sender: Any) {
        startPlaylistLocationMenu.isEnabled = Bool(btnStartAtPlaylistLocation.state)
    }

    func save(_ preferences: Preferences) {
        
        let viewPrefs = preferences.viewPreferences
        
        viewPrefs.viewOnStartup.option = btnStartWithView.state == 1 ? .specific : .rememberFromLastAppLaunch
        viewPrefs.viewOnStartup.layoutName = startWithViewMenu.selectedItem!.title
    }
}
