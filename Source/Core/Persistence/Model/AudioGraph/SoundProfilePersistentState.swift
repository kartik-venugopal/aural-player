//
//  SoundProfilePersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for a single sound profile.
///
/// - SeeAlso:  `SoundProfile`
///
struct SoundProfilePersistentState: Codable {
    
    let file: URL?
    
    let volume: Float?
    let pan: Float?
    let effects: MasterPresetPersistentState?
    
    init(file: URL?, volume: Float?, pan: Float?, effects: MasterPresetPersistentState?) {
        
        self.file = file
        self.volume = volume
        self.pan = pan
        self.effects = effects
    }
    
    init(profile: SoundProfile) {
        
        self.file = profile.file
        self.volume = profile.volume
        self.pan = profile.pan
        self.effects = MasterPresetPersistentState(preset: profile.effects)
    }
    
    init(legacyPersistentState: LegacySoundProfilePersistentState) {
        
        self.file = {
            
            guard let path = legacyPersistentState.file else {return nil}
            return URL(fileURLWithPath: path)
        }()
        
        self.volume = legacyPersistentState.volume
        self.pan = legacyPersistentState.pan
        self.effects = MasterPresetPersistentState(legacyPersistentState: legacyPersistentState.effects)
    }
}
