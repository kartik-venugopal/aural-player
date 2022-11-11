//
//  RemoteControlPreferencesViewController.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class RemoteControlPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var lblNotApplicable: NSTextField!
    @IBOutlet weak var controlsBox: NSBox!
    
    @IBOutlet weak var btnEnableRemoteControl: NSButton!
    
    @IBOutlet weak var btnShowTrackChangeControls: NSButton!
    @IBOutlet weak var btnShowSeekingControls: NSButton!
    
    @available(OSX 10.12.2, *)
    private var remoteControlManager: RemoteControlManager {objectGraph.remoteControlManager}
    
    override var nibName: String? {"RemoteControlPreferences"}
    
    override func viewDidLoad() {
        
        if #available(OSX 10.12.2, *) {
            
            lblNotApplicable.hide()
            controlsBox.show()
            
        } else {

            controlsBox.hide()
            lblNotApplicable.show()
        }
    }
    
    var preferencesView: NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        if #available(OSX 10.12.2, *) {
            
            let controlsPrefs = preferences.controlsPreferences.remoteControl
            
            btnEnableRemoteControl.onIf(controlsPrefs.enabled)
            btnShowTrackChangeControls.onIf(controlsPrefs.trackChangeOrSeekingOption == .trackChange)
            btnShowSeekingControls.onIf(controlsPrefs.trackChangeOrSeekingOption == .seeking)
        }
    }
    
    @IBAction func trackChangeOrSeekingOptionsAction(_ sender: Any) {
        // Needed for radio button group.
    }
    
    func save(_ preferences: Preferences) throws {

        if #available(OSX 10.12.2, *) {
            
            let controlsPrefs = preferences.controlsPreferences.remoteControl
            
            let wasEnabled: Bool = controlsPrefs.enabled
            let oldTrackChangeOrSeekingOption = controlsPrefs.trackChangeOrSeekingOption
            
            controlsPrefs.enabled = btnEnableRemoteControl.isOn
            controlsPrefs.trackChangeOrSeekingOption = btnShowTrackChangeControls.isOn ? .trackChange : .seeking
            
            // Don't do anything unless at least one preference was changed.
            
            let prefsHaveChanged = (wasEnabled != controlsPrefs.enabled) || (oldTrackChangeOrSeekingOption != controlsPrefs.trackChangeOrSeekingOption)
            
            if prefsHaveChanged {
                remoteControlManager.preferencesUpdated()
            }
        }
    }
}
