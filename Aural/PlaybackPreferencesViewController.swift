import Cocoa

class PlaybackPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var tabView: AuralTabView!
    
    // General preferences
    
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
    
    // Transcoding preferences
    
    @IBOutlet weak var btnSaveFiles: NSButton!
    @IBOutlet weak var btnDeleteFiles: NSButton!
    
    @IBOutlet weak var btnLimitSpace: NSButton!
    @IBOutlet weak var maxSpaceSlider: NSSlider!
    @IBOutlet weak var lblMaxSpace: NSTextField!
    @IBOutlet weak var lblCurrentUsage: NSTextField!
    
    @IBOutlet weak var btnEagerTranscoding: NSButton!
    @IBOutlet weak var btnPredictive: NSButton!
    @IBOutlet weak var btnAllFiles: NSButton!
    
    private let transcoder: TranscoderProtocol = ObjectGraph.transcoder
    
    private lazy var playbackProfiles: PlaybackProfiles = ObjectGraph.playbackDelegate.profiles
    
    override var nibName: String? {return "PlaybackPreferences"}
    
    func getView() -> NSView {
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
        
        // Show new track
        
        btnShowNewTrack.onIf(prefs.showNewTrackInPlaylist)
        
        // Remember last track position
        
        btnRememberPosition.onIf(prefs.rememberLastPosition)
        [btnRememberPosition_individualTracks, btnRememberPosition_allTracks].forEach({$0?.enableIf(btnRememberPosition.isOn())})
        
        if prefs.rememberLastPositionOption == .individualTracks {
            btnRememberPosition_individualTracks.on()
        } else {
            btnRememberPosition_allTracks.on()
        }
        
        // Gap between tracks
        
        btnGapBetweenTracks.onIf(prefs.gapBetweenTracks)
        [lblGapDuration, gapDurationPicker].forEach({$0?.enableIf(btnGapBetweenTracks.isOn())})
        gapDurationPicker.setInterval(Double(prefs.gapBetweenTracksDuration))
        gapDurationPickerAction(self)
        
        // Transcoded files persistence

        let transcodingPrefs = prefs.transcodingPreferences

        if transcodingPrefs.persistenceOption == .save {
            btnSaveFiles.on()
        } else {
            btnDeleteFiles.on()
        }
        transcoderPersistenceRadioButtonAction(self)
        
        btnLimitSpace.onIf(transcodingPrefs.limitDiskSpaceUsage)
        limitSpaceAction(self)

        let currentUsageMB: Double = Double(transcoder.currentDiskSpaceUsage) / (1000.0 * 1000)
        lblCurrentUsage.stringValue = formatSizeMB(currentUsageMB)
        let percUsed: Double = currentUsageMB * 100 / Double(transcodingPrefs.maxDiskSpaceUsage)
        
        if percUsed < 75 {
            lblCurrentUsage.textColor = NSColor.green
        } else if percUsed < 90 {
            lblCurrentUsage.textColor = NSColor.orange
        } else {
            lblCurrentUsage.textColor = NSColor.red
        }
        
        maxSpaceSlider.doubleValue = log10(Double(transcodingPrefs.maxDiskSpaceUsage)) - log10(100)
        maxSpaceSliderAction(self)
        
        btnEagerTranscoding.onIf(transcodingPrefs.eagerTranscodingEnabled)
        eagerTranscodingAction(self)
        
        if transcodingPrefs.eagerTranscodingOption == .allFiles {
            btnAllFiles.on()
        } else {
            btnPredictive.on()
        }
        
        tabView.selectTabViewItem(at: 0)
    }
    
    @IBAction func primarySeekLengthRadioButtonAction(_ sender: Any) {
        primarySeekLengthConstantFields.forEach({$0.enableIf(btnPrimarySeekLengthConstant.isOn())})
        primarySeekLengthPercStepper.enableIf(btnPrimarySeekLengthPerc.isOn())
    }
    
    @IBAction func secondarySeekLengthRadioButtonAction(_ sender: Any) {
        secondarySeekLengthConstantFields.forEach({$0.enableIf(btnSecondarySeekLengthConstant.isOn())})
        secondarySeekLengthPercStepper.enableIf(btnSecondarySeekLengthPerc.isOn())
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
        [btnAutoplayIfNotPlaying, btnAutoplayAlways].forEach({$0!.enableIf(btnAutoplayAfterAddingTracks.isOn())})
    }
    
    @IBAction func autoplayAfterAddingRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func rememberLastPositionAction(_ sender: Any) {
        [btnRememberPosition_individualTracks, btnRememberPosition_allTracks].forEach({$0?.enableIf(btnRememberPosition.isOn())})
    }
    
    @IBAction func rememberLastPositionRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func gapDurationAction(_ sender: NSButton) {
        [lblGapDuration, gapDurationPicker].forEach({$0?.enableIf(btnGapBetweenTracks.isOn())})
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
    
    @IBAction func transcoderPersistenceRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func limitSpaceAction(_ sender: Any) {
        maxSpaceSlider.enableIf(btnLimitSpace.isOn())
    }
    
    @IBAction func maxSpaceSliderAction(_ sender: Any) {
        lblMaxSpace.stringValue = formatSizeMB(round(100 * pow(10, maxSpaceSlider.doubleValue)))
    }
    
    private func formatSizeMB(_ size: Double) -> String {
        
        var amount: Double = size
        var unit = "MB"
        
        if amount >= 1000 && amount < 1000 * 1000 {
            
            // GB
            unit = "GB"
            amount = amount / 1000.0
            
        } else if amount >= 1000 * 1000 {
            
            // TB
            unit = "TB"
            amount = amount / (1000.0 * 1000.0)
        }
        
        let isWholeNumber = amount == round(amount)
        return isWholeNumber ? String(format: "%d  %@", Int(amount), unit) : (unit == "MB" ? String(format: "%d  %@", UInt(round(amount)), unit) : String(format: "%.2lf  %@", amount, unit))
    }
    
    @IBAction func eagerTranscodingAction(_ sender: Any) {
        [btnPredictive, btnAllFiles].forEach({$0?.enableIf(btnEagerTranscoding.isOn())})
    }
    
    @IBAction func eagerTranscodingOptionAction(_ sender: Any) {
        // Needed for radio buttons
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
        
        let prefs = preferences.playbackPreferences
        
        prefs.primarySeekLengthOption = btnPrimarySeekLengthConstant.isOn() ? .constant : .percentage
        prefs.primarySeekLengthConstant = Int(round(primarySeekLengthPicker.interval))
        prefs.primarySeekLengthPercentage = primarySeekLengthPercStepper.integerValue
        
        prefs.secondarySeekLengthOption = btnSecondarySeekLengthConstant.isOn() ? .constant : .percentage
        prefs.secondarySeekLengthConstant = Int(round(secondarySeekLengthPicker.interval))
        prefs.secondarySeekLengthPercentage = secondarySeekLengthPercStepper.integerValue
        
        prefs.autoplayOnStartup = btnAutoplayOnStartup.isOn()
        
        prefs.autoplayAfterAddingTracks = btnAutoplayAfterAddingTracks.isOn()
        prefs.autoplayAfterAddingOption = btnAutoplayIfNotPlaying.isOn() ? .ifNotPlaying : .always
     
        prefs.showNewTrackInPlaylist = btnShowNewTrack.isOn()
        
        prefs.rememberLastPosition = btnRememberPosition.isOn()
        
        let wasAllTracks: Bool = prefs.rememberLastPositionOption == .allTracks
        
        prefs.rememberLastPositionOption = btnRememberPosition_individualTracks.isOn() ? .individualTracks : .allTracks
        
        let isNowIndividualTracks: Bool = prefs.rememberLastPositionOption == .individualTracks
        
        if !prefs.rememberLastPosition || (wasAllTracks && isNowIndividualTracks) {
            playbackProfiles.removeAll()
        }
        
        prefs.gapBetweenTracks = btnGapBetweenTracks.isOn()
        prefs.gapBetweenTracksDuration = Int(round(gapDurationPicker.interval))
        
        prefs.transcodingPreferences.persistenceOption = btnSaveFiles.isOn() ? .save : .delete
        prefs.transcodingPreferences.limitDiskSpaceUsage = btnLimitSpace.isOn()
        
        let amount: Double = 100 * pow(10, maxSpaceSlider.doubleValue)
        prefs.transcodingPreferences.maxDiskSpaceUsage = Int(round(amount))
        
        prefs.transcodingPreferences.eagerTranscodingEnabled = btnEagerTranscoding.isOn()
        prefs.transcodingPreferences.eagerTranscodingOption = btnAllFiles.isOn() ? .allFiles : .predictive
        
        // Max usage prefs may have changed, so perform a check if user has opted to limit disk space usage
        if prefs.transcodingPreferences.limitDiskSpaceUsage {
            transcoder.checkDiskSpaceUsage()
        }
    }
}

fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}

fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
