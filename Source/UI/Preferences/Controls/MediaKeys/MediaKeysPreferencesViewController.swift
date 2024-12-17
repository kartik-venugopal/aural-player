//
//  MediaKeysPreferencesViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class MediaKeysPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    // Media keys response
    @IBOutlet weak var btnRespondToMediaKeys: CheckBox!
    
    // SKip key behavior
    @IBOutlet weak var btnHybrid: RadioButton!
    @IBOutlet weak var btnTrackChangesOnly: RadioButton!
    @IBOutlet weak var btnSeekingOnly: RadioButton!
    
    @IBOutlet weak var repeatSpeedMenu: NSPopUpButton!
    
    override var nibName: NSNib.Name? {"MediaKeysPreferences"}
    
    var preferencesView: NSView {
        view
    }
    
    func resetFields() {
        
        let controlsPrefs = preferences.controlsPreferences.mediaKeys
        
        btnRespondToMediaKeys.onIf(controlsPrefs.enabled.value)
        mediaKeyResponseAction(self)
        
        [btnHybrid, btnTrackChangesOnly, btnSeekingOnly].forEach {$0?.off()}
        
        switch controlsPrefs.skipKeyBehavior.value {
            
        case .hybrid:   btnHybrid.on()
            
        case .trackChangesOnly:     btnTrackChangesOnly.on()
            
        case .seekingOnly:          btnSeekingOnly.on()
            
        }
        
        repeatSpeedMenu.selectItem(withTitle: controlsPrefs.skipKeyRepeatSpeed.value.rawValue.capitalized)
    }
    
    @IBAction func mediaKeyResponseAction(_ sender: Any) {
        [btnHybrid, btnTrackChangesOnly, btnSeekingOnly, repeatSpeedMenu].forEach {$0?.enableIf(btnRespondToMediaKeys.isOn)}
    }
    
    @IBAction func skipKeyBehaviorAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    func save() throws {
        
        let controlsPrefs = preferences.controlsPreferences
        
        controlsPrefs.mediaKeys.enabled.value = btnRespondToMediaKeys.isOn
        
        if btnHybrid.isOn {
            controlsPrefs.mediaKeys.skipKeyBehavior.value = .hybrid
            
        } else if btnTrackChangesOnly.isOn {
            controlsPrefs.mediaKeys.skipKeyBehavior.value = .trackChangesOnly
            
        } else {
            controlsPrefs.mediaKeys.skipKeyBehavior.value = .seekingOnly
        }
        
        controlsPrefs.mediaKeys.skipKeyRepeatSpeed.value = MediaKeysControlsPreferences.SkipKeyRepeatSpeed(rawValue: repeatSpeedMenu.titleOfSelectedItem!.lowercased()) ?? PreferencesDefaults.Controls.MediaKeys.skipKeyRepeatSpeed
        controlsPrefs.mediaKeys.enabled.value ? mediaKeyHandler.startMonitoring() : mediaKeyHandler.stopMonitoring()
    }
}
