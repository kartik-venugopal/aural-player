import Cocoa

class PlaybackPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var btnPrimarySeekLengthConstant: NSButton!
    @IBOutlet weak var btnPrimarySeekLengthPerc: NSButton!
    
    @IBOutlet weak var primarySeekLengthPicker: IntervalPicker!
    @IBOutlet weak var lblPrimarySeekLength: FormattedIntervalLabel!
    
    @IBOutlet weak var primarySeekLengthPercStepper: NSStepper!
    @IBOutlet weak var lblPrimarySeekLengthPerc: NSTextField!
    
    private var primarySeekLengthConstantFields: [NSControl] = []
    
    @IBOutlet weak var btnSecondarySeekLengthConstant: NSButton!
    @IBOutlet weak var btnSecondarySeekLengthPerc: NSButton!
    
    @IBOutlet weak var secondarySeekLengthPicker: IntervalPicker!
    @IBOutlet weak var lblSecondarySeekLength: FormattedIntervalLabel!
    
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
    
    @IBOutlet weak var btnGapBetweenTracks: NSButton!
    @IBOutlet weak var gapDurationPicker: IntervalPicker!
    @IBOutlet weak var lblGapDuration: FormattedIntervalLabel!
    
    @IBOutlet weak var btnInfo_primarySeekLength: NSButton!
    @IBOutlet weak var btnInfo_secondarySeekLength: NSButton!
    
    override var nibName: String? {return "PlaybackPreferences"}
    
    func getView() -> NSView {
        return self.view
    }
    
    override func viewDidLoad() {
        
        primarySeekLengthConstantFields = [primarySeekLengthPicker]
        secondarySeekLengthConstantFields = [secondarySeekLengthPicker]
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let playbackPrefs = preferences.playbackPreferences
        
        // Primary seek length
        
        let primarySeekLength = playbackPrefs.primarySeekLengthConstant
        primarySeekLengthPicker.setInterval(Double(primarySeekLength))
        primarySeekLengthAction(self)
        
        let primarySeekLengthPerc = playbackPrefs.primarySeekLengthPercentage
        primarySeekLengthPercStepper.integerValue = primarySeekLengthPerc
        lblPrimarySeekLengthPerc.stringValue = String(format: "%d%%", primarySeekLengthPerc)
        
        if playbackPrefs.primarySeekLengthOption == .constant {
            btnPrimarySeekLengthConstant.on()
        } else {
            btnPrimarySeekLengthPerc.on()
        }
        
        primarySeekLengthConstantFields.forEach({$0.isEnabled = playbackPrefs.primarySeekLengthOption == .constant})
        primarySeekLengthPercStepper.isEnabled = playbackPrefs.primarySeekLengthOption == .percentage
        
        // Secondary seek length
        
        let secondarySeekLength = playbackPrefs.secondarySeekLengthConstant
        secondarySeekLengthPicker.setInterval(Double(secondarySeekLength))
        secondarySeekLengthAction(self)
        
        let secondarySeekLengthPerc = playbackPrefs.secondarySeekLengthPercentage
        secondarySeekLengthPercStepper.integerValue = secondarySeekLengthPerc
        lblSecondarySeekLengthPerc.stringValue = String(format: "%d%%", secondarySeekLengthPerc)
        
        if playbackPrefs.secondarySeekLengthOption == .constant {
            btnSecondarySeekLengthConstant.on()
        } else {
            btnSecondarySeekLengthPerc.on()
        }
        
        secondarySeekLengthConstantFields.forEach({$0.isEnabled = playbackPrefs.secondarySeekLengthOption == .constant})
        secondarySeekLengthPercStepper.isEnabled = playbackPrefs.secondarySeekLengthOption == .percentage
        
        // Autoplay
        
        btnAutoplayOnStartup.onIf(playbackPrefs.autoplayOnStartup)
        
        btnAutoplayAfterAddingTracks.onIf(playbackPrefs.autoplayAfterAddingTracks)
        
        btnAutoplayIfNotPlaying.isEnabled = playbackPrefs.autoplayAfterAddingTracks
        btnAutoplayIfNotPlaying.onIf(playbackPrefs.autoplayAfterAddingOption == .ifNotPlaying)
        
        btnAutoplayAlways.isEnabled = playbackPrefs.autoplayAfterAddingTracks
        btnAutoplayAlways.onIf(playbackPrefs.autoplayAfterAddingOption == .always)
        
        // Show new track
        
        btnShowNewTrack.onIf(playbackPrefs.showNewTrackInPlaylist)
        
        // Remember last track position
        
        btnRememberPosition.onIf(playbackPrefs.rememberLastPosition)
        [btnRememberPosition_individualTracks, btnRememberPosition_allTracks].forEach({$0?.isEnabled = btnRememberPosition.isOn()})
        
        if playbackPrefs.rememberLastPositionOption == .individualTracks {
            btnRememberPosition_individualTracks.on()
        } else {
            btnRememberPosition_allTracks.on()
        }
        
        // Gap between tracks
        
        btnGapBetweenTracks.onIf(playbackPrefs.gapBetweenTracks)
        [lblGapDuration, gapDurationPicker].forEach({$0?.isEnabled = btnGapBetweenTracks.isOn()})
        gapDurationPicker.setInterval(Double(playbackPrefs.gapBetweenTracksDuration))
        gapDurationPickerAction(self)
    }
    
    @IBAction func primarySeekLengthRadioButtonAction(_ sender: Any) {
        primarySeekLengthConstantFields.forEach({$0.isEnabled = btnPrimarySeekLengthConstant.isOn()})
        primarySeekLengthPercStepper.isEnabled = btnPrimarySeekLengthPerc.isOn()
    }
    
    @IBAction func secondarySeekLengthRadioButtonAction(_ sender: Any) {
        secondarySeekLengthConstantFields.forEach({$0.isEnabled = btnSecondarySeekLengthConstant.isOn()})
        secondarySeekLengthPercStepper.isEnabled = btnSecondarySeekLengthPerc.isOn()
    }
    
    @IBAction func primarySeekLengthAction(_ sender: Any) {
        lblPrimarySeekLength.interval = primarySeekLengthPicker.interval
    }
    
    @IBAction func secondarySeekLengthAction(_ sender: Any) {
        lblSecondarySeekLength.interval = secondarySeekLengthPicker.interval
    }
    
    @IBAction func primarySeekLengthPercAction(_ sender: Any) {
        lblPrimarySeekLengthPerc.stringValue = String(format: "%d%%", primarySeekLengthPercStepper.integerValue)
    }
    
    @IBAction func secondarySeekLengthPercAction(_ sender: Any) {
        lblSecondarySeekLengthPerc.stringValue = String(format: "%d%%", secondarySeekLengthPercStepper.integerValue)
    }
    
    // When the check box for "autoplay after adding tracks" is checked/unchecked, update the enabled state of the 2 option radio buttons
    @IBAction func autoplayAfterAddingAction(_ sender: Any) {
        [btnAutoplayIfNotPlaying, btnAutoplayAlways].forEach({$0!.isEnabled = btnAutoplayAfterAddingTracks.isOn()})
    }
    
    @IBAction func autoplayAfterAddingRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func rememberLastPositionAction(_ sender: Any) {
        [btnRememberPosition_individualTracks, btnRememberPosition_allTracks].forEach({$0?.isEnabled = btnRememberPosition.isOn()})
    }
    
    @IBAction func rememberLastPositionRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func gapDurationAction(_ sender: NSButton) {
        [lblGapDuration, gapDurationPicker].forEach({$0?.isEnabled = btnGapBetweenTracks.isOn()})
    }
    
    @IBAction func gapDurationPickerAction(_ sender: Any) {
        lblGapDuration.interval = gapDurationPicker.interval
    }
    
    @IBAction func seekLengthPrimary_infoAction(_ sender: Any) {
        showInfo(Strings.info_seekLengthPrimary)
    }
    
    @IBAction func seekLengthSecondary_infoAction(_ sender: Any) {
        showInfo(Strings.info_seekLengthSecondary)
    }
    
    private func showInfo(_ text: String) {
        
        let helpManager = NSHelpManager.shared
        let textFontAttributes = convertToOptionalNSAttributedStringKeyDictionary([
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): Fonts.helpInfoTextFont
            ])
        
        helpManager.setContextHelp(NSAttributedString(string: text, attributes: textFontAttributes), for: btnInfo_primarySeekLength)
        helpManager.showContextHelp(for: btnInfo_primarySeekLength, locationHint: NSEvent.mouseLocation)
    }
    
    func save(_ preferences: Preferences) throws {
        
        let playbackPrefs = preferences.playbackPreferences
        
        playbackPrefs.primarySeekLengthOption = btnPrimarySeekLengthConstant.isOn() ? .constant : .percentage
        playbackPrefs.primarySeekLengthConstant = Int(round(primarySeekLengthPicker.interval))
        playbackPrefs.primarySeekLengthPercentage = primarySeekLengthPercStepper.integerValue
        
        playbackPrefs.secondarySeekLengthOption = btnSecondarySeekLengthConstant.isOn() ? .constant : .percentage
        playbackPrefs.secondarySeekLengthConstant = Int(round(secondarySeekLengthPicker.interval))
        playbackPrefs.secondarySeekLengthPercentage = secondarySeekLengthPercStepper.integerValue
        
        playbackPrefs.autoplayOnStartup = btnAutoplayOnStartup.isOn()
        
        playbackPrefs.autoplayAfterAddingTracks = btnAutoplayAfterAddingTracks.isOn()
        playbackPrefs.autoplayAfterAddingOption = btnAutoplayIfNotPlaying.isOn() ? .ifNotPlaying : .always
     
        playbackPrefs.showNewTrackInPlaylist = btnShowNewTrack.isOn()
        
        playbackPrefs.rememberLastPosition = btnRememberPosition.isOn()
        
        let wasAllTracks: Bool = playbackPrefs.rememberLastPositionOption == .allTracks
        
        playbackPrefs.rememberLastPositionOption = btnRememberPosition_individualTracks.isOn() ? .individualTracks : .allTracks
        
        let isNowIndividualTracks: Bool = playbackPrefs.rememberLastPositionOption == .individualTracks
        
        if !playbackPrefs.rememberLastPosition || (wasAllTracks && isNowIndividualTracks) {
            PlaybackProfiles.removeAll()
        }
        
        playbackPrefs.gapBetweenTracks = btnGapBetweenTracks.isOn()
        playbackPrefs.gapBetweenTracksDuration = Int(round(gapDurationPicker.interval))
    }
}

fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}

fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
