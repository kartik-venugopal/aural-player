//
// GeneralPlaybackPreferencesViewController.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

class GeneralPlaybackPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    override var nibName: NSNib.Name? {"GeneralPlaybackPreferences"}
    
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
    
    @IBOutlet weak var btnRememberPositionForAllTracks: CheckBox!
    
    @IBOutlet weak var btnInfo_primarySeekLength: ContextHelpButton!
    @IBOutlet weak var btnInfo_secondarySeekLength: ContextHelpButton!
    
    private lazy var playbackProfiles: PlaybackProfiles = playbackDelegate.profiles
    
    var preferencesView: NSView {
        view
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        primarySeekLengthConstantFields = [primarySeekLengthPicker]
        secondarySeekLengthConstantFields = [secondarySeekLengthPicker]
    }
    
    func resetFields() {
        
        let prefs = preferences.playbackPreferences
        
        // Primary seek length
        
        primarySeekLengthPicker.integerValue = prefs.primarySeekLengthConstant
        primarySeekLengthAction(self)
        
        let primarySeekLengthPerc = prefs.primarySeekLengthPercentage
        primarySeekLengthPercStepper.integerValue = primarySeekLengthPerc
        lblPrimarySeekLengthPerc.stringValue = String(format: "%d%%", primarySeekLengthPerc)
        
        if prefs.primarySeekLengthOption == .constant {
            btnPrimarySeekLengthConstant.on()
        } else {
            btnPrimarySeekLengthPerc.on()
        }
        
        primarySeekLengthConstantFields.forEach {$0.enableIf(prefs.primarySeekLengthOption == .constant)}
        primarySeekLengthPercStepper.enableIf(prefs.primarySeekLengthOption == .percentage)
        
        // Secondary seek length
        
        secondarySeekLengthPicker.integerValue = prefs.secondarySeekLengthConstant
        secondarySeekLengthAction(self)
        
        let secondarySeekLengthPerc = prefs.secondarySeekLengthPercentage
        secondarySeekLengthPercStepper.integerValue = secondarySeekLengthPerc
        lblSecondarySeekLengthPerc.stringValue = String(format: "%d%%", secondarySeekLengthPerc)
        
        if prefs.secondarySeekLengthOption == .constant {
            btnSecondarySeekLengthConstant.on()
        } else {
            btnSecondarySeekLengthPerc.on()
        }
        
        secondarySeekLengthConstantFields.forEach {$0.enableIf(prefs.secondarySeekLengthOption == .constant)}
        secondarySeekLengthPercStepper.enableIf(prefs.secondarySeekLengthOption == .percentage)
        
        // Remember last track position
        btnRememberPositionForAllTracks.onIf(prefs.rememberLastPositionForAllTracks)
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
    
    @IBAction func seekLengthPrimary_infoAction(_ sender: Any) {
        btnInfo_primarySeekLength.showContextHelp(self)
    }
    
    @IBAction func seekLengthSecondary_infoAction(_ sender: Any) {
        btnInfo_secondarySeekLength.showContextHelp(self)
    }
    
    func save() throws {
        
        let prefs = preferences.playbackPreferences
        
        let oldPrimarySeekLengthConstant = prefs.primarySeekLengthConstant
        
        prefs.primarySeekLengthOption = btnPrimarySeekLengthConstant.isOn ? .constant : .percentage
        prefs.primarySeekLengthConstant = primarySeekLengthPicker.doubleValue.roundedInt
        prefs.primarySeekLengthPercentage = primarySeekLengthPercStepper.integerValue

        prefs.secondarySeekLengthOption = btnSecondarySeekLengthConstant.isOn ? .constant : .percentage
        prefs.secondarySeekLengthConstant = secondarySeekLengthPicker.doubleValue.roundedInt
        prefs.secondarySeekLengthPercentage = secondarySeekLengthPercStepper.integerValue

        // Playback profiles
        
        let wasAllTracks: Bool = prefs.rememberLastPositionForAllTracks
        prefs.rememberLastPositionForAllTracks = btnRememberPositionForAllTracks.isOn
        let isNowIndividualTracks: Bool = btnRememberPositionForAllTracks.isOff
        
        if wasAllTracks && isNowIndividualTracks {
            playbackProfiles.removeAll()
        }

        // Remote Control (seek interval)
        
        // If the (primary) seek interval has changed, update Remote Control with the new interval.
        if oldPrimarySeekLengthConstant != prefs.primarySeekLengthConstant {
            remoteControlManager.updateSeekInterval(to: Double(prefs.primarySeekLengthConstant))
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
