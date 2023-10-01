//
//  MediaKeysPreferencesViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class MediaKeysPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    // Media keys response
    @IBOutlet weak var btnRespondToMediaKeys: NSButton!
    
    // SKip key behavior
    @IBOutlet weak var btnHybrid: NSButton!
    @IBOutlet weak var btnTrackChangesOnly: NSButton!
    @IBOutlet weak var btnSeekingOnly: NSButton!
    
    @IBOutlet weak var repeatSpeedMenu: NSPopUpButton!
    
    private lazy var mediaKeyHandler: MediaKeyHandler = objectGraph.mediaKeyHandler
    
    override var nibName: String? {"MediaKeysPreferences"}
    
    var preferencesView: NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let controlsPrefs = preferences.controlsPreferences.mediaKeys
        
        btnRespondToMediaKeys.onIf(controlsPrefs.enabled)
        mediaKeyResponseAction(self)
        
        [btnHybrid, btnTrackChangesOnly, btnSeekingOnly].forEach {$0?.off()}
        
        switch controlsPrefs.skipKeyBehavior {
            
        case .hybrid:   btnHybrid.on()
            
        case .trackChangesOnly:     btnTrackChangesOnly.on()
            
        case .seekingOnly:          btnSeekingOnly.on()
            
        }
        
        repeatSpeedMenu.selectItem(withTitle: controlsPrefs.repeatSpeed.rawValue.capitalized)
    }
    
    @IBAction func mediaKeyResponseAction(_ sender: Any) {
    }
    
    @IBAction func skipKeyBehaviorAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    func save(_ preferences: Preferences) throws {
        
        let controlsPrefs = preferences.controlsPreferences
        
        controlsPrefs.mediaKeys.enabled = btnRespondToMediaKeys.isOn
        
        if btnHybrid.isOn {
            controlsPrefs.mediaKeys.skipKeyBehavior = .hybrid
        } else if btnTrackChangesOnly.isOn {
            controlsPrefs.mediaKeys.skipKeyBehavior = .trackChangesOnly
        } else {
            controlsPrefs.mediaKeys.skipKeyBehavior = .seekingOnly
        }
        
        controlsPrefs.mediaKeys.repeatSpeed = SkipKeyRepeatSpeed(rawValue: repeatSpeedMenu.titleOfSelectedItem!.lowercased())!
        controlsPrefs.mediaKeys.enabled ? mediaKeyHandler.startMonitoring() : mediaKeyHandler.stopMonitoring()
    }
}
