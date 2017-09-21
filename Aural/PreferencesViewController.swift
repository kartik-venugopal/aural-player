/*
    View controller for the Preferences modal dialog
 */

import Cocoa

class PreferencesViewController: NSViewController {
    
    @IBOutlet weak var prefsPanel: NSPanel!
    @IBOutlet weak var prefsTabView: NSTabView!
    
    private var prefsTabViewButtons: [NSButton]?
    
    // Player prefs
    @IBOutlet weak var btnPlayerPrefs: NSButton!
    
    @IBOutlet weak var seekLengthField: NSTextField!
    @IBOutlet weak var seekLengthSlider: NSSlider!
    
    @IBOutlet weak var volumeDeltaField: NSTextField!
    @IBOutlet weak var volumeDeltaStepper: NSStepper!
    
    @IBOutlet weak var btnRememberVolume: NSButton!
    @IBOutlet weak var btnSpecifyVolume: NSButton!
    
    @IBOutlet weak var startupVolumeSlider: NSSlider!
    @IBOutlet weak var lblStartupVolume: NSTextField!
    
    @IBOutlet weak var panDeltaField: NSTextField!
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
    
    private let preferencesDelegate: PreferencesDelegateProtocol = ObjectGraph.getPreferencesDelegate()
    private let preferences: Preferences = ObjectGraph.getPreferencesDelegate().getPreferences()
    
    override func viewDidLoad() {
        
        prefsPanel.titlebarAppearsTransparent = true
        prefsTabViewButtons = [btnPlayerPrefs, btnPlaylistPrefs, btnViewPrefs]
        
        resetPreferencesFields()
    }
    
    private func resetPreferencesFields() {
        
        resetPlayerPrefs()
        resetPlaylistPrefs()
        resetViewPrefs()
        
        // Select the player prefs tab
        playerPrefsTabViewAction(self)
    }
    
    private func resetPlayerPrefs() {
        
        let seekLength = preferences.seekLength
        seekLengthSlider.integerValue = seekLength
        seekLengthField.stringValue = Utils.formatDuration_minSec(seekLength)
        
        let volumeDelta = Int(round(preferences.volumeDelta * AppConstants.volumeConversion_audioGraphToUI))
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
        panDeltaField.stringValue = String(format: "%d%%", panDelta)
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
    }
    
    @IBAction func preferencesAction(_ sender: Any) {
        
        resetPreferencesFields()
        UIUtils.showModalDialog(prefsPanel)
    }
    
    @IBAction func volumeDeltaAction(_ sender: Any) {
        
        let value = volumeDeltaStepper.integerValue
        volumeDeltaField.stringValue = String(format: "%d%%", value)
    }
    
    @IBAction func panDeltaAction(_ sender: Any) {
        
        let value = panDeltaStepper.integerValue
        panDeltaField.stringValue = String(format: "%d%%", value)
    }
    
    @IBAction func savePreferencesAction(_ sender: Any) {
        
        // Player prefs
        
        preferences.seekLength = seekLengthSlider.integerValue
        
        preferences.volumeDelta = volumeDeltaStepper.floatValue * AppConstants.volumeConversion_UIToAudioGraph
        
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
        
        dismissModalDialog()
        preferencesDelegate.savePreferences(preferences)
    }
    
    private func dismissModalDialog() {
        NSApp.stopModal()
    }
    
    @IBAction func cancelPreferencesAction(_ sender: Any) {
        dismissModalDialog()
    }
    
    @IBAction func seekLengthAction(_ sender: Any) {
        
        let value = seekLengthSlider.integerValue
        seekLengthField.stringValue = Utils.formatDuration_minSec(value)
    }
    
    @IBAction func seekLengthIncrementAction(_ sender: Any) {
        
        if (Double(seekLengthSlider.integerValue) < seekLengthSlider.maxValue) {
            seekLengthSlider.integerValue += 1
            seekLengthField.stringValue = Utils.formatDuration_minSec(seekLengthSlider.integerValue)
        }
    }
    
    @IBAction func seekLengthDecrementAction(_ sender: Any) {
        
        if (Double(seekLengthSlider.integerValue) > seekLengthSlider.minValue) {
            seekLengthSlider.integerValue -= 1
            seekLengthField.stringValue = Utils.formatDuration_minSec(seekLengthSlider.integerValue)
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
        [btnAutoplayIfNotPlaying, btnAutoplayAlways].forEach({$0.isEnabled = Bool(btnAutoplayAfterAddingTracks.state)})
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
}

// Int to Bool conversion
extension Bool {
    init<T: Integer>(_ num: T) {
        self.init(num != 0)
    }
}
