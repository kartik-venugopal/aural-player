//
//  SoundProfile.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class SoundProfiles: TrackKeyedMap<SoundProfile> {
    
    init(_ profiles: [SoundProfilePersistentState]) {
        
        super.init()
        
        for profile in profiles {
            
            add(profile.file, SoundProfile(file: profile.file, volume: profile.volume, balance: profile.balance, effects: MasterPreset(persistentState: profile.effects)))
        }
    }
}

struct SoundProfile {
    
    let file: URL
    
    let volume: Float
    let balance: Float
    
    let effects: MasterPreset
}

class TrackKeyedMap<T> {

    var map: [URL: T] = [:]
    
    func add(_ track: Track, _ item: T) {
        map[track.file] = item
    }
    
    func add(_ file: URL, _ item: T) {
        map[file] = item
    }
    
    func get(_ track: Track) -> T? {
        return map[track.file]
    }
    
    func hasFor(_ track: Track) -> Bool {
        return get(track) != nil
    }
    
    func remove(_ track: Track) {
        map[track.file] = nil
    }
    
    func removeAll() {
        map.removeAll()
    }
    
    func all() -> [T] {
        return [T](map.values)
    }
    
    var size: Int {
        return map.count
    }
}
