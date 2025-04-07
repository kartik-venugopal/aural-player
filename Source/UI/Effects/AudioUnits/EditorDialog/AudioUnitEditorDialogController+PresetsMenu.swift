//
//  AudioUnitEditorDialogController+PresetsMenu.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

// ------------------------------------------------------------------------

// MARK: StringInputReceiver

extension AudioUnitEditorDialogController: StringInputReceiver {
    
    var inputPrompt: String {
        return "Enter a new preset name:"
    }
    
    var defaultValue: String? {
        return "<New preset>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
//        let presets = audioUnit.presets
//        
//        if presets.objectExists(named: string) {
//            return (false, "Preset with this name already exists !")
//        } else {
//            return (true, nil)
//        }
        return (true, nil)
    }
    
    // Receives a new EQ preset name and saves the new preset
    func acceptInput(_ string: String) {
        audioUnit.savePreset(named: string)
    }
}

class AudioUnitPresetsMenuDelegate: NSObject, NSMenuDelegate {
    
    var supportsUserPresets: Bool = false
    
    @IBOutlet weak var userPresetsMenuItem: NSMenuItem!
    @IBOutlet weak var saveUserPresetMenuItem: NSMenuItem!
    
    convenience init(supportsUserPresets: Bool) {

        self.init()
        self.supportsUserPresets = supportsUserPresets
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        [userPresetsMenuItem, saveUserPresetMenuItem].forEach {
            $0?.showIf(supportsUserPresets)
        }
    }
}

class AudioUnitUserPresetsMenuDelegate: NSObject, NSMenuDelegate {
    
    var audioUnit: HostedAudioUnitProtocol!
    
    var applyPresetAction: Selector!
    weak var target: AnyObject!
    
    convenience init(for audioUnit: HostedAudioUnitProtocol, applyPresetAction: Selector, target: AnyObject) {

        self.init()
        
        self.audioUnit = audioUnit
        self.applyPresetAction = applyPresetAction
        self.target = target
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        menu.items.removeAll()
        
//        guard let userPresets = audioUnit?.presets else {return}
//        
//        for preset in userPresets.userDefinedObjects.sorted(by: {$0.name < $1.name}) {
//            
//            menu.addItem(withTitle: preset.name, action: applyPresetAction, 
//                         target: self.target)
//        }
    }
}
