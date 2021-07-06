//
//  SoundProfilePersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

struct SoundProfilePersistentState: Codable {
    
    let file: URLPath?
    
    let volume: Float?
    let balance: Float?
    let effects: MasterPresetPersistentState?
    
    init(file: URLPath?, volume: Float?, balance: Float?, effects: MasterPresetPersistentState?) {
        
        self.file = file
        self.volume = volume
        self.balance = balance
        self.effects = effects
    }
    
    init(profile: SoundProfile) {
        
        self.file = profile.file.path
        self.volume = profile.volume
        self.balance = profile.balance
        self.effects = MasterPresetPersistentState(preset: profile.effects)
    }
}
