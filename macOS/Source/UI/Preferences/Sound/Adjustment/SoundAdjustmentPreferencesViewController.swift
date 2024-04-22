//
//  SoundAdjustmentPreferencesViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class SoundAdjustmentPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
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
    
    override var nibName: String? {"SoundAdjustmentPreferences"}
    
    var preferencesView: NSView {
        return self.view
    }
    
    func resetFields() {
        
        let soundPrefs = preferences.soundPreferences
        
        // Volume increment / decrement
        
        let volumeDelta = (soundPrefs.volumeDelta * ValueConversions.volume_audioGraphToUI).roundedInt
        volumeDeltaStepper.integerValue = volumeDelta
        volumeDeltaField.stringValue = String(format: "%d%%", volumeDelta)
        
        // Pan increment / decrement
        
        let panDelta = (soundPrefs.panDelta * ValueConversions.pan_audioGraphToUI).roundedInt
        panDeltaStepper.integerValue = panDelta
        panDeltaAction(self)
        
        let eqDelta = soundPrefs.eqDelta
        eqDeltaStepper.floatValue = eqDelta
        eqDeltaAction(self)
        
        let pitchDelta = soundPrefs.pitchDelta
        pitchDeltaStepper.integerValue = pitchDelta
        pitchDeltaAction(self)
        
        let timeDelta = soundPrefs.timeDelta
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

        soundPrefs.volumeDelta = volumeDeltaStepper.floatValue * ValueConversions.volume_UIToAudioGraph
//        soundPrefs.panDelta = panDeltaStepper.floatValue * ValueConversions.pan_UIToAudioGraph
//
//        soundPrefs.eqDelta = eqDeltaStepper.floatValue
//        soundPrefs.pitchDelta = pitchDeltaStepper.integerValue
        soundPrefs.timeDelta = timeDeltaStepper.floatValue
    }
}
