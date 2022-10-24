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
/// A mapped collection of sound profiles.
///
/// - SeeAlso: `SoundProfile`
///
class SoundProfiles: TrackKeyedMap<SoundProfile> {
    
    var systemProfile: SoundProfile?
    
    init(persistentState: [SoundProfilePersistentState]?) {
        
        super.init()
        
        for profile in persistentState ?? [] {
            
            guard let path = profile.file, let volume = profile.volume,
                  let pan = profile.pan, let effects = profile.effects,
                  let masterPreset = MasterPreset(persistentState: effects) else {continue}
            
            let url = URL(fileURLWithPath: path)
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
    
    let nameOfCurrentMasterPreset: String?
    let nameOfCurrentEQPreset: String?
    let nameOfCurrentTimeStretchPreset: String?
    let nameOfCurrentPitchShiftPreset: String?
    let nameOfCurrentReverbPreset: String?
    let nameOfCurrentDelayPreset: String?
    let nameOfCurrentFilterPreset: String?
    
    init(file: URL, volume: Float, pan: Float, effects: MasterPreset,
         nameOfCurrentMasterPreset: String? = nil,
         nameOfCurrentEQPreset: String? = nil, nameOfCurrentTimeStretchPreset: String? = nil,
         nameOfCurrentPitchShiftPreset: String? = nil, nameOfCurrentReverbPreset: String? = nil,
         nameOfCurrentDelayPreset: String? = nil, nameOfCurrentFilterPreset: String? = nil) {
        
        self.file = file
        self.volume = volume
        self.pan = pan
        self.effects = effects
        
        self.nameOfCurrentMasterPreset = nameOfCurrentMasterPreset
        self.nameOfCurrentEQPreset = nameOfCurrentEQPreset
        self.nameOfCurrentTimeStretchPreset = nameOfCurrentTimeStretchPreset
        self.nameOfCurrentPitchShiftPreset = nameOfCurrentPitchShiftPreset
        self.nameOfCurrentReverbPreset = nameOfCurrentReverbPreset
        self.nameOfCurrentDelayPreset = nameOfCurrentDelayPreset
        self.nameOfCurrentFilterPreset = nameOfCurrentFilterPreset
    }
}
