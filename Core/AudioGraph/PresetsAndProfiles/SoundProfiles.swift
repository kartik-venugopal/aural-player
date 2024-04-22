//
//  SoundProfiles.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A mapped collection of sound profiles.
///
/// - SeeAlso: `SoundProfile`
///
class SoundProfiles: TrackKeyedMap<SoundProfile> {
    
    var systemProfile: SoundProfile?
    
    init(persistentState: [SoundProfilePersistentState]?) {
        
        super.init()
        
        for profile in persistentState ?? [] {
            
            guard let url = profile.file, let volume = profile.volume,
                  let pan = profile.pan, let effects = profile.effects,
                  let masterPreset = MasterPreset(persistentState: effects) else {continue}
            
            self[url] = SoundProfile(file: url, volume: volume,
                                     pan: pan, effects: masterPreset)
        }
    }
    
    var persistentState: [SoundProfilePersistentState] {
        all().map {SoundProfilePersistentState(profile: $0)}
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
    let pan: Float
    
    let effects: MasterPreset
}
