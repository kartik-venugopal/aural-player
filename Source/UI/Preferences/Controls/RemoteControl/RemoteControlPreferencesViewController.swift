//
//  RemoteControlPreferencesViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class RemoteControlPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    override var nibName: NSNib.Name? {"RemoteControlPreferences"}
    
    @IBOutlet weak var btnEnableRemoteControl: CheckBox!
    
    @IBOutlet weak var btnShowTrackChangeControls: RadioButton!
    @IBOutlet weak var btnShowSeekingControls: RadioButton!
    
    var preferencesView: NSView {
        view
    }
    
    func resetFields() {
        
        let controlsPrefs = preferences.controlsPreferences.remoteControl
        
        btnEnableRemoteControl.onIf(controlsPrefs.enabled.value)
        enableRemoteControlAction(self)
        
        let trackChangeOrSeekingOption = controlsPrefs.trackChangeOrSeekingOption.value
        btnShowTrackChangeControls.onIf(trackChangeOrSeekingOption == .trackChange)
        btnShowSeekingControls.onIf(trackChangeOrSeekingOption == .seeking)
    }
    
    @IBAction func enableRemoteControlAction(_ sender: Any) {
        
        [btnShowTrackChangeControls, btnShowSeekingControls].forEach {
            $0?.enableIf(btnEnableRemoteControl.isOn)
        }
    }
    
    @IBAction func trackChangeOrSeekingOptionsAction(_ sender: Any) {
        // Needed for radio button group.
    }
    
    func save() throws {
        
        let controlsPrefs = preferences.controlsPreferences.remoteControl
        
        let wasEnabled: Bool = controlsPrefs.enabled.value
        let oldTrackChangeOrSeekingOption = controlsPrefs.trackChangeOrSeekingOption.value
        
        controlsPrefs.enabled.value = btnEnableRemoteControl.isOn
        controlsPrefs.trackChangeOrSeekingOption.value = btnShowTrackChangeControls.isOn ? .trackChange : .seeking
        
        // Don't do anything unless at least one preference was changed.
        
        let prefsHaveChanged = (wasEnabled != controlsPrefs.enabled.value) || (oldTrackChangeOrSeekingOption != controlsPrefs.trackChangeOrSeekingOption.value)
        
        if prefsHaveChanged {
            remoteControlManager.preferencesUpdated()
        }
    }
}
