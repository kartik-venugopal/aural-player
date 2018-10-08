import Cocoa

class PlaybackPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var lblSeekLength: NSTextField!
    @IBOutlet weak var seekLengthSlider: NSSlider!
    
    @IBOutlet weak var lblSecondarySeekLength: NSTextField!
    @IBOutlet weak var secondarySeekLengthSlider: NSSlider!
    
    @IBOutlet weak var btnAutoplayOnStartup: NSButton!
    
    @IBOutlet weak var btnAutoplayAfterAddingTracks: NSButton!
    @IBOutlet weak var btnAutoplayIfNotPlaying: NSButton!
    @IBOutlet weak var btnAutoplayAlways: NSButton!
    
    @IBOutlet weak var btnShowNewTrack: NSButton!
    
    @IBOutlet weak var btnRememberPosition: NSButton!
    @IBOutlet weak var btnRememberPosition_allTracks: NSButton!
    @IBOutlet weak var btnRememberPosition_individualTracks: NSButton!
    
    override var nibName: String? {return "PlaybackPreferences"}
    
    func getView() -> NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let playbackPrefs = preferences.playbackPreferences
        
        let seekLength = playbackPrefs.seekLength
        seekLengthSlider.integerValue = seekLength
        lblSeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(seekLength)
        
        let secondarySeekLength = playbackPrefs.seekLength_secondary
        secondarySeekLengthSlider.integerValue = secondarySeekLength
        lblSecondarySeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(secondarySeekLength)
        
        btnAutoplayOnStartup.state = NSControl.StateValue(rawValue: playbackPrefs.autoplayOnStartup ? 1 : 0)
        
        btnAutoplayAfterAddingTracks.state = NSControl.StateValue(rawValue: playbackPrefs.autoplayAfterAddingTracks ? 1 : 0)
        
        btnAutoplayIfNotPlaying.isEnabled = playbackPrefs.autoplayAfterAddingTracks
        btnAutoplayIfNotPlaying.state = NSControl.StateValue(rawValue: playbackPrefs.autoplayAfterAddingOption == .ifNotPlaying ? 1 : 0)
        
        btnAutoplayAlways.isEnabled = playbackPrefs.autoplayAfterAddingTracks
        btnAutoplayAlways.state = NSControl.StateValue(rawValue: playbackPrefs.autoplayAfterAddingOption == .always ? 1 : 0)
        
        btnShowNewTrack.state = NSControl.StateValue(rawValue: playbackPrefs.showNewTrackInPlaylist ? 1 : 0)
        
        btnRememberPosition.state = NSControl.StateValue(rawValue: playbackPrefs.rememberLastPosition ? 1 : 0)
        [btnRememberPosition_individualTracks, btnRememberPosition_allTracks].forEach({$0?.isEnabled = Bool(btnRememberPosition.state.rawValue)})
        
        if playbackPrefs.rememberLastPositionOption == .individualTracks {
            btnRememberPosition_individualTracks.state = UIConstants.buttonState_1
        } else {
            btnRememberPosition_allTracks.state = UIConstants.buttonState_1
        }
    }
    
    @IBAction func seekLengthAction(_ sender: Any) {
        lblSeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(seekLengthSlider.integerValue)
    }
    
    @IBAction func secondarySeekLengthAction(_ sender: Any) {
        lblSecondarySeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(secondarySeekLengthSlider.integerValue)
    }
    
    @IBAction func seekLengthIncrementAction(_ sender: Any) {
        
        if (Double(seekLengthSlider.integerValue) < seekLengthSlider.maxValue) {
            seekLengthSlider.integerValue += 1
            lblSeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(seekLengthSlider.integerValue)
        }
    }
    
    @IBAction func secondarySeekLengthIncrementAction(_ sender: Any) {
        
        if (Double(secondarySeekLengthSlider.integerValue) < secondarySeekLengthSlider.maxValue) {
            secondarySeekLengthSlider.integerValue += 1
            lblSecondarySeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(secondarySeekLengthSlider.integerValue)
        }
    }
    
    @IBAction func seekLengthDecrementAction(_ sender: Any) {
        
        if (Double(seekLengthSlider.integerValue) > seekLengthSlider.minValue) {
            seekLengthSlider.integerValue -= 1
            lblSeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(seekLengthSlider.integerValue)
        }
    }
    
    @IBAction func secondarySeekLengthDecrementAction(_ sender: Any) {
        
        if (Double(secondarySeekLengthSlider.integerValue) > secondarySeekLengthSlider.minValue) {
            secondarySeekLengthSlider.integerValue -= 1
            lblSecondarySeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(secondarySeekLengthSlider.integerValue)
        }
    }
    
    // When the check box for "autoplay after adding tracks" is checked/unchecked, update the enabled state of the 2 option radio buttons
    @IBAction func autoplayAfterAddingAction(_ sender: Any) {
        [btnAutoplayIfNotPlaying, btnAutoplayAlways].forEach({$0!.isEnabled = Bool(btnAutoplayAfterAddingTracks.state.rawValue)})
    }
    
    @IBAction func autoplayAfterAddingRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func rememberLastPositionAction(_ sender: Any) {
        [btnRememberPosition_individualTracks, btnRememberPosition_allTracks].forEach({$0?.isEnabled = Bool(btnRememberPosition.state.rawValue)})
    }
    
    @IBAction func rememberLastPositionRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    func save(_ preferences: Preferences) throws {
        
        let playbackPrefs = preferences.playbackPreferences
        
        playbackPrefs.seekLength = seekLengthSlider.integerValue
        playbackPrefs.seekLength_secondary = secondarySeekLengthSlider.integerValue
        
        playbackPrefs.autoplayOnStartup = Bool(btnAutoplayOnStartup.state.rawValue)
        
        playbackPrefs.autoplayAfterAddingTracks = Bool(btnAutoplayAfterAddingTracks.state.rawValue)
        playbackPrefs.autoplayAfterAddingOption = btnAutoplayIfNotPlaying.state.rawValue == 1 ? .ifNotPlaying : .always
     
        playbackPrefs.showNewTrackInPlaylist = Bool(btnShowNewTrack.state.rawValue)
        
        playbackPrefs.rememberLastPosition = Bool(btnRememberPosition.state.rawValue)
        
        let wasAllTracks: Bool = playbackPrefs.rememberLastPositionOption == .allTracks
        
        playbackPrefs.rememberLastPositionOption = btnRememberPosition_individualTracks.state == UIConstants.buttonState_1 ? .individualTracks : .allTracks
        
        let isNowIndividualTracks: Bool = playbackPrefs.rememberLastPositionOption == .individualTracks
        
        if !playbackPrefs.rememberLastPosition || (wasAllTracks && isNowIndividualTracks) {
            PlaybackProfiles.removeAll()
        }
    }
}
