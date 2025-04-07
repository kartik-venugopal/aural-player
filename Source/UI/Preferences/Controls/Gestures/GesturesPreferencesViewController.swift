//
//  GesturesPreferencesViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class GesturesPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    // Gestures
    @IBOutlet weak var btnAllowVolumeControl: CheckBox!
    @IBOutlet weak var btnAllowSeeking: CheckBox!
    @IBOutlet weak var btnAllowTrackChange: CheckBox!
    
    @IBOutlet weak var btnAllowPlayQueueScrollingTopToBottom: CheckBox!
    @IBOutlet weak var btnAllowPlayQueueScrollingPageUpDown: CheckBox!
    
    private var gestureButtons: [NSButton] = []
    
    // Sensitivity
    @IBOutlet weak var volumeControlSensitivityMenu: NSPopUpButton!
    @IBOutlet weak var seekSensitivityMenu: NSPopUpButton!
    
    override var nibName: NSNib.Name? {"GesturesPreferences"}
    
    override func viewDidLoad() {
        
        gestureButtons = [btnAllowVolumeControl, btnAllowSeeking, btnAllowTrackChange, btnAllowPlayQueueScrollingTopToBottom, btnAllowPlayQueueScrollingPageUpDown]
    }
    
    var preferencesView: NSView {
        view
    }
    
    func resetFields() {
        
        let controlsPrefs = preferences.controlsPreferences.gestures
        
        btnAllowVolumeControl.onIf(controlsPrefs.allowVolumeControl)
        volumeControlSensitivityMenu.enableIf(btnAllowVolumeControl.isOn)
        volumeControlSensitivityMenu.selectItem(withTitle: controlsPrefs.volumeControlSensitivity.rawValue.capitalized)
        
        btnAllowSeeking.onIf(controlsPrefs.allowSeeking)
        seekSensitivityMenu.enableIf(btnAllowSeeking.isOn)
        seekSensitivityMenu.selectItem(withTitle: controlsPrefs.seekSensitivity.rawValue.capitalized)
        
        btnAllowTrackChange.onIf(controlsPrefs.allowTrackChange)
        
        btnAllowPlayQueueScrollingTopToBottom.onIf(controlsPrefs.allowPlayQueueScrollingTopToBottom)
        btnAllowPlayQueueScrollingPageUpDown.onIf(controlsPrefs.allowPlayQueueScrollingPageUpDown)
    }

    @IBAction func allowVolumeControlAction(_ sender: Any) {
        volumeControlSensitivityMenu.enableIf(btnAllowVolumeControl.isOn)
    }
    
    @IBAction func allowSeekingAction(_ sender: Any) {
        seekSensitivityMenu.enableIf(btnAllowSeeking.isOn)
    }
    
    @IBAction func enableAllGesturesAction(_ sender: Any) {
        
        gestureButtons.forEach {$0.on()}
        [volumeControlSensitivityMenu, seekSensitivityMenu].forEach {$0.enable()}
    }
    
    @IBAction func disableAllGesturesAction(_ sender: Any) {
        
        gestureButtons.forEach {$0.off()}
        [volumeControlSensitivityMenu, seekSensitivityMenu].forEach {$0.disable()}
    }
    
    func save() throws {
        
        let controlsPrefs = preferences.controlsPreferences.gestures
        
        controlsPrefs.allowVolumeControl = btnAllowVolumeControl.isOn
        
        if let volumeControlSensitivity = volumeControlSensitivityMenu.enumValueForTitle(ofType: GesturesControlsPreferences.ScrollSensitivity.self) {
            controlsPrefs.volumeControlSensitivity = volumeControlSensitivity
        }

        controlsPrefs.allowSeeking = btnAllowSeeking.isOn
        
        if let seekSensitivity = seekSensitivityMenu.enumValueForTitle(ofType: GesturesControlsPreferences.ScrollSensitivity.self) {
            controlsPrefs.seekSensitivity = seekSensitivity
        }

        controlsPrefs.allowTrackChange = btnAllowTrackChange.isOn

        controlsPrefs.allowPlayQueueScrollingTopToBottom = btnAllowPlayQueueScrollingTopToBottom.isOn
        controlsPrefs.allowPlayQueueScrollingPageUpDown = btnAllowPlayQueueScrollingPageUpDown.isOn
    }
}
