//
// AutoplayPreferencesViewController.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

class AutoplayPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
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
        
        let prefs = preferences.playbackPreferences.autoplay
        
        btnAutoplayOnStartup.onIf(prefs.autoplayOnStartup)
        [btnAutoplayOnStartup_FirstTrack, btnAutoplayOnStartup_ResumeSequence].forEach {$0?.enableIf(btnAutoplayOnStartup.isOn)}
        btnAutoplayOnStartup_FirstTrack.onIf(prefs.autoplayOnStartupOption == .firstTrack)
        btnAutoplayOnStartup_ResumeSequence.onIf(prefs.autoplayOnStartupOption == .resumeSequence)
        
        btnAutoplayAfterAddingTracks.onIf(prefs.autoplayAfterAddingTracks)
        [btnAutoplayAfterAdding_IfNotPlaying, btnAutoplayAfterAdding_Always].forEach {$0?.enableIf(btnAutoplayAfterAddingTracks.isOn)}
        btnAutoplayAfterAdding_IfNotPlaying.onIf(prefs.autoplayAfterAddingOption == .ifNotPlaying)
        btnAutoplayAfterAdding_Always.onIf(prefs.autoplayAfterAddingOption == .always)
        
        btnAutoplayAfterOpeningTracks.onIf(prefs.autoplayAfterOpeningTracks)
        [btnAutoplayAfterOpening_IfNotPlaying, btnAutoplayAfterOpening_Always].forEach {$0?.enableIf(btnAutoplayAfterOpeningTracks.isOn)}
        btnAutoplayAfterOpening_Always.onIf(prefs.autoplayAfterOpeningOption == .always)
        btnAutoplayAfterOpening_IfNotPlaying.onIf(prefs.autoplayAfterOpeningOption == .ifNotPlaying)
    }
    
    @IBAction func autoplayOnStartupCheckBoxAction(_ sender: CheckBox) {
        [btnAutoplayOnStartup_FirstTrack, btnAutoplayOnStartup_ResumeSequence].forEach {$0?.enableIf(btnAutoplayOnStartup.isOn)}
    }
    
    @IBAction func autoplayAfterAddingCheckBoxAction(_ sender: CheckBox) {
        [btnAutoplayAfterAdding_IfNotPlaying, btnAutoplayAfterAdding_Always].forEach {$0?.enableIf(btnAutoplayAfterAddingTracks.isOn)}
    }
    
    @IBAction func autoplayAfterOpeningCheckBoxAction(_ sender: CheckBox) {
        [btnAutoplayAfterOpening_IfNotPlaying, btnAutoplayAfterOpening_Always].forEach {$0?.enableIf(btnAutoplayAfterOpeningTracks.isOn)}
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
        
        let prefs = preferences.playbackPreferences.autoplay
        
        prefs.autoplayOnStartup = btnAutoplayOnStartup.isOn
        prefs.autoplayOnStartupOption = btnAutoplayOnStartup_FirstTrack.isOn ? .firstTrack : .resumeSequence
        
        prefs.autoplayAfterAddingTracks = btnAutoplayAfterAddingTracks.isOn
        prefs.autoplayAfterAddingOption = btnAutoplayAfterAdding_IfNotPlaying.isOn ? .ifNotPlaying : .always
        
        prefs.autoplayAfterOpeningTracks = btnAutoplayAfterOpeningTracks.isOn
        prefs.autoplayAfterOpeningOption = btnAutoplayAfterOpening_IfNotPlaying.isOn ? .ifNotPlaying : .always
    }
}
