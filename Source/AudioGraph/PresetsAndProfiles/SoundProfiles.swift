//
//  SoundProfiles.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A collection of sound profiles.
///
/// - SeeAlso: `SoundProfile`
///
class SoundProfiles: TrackKeyedMap<SoundProfile> {
    
    init(persistentState: [SoundProfilePersistentState]?) {
        
        super.init()
        
        for profile in persistentState ?? [] {
            
            guard let file = profile.file, let volume = profile.volume,
                  let balance = profile.balance, let effects = profile.effects,
                  let masterPreset = MasterPreset(persistentState: effects) else {continue}
            
            add(file, SoundProfile(file: file, volume: volume,
                                   balance: balance, effects: masterPreset))
        }
    }
}

///
/// A sound profile is a snapshot of all Audio Graph settings at any given time,
/// mapped to a specific track.
///
/// By capturing a sound profile, and mapping it to a track, the app can "remember"
/// effects settings on a per-track basis and the app can then automatically re-apply
/// those settings whenever that track is played by the user.
///
struct SoundProfile {
    
    let file: URL
    
    let volume: Float
    let balance: Float
    
    let effects: MasterPreset
}
