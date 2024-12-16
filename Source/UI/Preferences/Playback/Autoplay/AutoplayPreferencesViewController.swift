//
// AutoplayPreferencesViewController.swift
// Aural
// 
// Copyright © 2024 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

class AutoplayPreferencesViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"AutoplayPreferences"}
    
    @IBOutlet weak var btnAutoplayOnStartup: CheckBox!
    @IBOutlet weak var btnAutoplayOnStartup_FirstTrack: RadioButton!
    @IBOutlet weak var btnAutoplayOnStartup_ResumeSequence: RadioButton!
    
    @IBOutlet weak var btnAutoplayAfterAddingTracks: CheckBox!
    @IBOutlet weak var btnAutoplayAfterAdding_IfNotPlaying: RadioButton!
    @IBOutlet weak var btnAutoplayAfterAdding_Always: RadioButton!
    
    @IBOutlet weak var btnAutoplayAfterOpeningTracks: CheckBox!
    @IBOutlet weak var btnAutoplayAfterOpening_IfNotPlaying: RadioButton!
    @IBOutlet weak var btnAutoplayAfterOpening_Always: RadioButton!
    
    var preferencesView: NSView {
        view
    }
    
    func resetFields() {
        
        let prefs = preferences.playbackPreferences
        
        btnAutoplayOnStartup.onIf(prefs.autoplayOnStartup.value)
        
        btnAutoplayAfterAddingTracks.onIf(prefs.autoplayAfterAddingTracks.value)
        btnAutoplayAfterAdding_IfNotPlaying.onIf(prefs.autoplayAfterAddingOption.value == .ifNotPlaying)
        btnAutoplayAfterAdding_Always.onIf(prefs.autoplayAfterAddingOption.value == .always)
        
        btnAutoplayAfterOpeningTracks.onIf(prefs.autoplayAfterOpeningTracks.value)
        btnAutoplayAfterOpening_Always.onIf(prefs.autoplayAfterOpeningOption.value == .always)
        btnAutoplayAfterOpening_IfNotPlaying.onIf(prefs.autoplayAfterOpeningOption.value == .ifNotPlaying)
    }
    
    @IBAction func autoplayOnStartupRadioButtonAction(_ sender: RadioButton) {
        // Needed for radio button group
    }
    
    @IBAction func autoplayAfterAddingRadioButtonAction(_ sender: RadioButton) {
        // Needed for radio button group
    }
    
    @IBAction func autoplayAfterOpeningRadioButtonAction(_ sender: RadioButton) {
        // Needed for radio button group
    }
    
    func save() throws {
        
        let prefs = preferences.playbackPreferences
        
        prefs.autoplayOnStartup.value = btnAutoplayOnStartup.isOn
        prefs.autoplayOnStartupOption.value = btnAutoplayOnStartup_FirstTrack.isOn ? .firstTrack : .resumeSequence
        
        prefs.autoplayAfterAddingTracks.value = btnAutoplayAfterAddingTracks.isOn
        prefs.autoplayAfterAddingOption.value = btnAutoplayAfterAdding_IfNotPlaying.isOn ? .ifNotPlaying : .always
        
        prefs.autoplayAfterOpeningTracks.value = btnAutoplayAfterOpeningTracks.isOn
        prefs.autoplayAfterOpeningOption.value = btnAutoplayAfterOpening_IfNotPlaying.isOn ? .ifNotPlaying : .always
    }
}
