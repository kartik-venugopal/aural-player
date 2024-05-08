//
//  PlaybackPreferencesViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class PlaybackPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var btnPrimarySeekLengthConstant: NSButton!
    @IBOutlet weak var btnPrimarySeekLengthPerc: NSButton!
    
    @IBOutlet weak var primarySeekLengthPicker: NSStepper!
    @IBOutlet weak var lblPrimarySeekLength: FormattedIntervalLabel!
    
    @IBOutlet weak var primarySeekLengthPercStepper: NSStepper!
    @IBOutlet weak var lblPrimarySeekLengthPerc: NSTextField!
    
    private var primarySeekLengthConstantFields: [NSControl] = []
    
    @IBOutlet weak var btnSecondarySeekLengthConstant: NSButton!
    @IBOutlet weak var btnSecondarySeekLengthPerc: NSButton!
    
    @IBOutlet weak var secondarySeekLengthPicker: NSStepper!
    @IBOutlet weak var lblSecondarySeekLength: FormattedIntervalLabel!
    
    @IBOutlet weak var secondarySeekLengthPercStepper: NSStepper!
    @IBOutlet weak var lblSecondarySeekLengthPerc: NSTextField!
    
    private var secondarySeekLengthConstantFields: [NSControl] = []
    
    @IBOutlet weak var btnAutoplayOnStartup: NSButton!
    
    @IBOutlet weak var btnAutoplayAfterAddingTracks: NSButton!
    @IBOutlet weak var btnAutoplayAfterAdding_IfNotPlaying: NSButton!
    @IBOutlet weak var btnAutoplayAfterAdding_Always: NSButton!
    
    @IBOutlet weak var btnAutoplayAfterOpeningTracks: NSButton!
    @IBOutlet weak var btnAutoplayAfterOpening_IfNotPlaying: NSButton!
    @IBOutlet weak var btnAutoplayAfterOpening_Always: NSButton!
    
    @IBOutlet weak var btnRememberPositionForAllTracks: CheckBox!
    
    @IBOutlet weak var btnInfo_primarySeekLength: ContextHelpButton!
    @IBOutlet weak var btnInfo_secondarySeekLength: ContextHelpButton!
    
    private lazy var playbackProfiles: PlaybackProfiles = playbackDelegate.profiles
    
    override var nibName: String? {"PlaybackPreferences"}
    
    var preferencesView: NSView {
        view
    }
    
    override func viewDidLoad() {
        
        primarySeekLengthConstantFields = [primarySeekLengthPicker]
        secondarySeekLengthConstantFields = [secondarySeekLengthPicker]
    }
    
    func resetFields() {
        
        let prefs = preferences.playbackPreferences
        
        // Primary seek length
        
        primarySeekLengthPicker.integerValue = prefs.primarySeekLengthConstant.value
        primarySeekLengthAction(self)
        
        let primarySeekLengthPerc = prefs.primarySeekLengthPercentage.value
        primarySeekLengthPercStepper.integerValue = primarySeekLengthPerc
        lblPrimarySeekLengthPerc.stringValue = String(format: "%d%%", primarySeekLengthPerc)
        
        if prefs.primarySeekLengthOption.value == .constant {
            btnPrimarySeekLengthConstant.on()
        } else {
            btnPrimarySeekLengthPerc.on()
        }
        
        primarySeekLengthConstantFields.forEach {$0.enableIf(prefs.primarySeekLengthOption.value == .constant)}
        primarySeekLengthPercStepper.enableIf(prefs.primarySeekLengthOption.value == .percentage)
        
        // Secondary seek length
        
        secondarySeekLengthPicker.integerValue = prefs.secondarySeekLengthConstant.value
        secondarySeekLengthAction(self)
        
        let secondarySeekLengthPerc = prefs.secondarySeekLengthPercentage.value
        secondarySeekLengthPercStepper.integerValue = secondarySeekLengthPerc
        lblSecondarySeekLengthPerc.stringValue = String(format: "%d%%", secondarySeekLengthPerc)
        
        if prefs.secondarySeekLengthOption.value == .constant {
            btnSecondarySeekLengthConstant.on()
        } else {
            btnSecondarySeekLengthPerc.on()
        }
        
        secondarySeekLengthConstantFields.forEach {$0.enableIf(prefs.secondarySeekLengthOption.value == .constant)}
        secondarySeekLengthPercStepper.enableIf(prefs.secondarySeekLengthOption.value == .percentage)
        
        // Autoplay
        
        btnAutoplayOnStartup.onIf(prefs.autoplayOnStartup.value)
        
        btnAutoplayAfterAddingTracks.onIf(prefs.autoplayAfterAddingTracks.value)
        btnAutoplayAfterAdding_IfNotPlaying.onIf(prefs.autoplayAfterAddingOption.value == .ifNotPlaying)
        btnAutoplayAfterAdding_Always.onIf(prefs.autoplayAfterAddingOption.value == .always)
        
        btnAutoplayAfterOpeningTracks.onIf(prefs.autoplayAfterOpeningTracks.value)
        btnAutoplayAfterOpening_Always.onIf(prefs.autoplayAfterOpeningOption.value == .always)
        btnAutoplayAfterOpening_IfNotPlaying.onIf(prefs.autoplayAfterOpeningOption.value == .ifNotPlaying)
        
        // Remember last track position
        btnRememberPositionForAllTracks.onIf(prefs.rememberLastPositionForAllTracks.value)
    }
    
    @IBAction func primarySeekLengthRadioButtonAction(_ sender: Any) {
        
        primarySeekLengthConstantFields.forEach {$0.enableIf(btnPrimarySeekLengthConstant.isOn)}
        primarySeekLengthPercStepper.enableIf(btnPrimarySeekLengthPerc.isOn)
    }
    
    @IBAction func secondarySeekLengthRadioButtonAction(_ sender: Any) {
        
        secondarySeekLengthConstantFields.forEach {$0.enableIf(btnSecondarySeekLengthConstant.isOn)}
        secondarySeekLengthPercStepper.enableIf(btnSecondarySeekLengthPerc.isOn)
    }
    
    @IBAction func primarySeekLengthAction(_ sender: Any) {
        lblPrimarySeekLength.interval = primarySeekLengthPicker.doubleValue
    }
    
    @IBAction func secondarySeekLengthAction(_ sender: Any) {
        lblSecondarySeekLength.interval = secondarySeekLengthPicker.doubleValue
    }
    
    @IBAction func primarySeekLengthPercAction(_ sender: Any) {
        lblPrimarySeekLengthPerc.stringValue = String(format: "%d%%", primarySeekLengthPercStepper.integerValue)
    }
    
    @IBAction func secondarySeekLengthPercAction(_ sender: Any) {
        lblSecondarySeekLengthPerc.stringValue = String(format: "%d%%", secondarySeekLengthPercStepper.integerValue)
    }
    
    // When the check box for "autoplay after adding tracks" is checked/unchecked, update the enabled state of the 2 option radio buttons
    @IBAction func autoplayAfterAddingAction(_ sender: Any) {
    }
    
    // When the check box for "autoplay after opening tracks" is checked/unchecked, update the enabled state of the 2 option radio buttons
    @IBAction func autoplayAfterOpeningAction(_ sender: Any) {
    }
    
    @IBAction func autoplayAfterAddingRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func autoplayAfterOpeningRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func rememberLastPositionRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func seekLengthPrimary_infoAction(_ sender: Any) {
        btnInfo_primarySeekLength.showContextHelp(self)
    }
    
    @IBAction func seekLengthSecondary_infoAction(_ sender: Any) {
        btnInfo_secondarySeekLength.showContextHelp(self)
    }
    
    func save() throws {
        
        let prefs = preferences.playbackPreferences
        
        let oldPrimarySeekLengthConstant = prefs.primarySeekLengthConstant.value
        
        prefs.primarySeekLengthOption.value = btnPrimarySeekLengthConstant.isOn ? .constant : .percentage
        prefs.primarySeekLengthConstant.value = primarySeekLengthPicker.doubleValue.roundedInt
        prefs.primarySeekLengthPercentage.value = primarySeekLengthPercStepper.integerValue

        prefs.secondarySeekLengthOption.value = btnSecondarySeekLengthConstant.isOn ? .constant : .percentage
        prefs.secondarySeekLengthConstant.value = secondarySeekLengthPicker.doubleValue.roundedInt
        prefs.secondarySeekLengthPercentage.value = secondarySeekLengthPercStepper.integerValue

        prefs.autoplayOnStartup.value = btnAutoplayOnStartup.isOn
        
        prefs.autoplayAfterAddingTracks.value = btnAutoplayAfterAddingTracks.isOn
        prefs.autoplayAfterAddingOption.value = btnAutoplayAfterAdding_IfNotPlaying.isOn ? .ifNotPlaying : .always
        
        prefs.autoplayAfterOpeningTracks.value = btnAutoplayAfterOpeningTracks.isOn
        prefs.autoplayAfterOpeningOption.value = btnAutoplayAfterOpening_IfNotPlaying.isOn ? .ifNotPlaying : .always
        
        // Playback profiles
        
        let wasAllTracks: Bool = prefs.rememberLastPositionForAllTracks.value
        prefs.rememberLastPositionForAllTracks.value = btnRememberPositionForAllTracks.isOn
        let isNowIndividualTracks: Bool = !prefs.rememberLastPositionForAllTracks.value
        
        if wasAllTracks && isNowIndividualTracks {
            playbackProfiles.removeAll()
        }

        // Remote Control (seek interval)
        
        // If the (primary) seek interval has changed, update Remote Control with the new interval.
        if oldPrimarySeekLengthConstant != prefs.primarySeekLengthConstant.value {
            remoteControlManager.updateSeekInterval(to: Double(prefs.primarySeekLengthConstant.value))
        }
    }
}

@IBDesignable
class FormattedIntervalLabel: NSTextField {
    
    @IBInspectable var interval: Double = 0 {
        
        didSet {
            self.stringValue = interval != 0 ? ValueFormatter.formatSecondsToHMS_hrMinSec(interval.roundedInt) : "0 sec"
        }
    }
    
    override func awakeFromNib() {
        
        self.alignment = .right
        self.font = standardFontSet.mainFont(size: 11)
        self.isBordered = false
        self.drawsBackground = false
        self.textColor = .defaultLightTextColor
    }
}
