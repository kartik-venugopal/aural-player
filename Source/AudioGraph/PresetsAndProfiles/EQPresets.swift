//
//  EQPresets.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Manages a mapped collection of presets that can be applied to the Equalizer effects unit.
///
class EQPresets: EffectsUnitPresets<EQPreset> {
    
    /// Default EQ preset.
    static let flatPreset: EQPreset = EQPreset(name: "Flat", state: .active, bands: [Float](repeating: 0, count: 15),
                                               globalGain: 0, systemDefined: true)
    
    fileprivate static let systemDefinedPresets: [EQPreset] = [

        flatPreset,
        
        EQPreset(name: "High bass and treble", state: .active, bands: [15.0, 15.0, 12.5, 10.0, 10.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 10.0, 12.5, 12.5, 15.0],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Dance", state: .active, bands: [0.0, 3.5, 7.0, 4.0, 4.0, 0.0, -1.0, -1.0, -2.0, -4.0, -4.0, 0.0, 4.0, 4.0, 5.0],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Electronic", state: .active, bands: [7.0, 7.0, 6.5, 0.0, 0.0, -2.0, -5.0, -5.0, 0.0, 0.0, 0.0, 0.0, 6.5, 6.5, 7.0],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Hip Hop", state: .active, bands: [7.0, 7.0, 7.0, 0.0, 0.0, 0.0, -3.0, -3.0, -3.0, -2.0, -2.0, 1.0, 1.0, 1.0, 7.0],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Jazz", state: .active, bands: [0.0, 0.0, 3.0, 0.0, 0.0, 0.0, -3.0, -3.0, -3.0, 0.0, 0.0, 0.0, 3.0, 3.0, 5.0],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Latin", state: .active, bands: [8.0, 8.0, 5.0, 0.0, 0.0, 0.0, -4.0, -4.0, -4.0, -4.0, -4.0, 0.0, 6.0, 6.0, 8.0],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Lounge", state: .active, bands: [-5.0, -5.0, -2.0, 0.0, 0.0, 2.0, 4.0, 4.0, 3.0, 0.0, 0.0, 0.0, 3.0, 3.0, 0.0],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Piano", state: .active, bands: [1.0, 1.0, -1.0, -3.0, -3.0, 0.0, 1.0, 1.0, -1.0, 2.0, 2.0, 3.0, 1.0, 1.0, 2.0],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Pop", state: .active, bands: [-2.0, -2.0, -1.5, 0.0, 0.0, 3.0, 7.0, 7.0, 7.0, 3.5, 3.5, 0.0, -2.0, -2.0, -3.0],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "R&B", state: .active, bands: [0.0, 0.0, 7.0, 4.0, 4.0, -3.0, -5.0, -5.0, -4.5, -2.0, -2.0, -1.5, 0.0, 0.0, 1.5],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Rock", state: .active, bands: [5.0, 5.0, 3.0, 1.5, 1.5, 0.0, -5.0, -5.0, -6.0, -2.5, -2.5, 0.0, 2.5, 2.5, 4.0],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Soft", state: .active, bands: [0.0, 0.0, 1.0, 2.0, 2.0, 6.0, 8.0, 8.0, 10.0, 12.0, 12.0, 12.0, 13.0, 13.0, 14.0],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Karaoke", state: .active, bands: [8.0, 8.0, 6.0, 4.0, 4.0, -20.0, -20.0, -20.0, -20.0, -20.0, -20.0, 4.0, 6.0, 6.0, 8.0],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Vocal", state: .active, bands: [-20.0, -20.0, -20.0, -20.0, -20.0, 12.0, 14.0, 14.0, 14.0, 12.0, 12.0, -20.0, -20.0, -20.0, -20.0],
                 globalGain: 0, systemDefined: true)
    ]
    
    init(persistentState: EQUnitPersistentState?) {
        
        let userDefinedPresets = (persistentState?.userPresets ?? []).compactMap {EQPreset(persistentState: $0)}
        
        super.init(systemDefinedObjects: Self.systemDefinedPresets, userDefinedObjects: userDefinedPresets)
    }
    
    override var defaultPreset: EQPreset {Self.flatPreset}
}

///
/// Represents a single Equalizer effects unit preset.
///
class EQPreset: EffectsUnitPreset {
    
    let bands: [Float]
    let globalGain: Float
    
    init(name: String, state: EffectsUnitState, bands: [Float],
         globalGain: Float, systemDefined: Bool) {
        
        self.bands = bands
        self.globalGain = globalGain
        super.init(name: name, state: state, systemDefined: systemDefined)
    }
    
    init?(persistentState: EQPresetPersistentState) {
        
        guard let name = persistentState.name, let unitState = persistentState.state,
              var bands = persistentState.bands else {return nil}
        
        // For backward-compatibility with 10-band presets.
        if bands.count == 10 {
            bands = Self.map10BandsTo15Bands(bands)
        }
        
        self.bands = bands
        self.globalGain = persistentState.globalGain ?? AudioGraphDefaults.eqGlobalGain
        
        super.init(name: name, state: unitState, systemDefined: false)
    }
    
    private static func map10BandsTo15Bands(_ srcBands: [Float]) -> [Float] {
        
        var bands = [0, 0, 1, 2, 2, 3, 4, 4, 5, 6, 6, 7, 8, 8, 9].map {srcBands[$0]}
        
        bands[1] = (bands[0] + bands[2]) / 2
        bands[4] = (bands[3] + bands[5]) / 2
        bands[7] = (bands[6] + bands[8]) / 2
        bands[10] = (bands[9] + bands[11]) / 2
        bands[13] = (bands[12] + bands[14]) / 2
        
        return bands
    }
}

extension EQPreset: Equatable {
    
    static func == (lhs: EQPreset, rhs: EQPreset) -> Bool {
        
        if lhs.bands.count != rhs.bands.count {
            return false
        }
        
        for index in lhs.bands.indices {
            
            if Float.valuesDiffer(lhs.bands[index], rhs.bands[index], tolerance: 0.001) {
                return false
            }
        }
        
        if Float.valuesDiffer(lhs.globalGain, rhs.globalGain, tolerance: 0.001) {
            return false
        }
        
        return true
    }
    
    func equalToOtherPreset(globalGain: Float, bands: [Float]) -> Bool {
        
        if self.bands.count != bands.count {
            return false
        }
        
        for index in self.bands.indices {
            
            if Float.valuesDiffer(self.bands[index], bands[index], tolerance: 0.001) {
                return false
            }
        }
        
        if Float.valuesDiffer(self.globalGain, globalGain, tolerance: 0.001) {
            return false
        }
        
        return true
    }
}
