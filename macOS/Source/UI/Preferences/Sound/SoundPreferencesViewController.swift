//
//  SoundPreferencesViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Cocoa

class SoundPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    override var nibName: String? {"SoundPreferences"}
    
    var preferencesView: NSView {self.view}
    
    @IBOutlet weak var btnRememberSettingsforAllTracks: CheckBox!
    
    @IBOutlet weak var volumeDeltaField: NSTextField!
    @IBOutlet weak var volumeDeltaStepper: NSStepper!
    
    @IBOutlet weak var lblPanDelta: NSTextField!
    @IBOutlet weak var panDeltaStepper: NSStepper!
    
    @IBOutlet weak var lblEQDelta: NSTextField!
    @IBOutlet weak var eqDeltaStepper: NSStepper!
    
    @IBOutlet weak var lblPitchDelta: NSTextField!
    @IBOutlet weak var pitchDeltaStepper: NSStepper!
    
    @IBOutlet weak var lblTimeDelta: NSTextField!
    @IBOutlet weak var timeDeltaStepper: NSStepper!
    
    func resetFields() {
        
        let soundPrefs = preferences.soundPreferences
        
        // Per-track effects settings memory
        btnRememberSettingsforAllTracks.onIf(soundPrefs.rememberEffectsSettingsForAllTracks.value)
        
        // Volume increment / decrement
        
        let volumeDelta = (soundPrefs.volumeDelta.value * ValueConversions.volume_audioGraphToUI).roundedInt
        volumeDeltaStepper.integerValue = volumeDelta
        volumeDeltaField.stringValue = String(format: "%d%%", volumeDelta)
        
        // Pan increment / decrement
        
        let panDelta = (soundPrefs.panDelta.value * ValueConversions.pan_audioGraphToUI).roundedInt
        panDeltaStepper.integerValue = panDelta
        panDeltaAction(self)
        
        let eqDelta = soundPrefs.eqDelta.value
        eqDeltaStepper.floatValue = eqDelta
        eqDeltaAction(self)
        
        let pitchDelta = soundPrefs.pitchDelta.value
        pitchDeltaStepper.integerValue = pitchDelta
        pitchDeltaAction(self)
        
        let timeDelta = soundPrefs.rateDelta.value
        timeDeltaStepper.floatValue = timeDelta
        timeDeltaAction(self)
    }
    
    @IBAction func volumeDeltaAction(_ sender: Any) {
        volumeDeltaField.stringValue = String(format: "%d%%", volumeDeltaStepper.integerValue)
    }
    
    @IBAction func panDeltaAction(_ sender: Any) {
        lblPanDelta.stringValue = String(format: "%d%%", panDeltaStepper.integerValue)
    }
    
    @IBAction func eqDeltaAction(_ sender: Any) {
        lblEQDelta.stringValue = String(format: "%.1lf dB", eqDeltaStepper.floatValue)
    }
    
    @IBAction func pitchDeltaAction(_ sender: Any) {
        lblPitchDelta.stringValue = String(format: "%d cents", pitchDeltaStepper.integerValue)
    }
    
    @IBAction func timeDeltaAction(_ sender: Any) {
        lblTimeDelta.stringValue = String(format: "%.2lfx", timeDeltaStepper.floatValue)
    }
    
    func save() throws {
        
        let soundPrefs = preferences.soundPreferences
        
        soundPrefs.volumeDelta.value = volumeDeltaStepper.floatValue * ValueConversions.volume_UIToAudioGraph
        soundPrefs.panDelta.value = panDeltaStepper.floatValue * ValueConversions.pan_UIToAudioGraph
        
        soundPrefs.eqDelta.value = eqDeltaStepper.floatValue
        soundPrefs.pitchDelta.value = pitchDeltaStepper.integerValue
        soundPrefs.rateDelta.value = timeDeltaStepper.floatValue

        let wasAllTracks: Bool = soundPrefs.rememberEffectsSettingsForAllTracks.value
        soundPrefs.rememberEffectsSettingsForAllTracks.value = btnRememberSettingsforAllTracks.isOn
        let isNowIndividualTracks: Bool = soundPrefs.rememberEffectsSettingsForAllTracks.value
        
        if wasAllTracks && isNowIndividualTracks {
            audioGraphDelegate.soundProfiles.removeAll()
        }
    }
}
