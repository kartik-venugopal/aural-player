//
// AudioGraph+SoundProfiles.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension AudioGraph {
    
    func applySoundProfile(_ profile: SoundProfile) {
        
        self.volume = profile.volume
        self.pan = profile.pan
        masterUnit.applyPreset(profile.effects)
    }
    
    func captureSystemSoundProfile() {
        
        soundProfiles.systemProfile = SoundProfile(file: URL(fileURLWithPath: "system"),
                                                   volume: volume,
                                                   pan: pan,
                                                   effects: settingsAsMasterPreset)
    }
    
    func restoreSystemSoundProfile() {
        
        guard let systemSoundProfile = soundProfiles.systemProfile else {return}
        
        self.volume = systemSoundProfile.volume
        self.pan = systemSoundProfile.pan
        masterUnit.applyPreset(systemSoundProfile.effects)
    }
}
