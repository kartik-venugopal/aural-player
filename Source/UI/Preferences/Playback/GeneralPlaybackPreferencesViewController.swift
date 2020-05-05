import Cocoa

class GeneralPlaybackPreferencesViewController: NSViewController, PreferencesViewProtocol {

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
    
    @IBOutlet weak var btnRememberPosition: NSButton!
    @IBOutlet weak var btnRememberPosition_allTracks: NSButton!
    @IBOutlet weak var btnRememberPosition_individualTracks: NSButton!
    
    @IBOutlet weak var btnGapBetweenTracks: NSButton!
    @IBOutlet weak var gapDurationPicker: IntervalPicker!
    @IBOutlet weak var lblGapDuration: FormattedIntervalLabel!
    
    @IBOutlet weak var btnInfo_primarySeekLength: NSButton!
    @IBOutlet weak var btnInfo_secondarySeekLength: NSButton!
    
    private lazy var playbackProfiles: PlaybackProfiles = ObjectGraph.playbackDelegate.profiles
    
    var preferencesView: NSView {
        return self.view
    }
    
    override func viewDidLoad() {
        
        primarySeekLengthConstantFields = [primarySeekLengthPicker]
        secondarySeekLengthConstantFields = [secondarySeekLengthPicker]
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let prefs = preferences.playbackPreferences
        
        // Primary seek length
        
        let primarySeekLength = prefs.primarySeekLengthConstant
        primarySeekLengthPicker.setInterval(Double(primarySeekLength))
        primarySeekLengthAction(self)
        
        let primarySeekLengthPerc = prefs.primarySeekLengthPercentage
        primarySeekLengthPercStepper.integerValue = primarySeekLengthPerc
        lblPrimarySeekLengthPerc.stringValue = String(format: "%d%%", primarySeekLengthPerc)
        
        if prefs.primarySeekLengthOption == .constant {
            btnPrimarySeekLengthConstant.on()
        } else {
            btnPrimarySeekLengthPerc.on()
        }
        
        primarySeekLengthConstantFields.forEach({$0.enableIf(prefs.primarySeekLengthOption == .constant)})
        primarySeekLengthPercStepper.enableIf(prefs.primarySeekLengthOption == .percentage)
        
        // Secondary seek length
        
        let secondarySeekLength = prefs.secondarySeekLengthConstant
        secondarySeekLengthPicker.setInterval(Double(secondarySeekLength))
        secondarySeekLengthAction(self)
        
        let secondarySeekLengthPerc = prefs.secondarySeekLengthPercentage
        secondarySeekLengthPercStepper.integerValue = secondarySeekLengthPerc
        lblSecondarySeekLengthPerc.stringValue = String(format: "%d%%", secondarySeekLengthPerc)
        
        if prefs.secondarySeekLengthOption == .constant {
            btnSecondarySeekLengthConstant.on()
        } else {
            btnSecondarySeekLengthPerc.on()
        }
        
        secondarySeekLengthConstantFields.forEach({$0.enableIf(prefs.secondarySeekLengthOption == .constant)})
        secondarySeekLengthPercStepper.enableIf(prefs.secondarySeekLengthOption == .percentage)
        
        // Autoplay
        
        btnAutoplayOnStartup.onIf(prefs.autoplayOnStartup)
        
        btnAutoplayAfterAddingTracks.onIf(prefs.autoplayAfterAddingTracks)
        
        btnAutoplayIfNotPlaying.enableIf(prefs.autoplayAfterAddingTracks)
        btnAutoplayIfNotPlaying.onIf(prefs.autoplayAfterAddingOption == .ifNotPlaying)
        
        btnAutoplayAlways.enableIf(prefs.autoplayAfterAddingTracks)
        btnAutoplayAlways.onIf(prefs.autoplayAfterAddingOption == .always)
        
        // Remember last track position
        
        btnRememberPosition.onIf(prefs.rememberLastPosition)
        [btnRememberPosition_individualTracks, btnRememberPosition_allTracks].forEach({$0?.enableIf(btnRememberPosition.isOn)})
        
        if prefs.rememberLastPositionOption == .individualTracks {
            btnRememberPosition_individualTracks.on()
        } else {
            btnRememberPosition_allTracks.on()
        }
        
        // Gap between tracks
        
        btnGapBetweenTracks.onIf(prefs.gapBetweenTracks)
        [lblGapDuration, gapDurationPicker].forEach({$0?.enableIf(btnGapBetweenTracks.isOn)})
        gapDurationPicker.setInterval(Double(prefs.gapBetweenTracksDuration))
        gapDurationPickerAction(self)
    }
    
    @IBAction func primarySeekLengthRadioButtonAction(_ sender: Any) {
        primarySeekLengthConstantFields.forEach({$0.enableIf(btnPrimarySeekLengthConstant.isOn)})
        primarySeekLengthPercStepper.enableIf(btnPrimarySeekLengthPerc.isOn)
    }
    
    @IBAction func secondarySeekLengthRadioButtonAction(_ sender: Any) {
        secondarySeekLengthConstantFields.forEach({$0.enableIf(btnSecondarySeekLengthConstant.isOn)})
        secondarySeekLengthPercStepper.enableIf(btnSecondarySeekLengthPerc.isOn)
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
        [btnAutoplayIfNotPlaying, btnAutoplayAlways].forEach({$0!.enableIf(btnAutoplayAfterAddingTracks.isOn)})
    }
    
    @IBAction func autoplayAfterAddingRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func rememberLastPositionAction(_ sender: Any) {
        [btnRememberPosition_individualTracks, btnRememberPosition_allTracks].forEach({$0?.enableIf(btnRememberPosition.isOn)})
    }
    
    @IBAction func rememberLastPositionRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func gapDurationAction(_ sender: NSButton) {
        [lblGapDuration, gapDurationPicker].forEach({$0?.enableIf(btnGapBetweenTracks.isOn)})
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
            NSAttributedString.Key.font.rawValue: Fonts.helpInfoTextFont
            ])
        
        helpManager.setContextHelp(NSAttributedString(string: text, attributes: textFontAttributes), for: btnInfo_primarySeekLength!)
        helpManager.showContextHelp(for: btnInfo_primarySeekLength!, locationHint: NSEvent.mouseLocation)
    }
    
    func save(_ preferences: Preferences) throws {
        
        let prefs = preferences.playbackPreferences
        
        prefs.primarySeekLengthOption = btnPrimarySeekLengthConstant.isOn ? .constant : .percentage
        prefs.primarySeekLengthConstant = Int(round(primarySeekLengthPicker.interval))
        prefs.primarySeekLengthPercentage = primarySeekLengthPercStepper.integerValue
        
        prefs.secondarySeekLengthOption = btnSecondarySeekLengthConstant.isOn ? .constant : .percentage
        prefs.secondarySeekLengthConstant = Int(round(secondarySeekLengthPicker.interval))
        prefs.secondarySeekLengthPercentage = secondarySeekLengthPercStepper.integerValue
        
        prefs.autoplayOnStartup = btnAutoplayOnStartup.isOn
        
        prefs.autoplayAfterAddingTracks = btnAutoplayAfterAddingTracks.isOn
        prefs.autoplayAfterAddingOption = btnAutoplayIfNotPlaying.isOn ? .ifNotPlaying : .always
        
        prefs.rememberLastPosition = btnRememberPosition.isOn
        
        let wasAllTracks: Bool = prefs.rememberLastPositionOption == .allTracks
        
        prefs.rememberLastPositionOption = btnRememberPosition_individualTracks.isOn ? .individualTracks : .allTracks
        
        let isNowIndividualTracks: Bool = prefs.rememberLastPositionOption == .individualTracks
        
        if !prefs.rememberLastPosition || (wasAllTracks && isNowIndividualTracks) {
            playbackProfiles.removeAll()
        }
        
        prefs.gapBetweenTracks = btnGapBetweenTracks.isOn
        prefs.gapBetweenTracksDuration = Int(round(gapDurationPicker.interval))
    }
}

fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

