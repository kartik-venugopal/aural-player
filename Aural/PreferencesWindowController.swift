import Cocoa

/*
    Window controller for the preferences dialog
 */
class PreferencesWindowController: NSWindowController, NSWindowDelegate, ModalDialogDelegate {
    
    convenience init() {
        self.init(windowNibName: "Preferences")
    }
    
    @IBOutlet weak var prefsTabView: NSTabView!
    
    private var prefsTabViewButtons: [NSButton]?
    
    // Player prefs
    @IBOutlet weak var btnPlayerPrefs: NSButton!
    
    @IBOutlet weak var lblSeekLength: NSTextField!
    @IBOutlet weak var seekLengthSlider: NSSlider!
    
    @IBOutlet weak var volumeDeltaField: NSTextField!
    @IBOutlet weak var volumeDeltaStepper: NSStepper!
    
    @IBOutlet weak var btnRememberVolume: NSButton!
    @IBOutlet weak var btnSpecifyVolume: NSButton!
    
    @IBOutlet weak var startupVolumeSlider: NSSlider!
    @IBOutlet weak var lblStartupVolume: NSTextField!
    
    @IBOutlet weak var lblPanDelta: NSTextField!
    @IBOutlet weak var panDeltaStepper: NSStepper!
    
    // Playlist prefs
    @IBOutlet weak var btnPlaylistPrefs: NSButton!
    
    @IBOutlet weak var btnEmptyPlaylist: NSButton!
    @IBOutlet weak var btnRememberPlaylist: NSButton!
    
    @IBOutlet weak var btnAutoplayOnStartup: NSButton!
    
    @IBOutlet weak var btnAutoplayAfterAddingTracks: NSButton!
    @IBOutlet weak var btnAutoplayIfNotPlaying: NSButton!
    @IBOutlet weak var btnAutoplayAlways: NSButton!
    
    // View prefs
    @IBOutlet weak var btnViewPrefs: NSButton!
    
    @IBOutlet weak var btnStartWithView: NSButton!
    @IBOutlet weak var startWithViewMenu: NSPopUpButton!
    @IBOutlet weak var btnRememberView: NSButton!
    
    @IBOutlet weak var btnRememberWindowLocation: NSButton!
    @IBOutlet weak var btnStartAtWindowLocation: NSButton!
    @IBOutlet weak var startWindowLocationMenu: NSPopUpButton!
    
    @IBOutlet weak var btnRememberPlaylistLocation: NSButton!
    @IBOutlet weak var btnStartAtPlaylistLocation: NSButton!
    @IBOutlet weak var startPlaylistLocationMenu: NSPopUpButton!
    
    // Delegate that performs CRUD on user preferences
    private let preferencesDelegate: PreferencesDelegateProtocol = ObjectGraph.getPreferencesDelegate()
    
    // Cached preferences instance
    private let preferences: Preferences = ObjectGraph.getPreferencesDelegate().getPreferences()
    
    override func windowDidLoad() {
        
        window?.titlebarAppearsTransparent = true
        window?.isMovableByWindowBackground = true
        
        prefsTabViewButtons = [btnPlayerPrefs, btnPlaylistPrefs, btnViewPrefs]
        
        super.windowDidLoad()
    }
    
    func showDialog() {
     
        // Force loading of the window if it hasn't been loaded yet (only once)
        if (!self.isWindowLoaded) {
            _ = self.window!
        }
        
        resetPreferencesFields()
        
        // Select the player prefs tab
        playerPrefsTabViewAction(self)
        
        UIUtils.showModalDialog(self.window!)
    }
    
    func windowWillClose(_ notification: Notification) {
        
        resetPreferencesFields()
        
        // Select the player prefs tab
        playerPrefsTabViewAction(self)
    }
    
    private func resetPreferencesFields() {
        
        resetPlayerPrefs()
        resetPlaylistPrefs()
        resetViewPrefs()
    }
    
    private func resetPlayerPrefs() {
        
        let seekLength = preferences.seekLength_discrete
        seekLengthSlider.integerValue = seekLength
        lblSeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(seekLength)
        
        let volumeDelta = Int(round(preferences.volumeDelta_discrete * AppConstants.volumeConversion_audioGraphToUI))
        volumeDeltaStepper.integerValue = volumeDelta
        volumeDeltaField.stringValue = String(format: "%d%%", volumeDelta)
        
        btnRememberVolume.state = preferences.volumeOnStartup == .rememberFromLastAppLaunch ? 1 : 0
        
        btnSpecifyVolume.state = preferences.volumeOnStartup == .rememberFromLastAppLaunch ? 0 : 1
        
        startupVolumeSlider.isEnabled = Bool(btnSpecifyVolume.state)
        startupVolumeSlider.integerValue = Int(round(preferences.startupVolumeValue * AppConstants.volumeConversion_audioGraphToUI))
        
        lblStartupVolume.isEnabled = Bool(btnSpecifyVolume.state)
        lblStartupVolume.stringValue = String(format: "%d%%", startupVolumeSlider.integerValue)
        
        let panDelta = Int(round(preferences.panDelta * AppConstants.panConversion_audioGraphToUI))
        panDeltaStepper.integerValue = panDelta
        lblPanDelta.stringValue = String(format: "%d%%", panDelta)
    }
    
    private func resetPlaylistPrefs() {
        
        if (preferences.playlistOnStartup == .empty) {
            btnEmptyPlaylist.state = 1
        } else {
            btnRememberPlaylist.state = 1
        }
        
        btnAutoplayOnStartup.state = preferences.autoplayOnStartup ? 1 : 0
        
        btnAutoplayAfterAddingTracks.state = preferences.autoplayAfterAddingTracks ? 1 : 0
        
        btnAutoplayIfNotPlaying.isEnabled = preferences.autoplayAfterAddingTracks
        btnAutoplayIfNotPlaying.state = preferences.autoplayAfterAddingOption == .ifNotPlaying ? 1 : 0
        
        btnAutoplayAlways.isEnabled = preferences.autoplayAfterAddingTracks
        btnAutoplayAlways.state = preferences.autoplayAfterAddingOption == .always ? 1 : 0
    }
    
    private func resetViewPrefs() {
        
        if (preferences.viewOnStartup.option == .specific) {
            btnStartWithView.state = 1
        } else {
            btnRememberView.state = 1
        }
        
        startWithViewMenu.selectItem(withTitle: preferences.viewOnStartup.viewType.description)
        startWithViewMenu.isEnabled = Bool(btnStartWithView.state)
        
        btnRememberWindowLocation.state = preferences.windowLocationOnStartup.option == .rememberFromLastAppLaunch ? 1 : 0
        btnStartAtWindowLocation.state = preferences.windowLocationOnStartup.option == .specific ? 1 : 0
        
        startWindowLocationMenu.isEnabled = Bool(btnStartAtWindowLocation.state)
        startWindowLocationMenu.selectItem(withTitle: preferences.windowLocationOnStartup.windowLocation.description)
        
        btnRememberPlaylistLocation.state = preferences.playlistLocationOnStartup.option == .rememberFromLastAppLaunch ? 1 : 0
        btnStartAtPlaylistLocation.state = preferences.playlistLocationOnStartup.option == .specific ? 1 : 0
        
        startPlaylistLocationMenu.isEnabled = Bool(btnStartAtPlaylistLocation.state)
        startPlaylistLocationMenu.selectItem(withTitle: preferences.playlistLocationOnStartup.playlistLocation.description)
    }
    
    @IBAction func volumeDeltaAction(_ sender: Any) {
        volumeDeltaField.stringValue = String(format: "%d%%", volumeDeltaStepper.integerValue)
    }
    
    @IBAction func panDeltaAction(_ sender: Any) {
        lblPanDelta.stringValue = String(format: "%d%%", panDeltaStepper.integerValue)
    }
    
    @IBAction func savePreferencesAction(_ sender: Any) {
        
        // Player prefs
        
        preferences.seekLength_discrete = seekLengthSlider.integerValue
        
        preferences.volumeDelta_discrete = volumeDeltaStepper.floatValue * AppConstants.volumeConversion_UIToAudioGraph
        
        preferences.volumeOnStartup = btnRememberVolume.state == 1 ? .rememberFromLastAppLaunch : .specific
        preferences.startupVolumeValue = Float(startupVolumeSlider.integerValue) * AppConstants.volumeConversion_UIToAudioGraph
        
        preferences.panDelta = panDeltaStepper.floatValue * AppConstants.panConversion_UIToAudioGraph
        
        // Playlist prefs
        
        preferences.playlistOnStartup = btnEmptyPlaylist.state == 1 ? .empty : .rememberFromLastAppLaunch
        
        preferences.autoplayOnStartup = Bool(btnAutoplayOnStartup.state)
        
        preferences.autoplayAfterAddingTracks = Bool(btnAutoplayAfterAddingTracks.state)
        preferences.autoplayAfterAddingOption = btnAutoplayIfNotPlaying.state == 1 ? .ifNotPlaying : .always
        
        // View prefs
        
        preferences.viewOnStartup.option = btnStartWithView.state == 1 ? .specific : .rememberFromLastAppLaunch
        
        for viewType in ViewTypes.allValues {
            
            if startWithViewMenu.selectedItem!.title == viewType.description {
                preferences.viewOnStartup.viewType = viewType
                break;
            }
        }
        
        preferences.windowLocationOnStartup.option = btnRememberWindowLocation.state == 1 ? .rememberFromLastAppLaunch : .specific
        
        preferences.windowLocationOnStartup.windowLocation = WindowLocations.fromDescription(startWindowLocationMenu.selectedItem!.title)
        
        preferences.playlistLocationOnStartup.option = btnRememberPlaylistLocation.state == 1 ? .rememberFromLastAppLaunch : .specific
        
        preferences.playlistLocationOnStartup.playlistLocation = PlaylistLocations.fromDescription(startPlaylistLocationMenu.selectedItem!.title)
        
        preferencesDelegate.savePreferences(preferences)
        UIUtils.dismissModalDialog()
    }
    
    @IBAction func cancelPreferencesAction(_ sender: Any) {
        UIUtils.dismissModalDialog()
    }
    
    @IBAction func seekLengthAction(_ sender: Any) {
        
        let value = seekLengthSlider.integerValue
        lblSeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(value)
    }
    
    @IBAction func seekLengthIncrementAction(_ sender: Any) {
        
        if (Double(seekLengthSlider.integerValue) < seekLengthSlider.maxValue) {
            seekLengthSlider.integerValue += 1
            lblSeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(seekLengthSlider.integerValue)
        }
    }
    
    @IBAction func seekLengthDecrementAction(_ sender: Any) {
        
        if (Double(seekLengthSlider.integerValue) > seekLengthSlider.minValue) {
            seekLengthSlider.integerValue -= 1
            lblSeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(seekLengthSlider.integerValue)
        }
    }
    
    @IBAction func playerPrefsTabViewAction(_ sender: Any) {
        
        prefsTabViewButtons!.forEach({$0.state = 0})
        
        btnPlayerPrefs.state = 1
        prefsTabView.selectTabViewItem(at: 0)
    }
    
    @IBAction func playlistPrefsTabViewAction(_ sender: Any) {
        
        prefsTabViewButtons!.forEach({$0.state = 0})
        
        btnPlaylistPrefs.state = 1
        prefsTabView.selectTabViewItem(at: 1)
    }
    
    @IBAction func viewPrefsTabViewAction(_ sender: Any) {
        
        prefsTabViewButtons!.forEach({$0.state = 0})
        
        btnViewPrefs.state = 1
        prefsTabView.selectTabViewItem(at: 2)
    }
    
    @IBAction func startupPlaylistPrefAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func startupViewPrefAction(_ sender: Any) {
        startWithViewMenu.isEnabled = Bool(btnStartWithView.state)
    }
    
    // When the check box for "autoplay after adding tracks" is checked/unchecked, update the enabled state of the 2 option radio buttons
    @IBAction func autoplayAfterAddingAction(_ sender: Any) {
        [btnAutoplayIfNotPlaying, btnAutoplayAlways].forEach({$0!.isEnabled = Bool(btnAutoplayAfterAddingTracks.state)})
    }
    
    @IBAction func autoplayAfterAddingRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func startupVolumeButtonAction(_ sender: Any) {
        [startupVolumeSlider, lblStartupVolume].forEach({$0.isEnabled = Bool(btnSpecifyVolume.state)})
    }
    
    @IBAction func startupVolumeSliderAction(_ sender: Any) {
        lblStartupVolume.stringValue = String(format: "%d%%", startupVolumeSlider.integerValue)
    }
    
    @IBAction func windowLocationOnStartupAction(_ sender: Any) {
        startWindowLocationMenu.isEnabled = Bool(btnStartAtWindowLocation.state)
    }
    
    @IBAction func playlistLocationOnStartupAction(_ sender: Any) {
        startPlaylistLocationMenu.isEnabled = Bool(btnStartAtPlaylistLocation.state)
    }
}

// Int to Bool conversion
extension Bool {
    init<T: Integer>(_ num: T) {
        self.init(num != 0)
    }
}
