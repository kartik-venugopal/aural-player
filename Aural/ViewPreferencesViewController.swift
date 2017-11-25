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
    
    func resetFields(_ preferences: Preferences) {
        
        let viewPrefs = preferences.viewPreferences
     
        if (viewPrefs.viewOnStartup.option == .specific) {
            btnStartWithView.state = 1
        } else {
            btnRememberView.state = 1
        }
        
        startWithViewMenu.selectItem(withTitle: viewPrefs.viewOnStartup.viewType.description)
        startWithViewMenu.isEnabled = Bool(btnStartWithView.state)
        
        btnRememberWindowLocation.state = viewPrefs.windowLocationOnStartup.option == .rememberFromLastAppLaunch ? 1 : 0
        btnStartAtWindowLocation.state = viewPrefs.windowLocationOnStartup.option == .specific ? 1 : 0
        
        startWindowLocationMenu.isEnabled = Bool(btnStartAtWindowLocation.state)
        startWindowLocationMenu.selectItem(withTitle: viewPrefs.windowLocationOnStartup.windowLocation.description)
        
        btnRememberPlaylistLocation.state = viewPrefs.playlistLocationOnStartup.option == .rememberFromLastAppLaunch ? 1 : 0
        btnStartAtPlaylistLocation.state = viewPrefs.playlistLocationOnStartup.option == .specific ? 1 : 0
        
        startPlaylistLocationMenu.isEnabled = Bool(btnStartAtPlaylistLocation.state)
        startPlaylistLocationMenu.selectItem(withTitle: viewPrefs.playlistLocationOnStartup.playlistLocation.description)
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
        viewPrefs.viewOnStartup.viewType = ViewTypes.fromDescription(startWithViewMenu.selectedItem!.title)
        
        viewPrefs.windowLocationOnStartup.option = btnRememberWindowLocation.state == 1 ? .rememberFromLastAppLaunch : .specific
        viewPrefs.windowLocationOnStartup.windowLocation = WindowLocations.fromDescription(startWindowLocationMenu.selectedItem!.title)
        
        viewPrefs.playlistLocationOnStartup.option = btnRememberPlaylistLocation.state == 1 ? .rememberFromLastAppLaunch : .specific
        viewPrefs.playlistLocationOnStartup.playlistLocation = PlaylistLocations.fromDescription(startPlaylistLocationMenu.selectedItem!.title)
    }
}
