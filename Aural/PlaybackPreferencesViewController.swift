import Cocoa

class PlaybackPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var btnPrimarySeekLengthConstant: NSButton!
    @IBOutlet weak var btnPrimarySeekLengthPerc: NSButton!
    
    @IBOutlet weak var primarySeekLengthSlider: NSSlider!
    @IBOutlet weak var btnPrimarySeekLengthIncrement: NSButton!
    @IBOutlet weak var btnPrimarySeekLengthDecrement: NSButton!
    @IBOutlet weak var lblPrimarySeekLength: NSTextField!
    
    @IBOutlet weak var primarySeekLengthPercStepper: NSStepper!
    @IBOutlet weak var lblPrimarySeekLengthPerc: NSTextField!
    
    private var primarySeekLengthConstantFields: [NSControl] = []
    
    @IBOutlet weak var btnSecondarySeekLengthConstant: NSButton!
    @IBOutlet weak var btnSecondarySeekLengthPerc: NSButton!
    
    @IBOutlet weak var secondarySeekLengthSlider: NSSlider!
    @IBOutlet weak var btnSecondarySeekLengthIncrement: NSButton!
    @IBOutlet weak var btnSecondarySeekLengthDecrement: NSButton!
    @IBOutlet weak var lblSecondarySeekLength: NSTextField!
    
    @IBOutlet weak var secondarySeekLengthPercStepper: NSStepper!
    @IBOutlet weak var lblSecondarySeekLengthPerc: NSTextField!
    
    private var secondarySeekLengthConstantFields: [NSControl] = []
    
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
    
    override func viewDidLoad() {
        
        primarySeekLengthConstantFields = [btnPrimarySeekLengthDecrement, btnPrimarySeekLengthIncrement, primarySeekLengthSlider]
        secondarySeekLengthConstantFields = [btnSecondarySeekLengthDecrement, btnSecondarySeekLengthIncrement, secondarySeekLengthSlider]
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let playbackPrefs = preferences.playbackPreferences
        
        // Primary seek length
        
        let primarySeekLength = playbackPrefs.primarySeekLengthConstant
        primarySeekLengthSlider.integerValue = primarySeekLength
        lblPrimarySeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(primarySeekLength)
        
        let primarySeekLengthPerc = playbackPrefs.primarySeekLengthPercentage
        primarySeekLengthPercStepper.integerValue = primarySeekLengthPerc
        lblPrimarySeekLengthPerc.stringValue = String(format: "%d%%", primarySeekLengthPerc)
        
        if playbackPrefs.primarySeekLengthOption == .constant {
            btnPrimarySeekLengthConstant.state = UIConstants.buttonState_1
        } else {
            btnPrimarySeekLengthPerc.state = UIConstants.buttonState_1
        }
        
        primarySeekLengthConstantFields.forEach({$0.isEnabled = playbackPrefs.primarySeekLengthOption == .constant})
        primarySeekLengthPercStepper.isEnabled = playbackPrefs.primarySeekLengthOption == .percentage
        
        // Secondary seek length
        
        let secondarySeekLength = playbackPrefs.secondarySeekLengthConstant
        secondarySeekLengthSlider.integerValue = secondarySeekLength
        lblSecondarySeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(secondarySeekLength)
        
        let secondarySeekLengthPerc = playbackPrefs.secondarySeekLengthPercentage
        secondarySeekLengthPercStepper.integerValue = secondarySeekLengthPerc
        lblSecondarySeekLengthPerc.stringValue = String(format: "%d%%", secondarySeekLengthPerc)
        
        if playbackPrefs.secondarySeekLengthOption == .constant {
            btnSecondarySeekLengthConstant.state = UIConstants.buttonState_1
        } else {
            btnSecondarySeekLengthPerc.state = UIConstants.buttonState_1
        }
        
        secondarySeekLengthConstantFields.forEach({$0.isEnabled = playbackPrefs.secondarySeekLengthOption == .constant})
        secondarySeekLengthPercStepper.isEnabled = playbackPrefs.secondarySeekLengthOption == .percentage
        
        // Autoplay
        
        btnAutoplayOnStartup.state = NSControl.StateValue(rawValue: playbackPrefs.autoplayOnStartup ? 1 : 0)
        
        btnAutoplayAfterAddingTracks.state = NSControl.StateValue(rawValue: playbackPrefs.autoplayAfterAddingTracks ? 1 : 0)
        
        btnAutoplayIfNotPlaying.isEnabled = playbackPrefs.autoplayAfterAddingTracks
        btnAutoplayIfNotPlaying.state = NSControl.StateValue(rawValue: playbackPrefs.autoplayAfterAddingOption == .ifNotPlaying ? 1 : 0)
        
        btnAutoplayAlways.isEnabled = playbackPrefs.autoplayAfterAddingTracks
        btnAutoplayAlways.state = NSControl.StateValue(rawValue: playbackPrefs.autoplayAfterAddingOption == .always ? 1 : 0)
        
        // Show new track
        
        btnShowNewTrack.state = NSControl.StateValue(rawValue: playbackPrefs.showNewTrackInPlaylist ? 1 : 0)
        
        // Remember last track position
        
        btnRememberPosition.state = NSControl.StateValue(rawValue: playbackPrefs.rememberLastPosition ? 1 : 0)
        [btnRememberPosition_individualTracks, btnRememberPosition_allTracks].forEach({$0?.isEnabled = Bool(btnRememberPosition.state.rawValue)})
        
        if playbackPrefs.rememberLastPositionOption == .individualTracks {
            btnRememberPosition_individualTracks.state = UIConstants.buttonState_1
        } else {
            btnRememberPosition_allTracks.state = UIConstants.buttonState_1
        }
    }
    
    @IBAction func primarySeekLengthRadioButtonAction(_ sender: Any) {
        primarySeekLengthConstantFields.forEach({$0.isEnabled = btnPrimarySeekLengthConstant.state.rawValue == 1})
        primarySeekLengthPercStepper.isEnabled = btnPrimarySeekLengthPerc.state.rawValue == 1
    }
    
    @IBAction func secondarySeekLengthRadioButtonAction(_ sender: Any) {
        secondarySeekLengthConstantFields.forEach({$0.isEnabled = btnSecondarySeekLengthConstant.state.rawValue == 1})
        secondarySeekLengthPercStepper.isEnabled = btnSecondarySeekLengthPerc.state.rawValue == 1
    }
    
    @IBAction func primarySeekLengthAction(_ sender: Any) {
        lblPrimarySeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(primarySeekLengthSlider.integerValue)
    }
    
    @IBAction func secondarySeekLengthAction(_ sender: Any) {
        lblSecondarySeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(secondarySeekLengthSlider.integerValue)
    }
    
    @IBAction func primarySeekLengthIncrementAction(_ sender: Any) {
        
        if (Double(primarySeekLengthSlider.integerValue) < primarySeekLengthSlider.maxValue) {
            primarySeekLengthSlider.integerValue += 1
            lblPrimarySeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(primarySeekLengthSlider.integerValue)
        }
    }
    
    @IBAction func secondarySeekLengthIncrementAction(_ sender: Any) {
        
        if (Double(secondarySeekLengthSlider.integerValue) < secondarySeekLengthSlider.maxValue) {
            secondarySeekLengthSlider.integerValue += 1
            lblSecondarySeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(secondarySeekLengthSlider.integerValue)
        }
    }
    
    @IBAction func primarySeekLengthDecrementAction(_ sender: Any) {
        
        if (Double(primarySeekLengthSlider.integerValue) > primarySeekLengthSlider.minValue) {
            primarySeekLengthSlider.integerValue -= 1
            lblPrimarySeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(primarySeekLengthSlider.integerValue)
        }
    }
    
    @IBAction func secondarySeekLengthDecrementAction(_ sender: Any) {
        
        if (Double(secondarySeekLengthSlider.integerValue) > secondarySeekLengthSlider.minValue) {
            secondarySeekLengthSlider.integerValue -= 1
            lblSecondarySeekLength.stringValue = StringUtils.formatSecondsToHMS_minSec(secondarySeekLengthSlider.integerValue)
        }
    }
    
    @IBAction func primarySeekLengthPercAction(_ sender: Any) {
        lblPrimarySeekLengthPerc.stringValue = String(format: "%d%%", primarySeekLengthPercStepper.integerValue)
    }
    
    @IBAction func secondarySeekLengthPercAction(_ sender: Any) {
        lblSecondarySeekLengthPerc.stringValue = String(format: "%d%%", secondarySeekLengthPercStepper.integerValue)
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
        
        playbackPrefs.primarySeekLengthOption = btnPrimarySeekLengthConstant.state.rawValue == 1 ? .constant : .percentage
        playbackPrefs.primarySeekLengthConstant = primarySeekLengthSlider.integerValue
        playbackPrefs.primarySeekLengthPercentage = primarySeekLengthPercStepper.integerValue
        
        playbackPrefs.secondarySeekLengthOption = btnSecondarySeekLengthConstant.state.rawValue == 1 ? .constant : .percentage
        playbackPrefs.secondarySeekLengthConstant = secondarySeekLengthSlider.integerValue
        playbackPrefs.secondarySeekLengthPercentage = secondarySeekLengthPercStepper.integerValue
        
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
