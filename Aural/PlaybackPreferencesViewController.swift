import Cocoa

class PlaybackPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var lblSeekLength: NSTextField!
    @IBOutlet weak var seekLengthSlider: NSSlider!
    
    @IBOutlet weak var btnAutoplayOnStartup: NSButton!
    
    @IBOutlet weak var btnAutoplayAfterAddingTracks: NSButton!
    @IBOutlet weak var btnAutoplayIfNotPlaying: NSButton!
    @IBOutlet weak var btnAutoplayAlways: NSButton!
    
    convenience init() {
        self.init(nibName: "PlaybackPreferences", bundle: Bundle.main)!
    }
    
    func getView() -> NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let playbackPrefs = preferences.playbackPreferences
        
        let seekLength = playbackPrefs.seekLength
        seekLengthSlider.integerValue = seekLength
        lblSeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(seekLength)
        
        btnAutoplayOnStartup.state = playbackPrefs.autoplayOnStartup ? 1 : 0
        
        btnAutoplayAfterAddingTracks.state = playbackPrefs.autoplayAfterAddingTracks ? 1 : 0
        
        btnAutoplayIfNotPlaying.isEnabled = playbackPrefs.autoplayAfterAddingTracks
        btnAutoplayIfNotPlaying.state = playbackPrefs.autoplayAfterAddingOption == .ifNotPlaying ? 1 : 0
        
        btnAutoplayAlways.isEnabled = playbackPrefs.autoplayAfterAddingTracks
        btnAutoplayAlways.state = playbackPrefs.autoplayAfterAddingOption == .always ? 1 : 0
    }
    
    @IBAction func seekLengthAction(_ sender: Any) {
        lblSeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(seekLengthSlider.integerValue)
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
    
    // When the check box for "autoplay after adding tracks" is checked/unchecked, update the enabled state of the 2 option radio buttons
    @IBAction func autoplayAfterAddingAction(_ sender: Any) {
        [btnAutoplayIfNotPlaying, btnAutoplayAlways].forEach({$0!.isEnabled = Bool(btnAutoplayAfterAddingTracks.state)})
    }
    
    @IBAction func autoplayAfterAddingRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    func save(_ preferences: Preferences) {
        
        let playbackPrefs = preferences.playbackPreferences
        
        playbackPrefs.seekLength = seekLengthSlider.integerValue
        
        playbackPrefs.autoplayOnStartup = Bool(btnAutoplayOnStartup.state)
        
        playbackPrefs.autoplayAfterAddingTracks = Bool(btnAutoplayAfterAddingTracks.state)
        playbackPrefs.autoplayAfterAddingOption = btnAutoplayIfNotPlaying.state == 1 ? .ifNotPlaying : .always
    }
}
