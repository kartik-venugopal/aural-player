//
//  MediaKeysPreferencesViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
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
        
        btnRespondToMediaKeys.onIf(controlsPrefs.enabled)
        mediaKeyResponseAction(self)
        
        [btnHybrid, btnTrackChangesOnly, btnSeekingOnly].forEach {$0?.off()}
        
        switch controlsPrefs.skipKeyBehavior {
            
        case .hybrid:   btnHybrid.on()
            
        case .trackChangesOnly:     btnTrackChangesOnly.on()
            
        case .seekingOnly:          btnSeekingOnly.on()
            
        }
        
        repeatSpeedMenu.selectItem(withTitle: controlsPrefs.skipKeyRepeatSpeed.rawValue.capitalized)
    }
    
    @IBAction func mediaKeyResponseAction(_ sender: Any) {
        [btnHybrid, btnTrackChangesOnly, btnSeekingOnly, repeatSpeedMenu].forEach {$0?.enableIf(btnRespondToMediaKeys.isOn)}
    }
    
    @IBAction func skipKeyBehaviorAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    func save() throws {
        
        let controlsPrefs = preferences.controlsPreferences
        
        controlsPrefs.mediaKeys.enabled = btnRespondToMediaKeys.isOn
        
        if btnHybrid.isOn {
            controlsPrefs.mediaKeys.skipKeyBehavior = .hybrid
            
        } else if btnTrackChangesOnly.isOn {
            controlsPrefs.mediaKeys.skipKeyBehavior = .trackChangesOnly
            
        } else {
            controlsPrefs.mediaKeys.skipKeyBehavior = .seekingOnly
        }
        
        if let repeatSpeed = repeatSpeedMenu.enumValueForTitle(ofType: MediaKeysControlsPreferences.SkipKeyRepeatSpeed.self) {
            controlsPrefs.mediaKeys.skipKeyRepeatSpeed = repeatSpeed
        }
        
        controlsPrefs.mediaKeys.enabled ? mediaKeyHandler.startMonitoring() : mediaKeyHandler.stopMonitoring()
    }
}
