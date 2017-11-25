import Cocoa

class PlaylistPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var btnEmptyPlaylist: NSButton!
    @IBOutlet weak var btnRememberPlaylist: NSButton!
    
    override var nibName: String? {return "PlaylistPreferences"}
    
    func getView() -> NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
     
        if (preferences.playlistPreferences.playlistOnStartup == .empty) {
            btnEmptyPlaylist.state = 1
        } else {
            btnRememberPlaylist.state = 1
        }
    }
    
    @IBAction func startupPlaylistPrefAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    func save(_ preferences: Preferences) {
        preferences.playlistPreferences.playlistOnStartup = btnEmptyPlaylist.state == 1 ? .empty : .rememberFromLastAppLaunch
    }
}
