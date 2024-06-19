//
//  EQPresets.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Manages a mapped collection of presets that can be applied to the Equalizer effects unit.
///
class EQPresets: EffectsUnitPresets<EQPreset> {
    
    #if os(macOS)
    
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
    
    #elseif os(iOS)
    
    /// Default EQ preset.
    fileprivate static let flatPreset: EQPreset = EQPreset(name: "Flat", state: .active, bands: [Float](repeating: 0, count: 10),
                                                           globalGain: 0, systemDefined: true)
    
    fileprivate static let systemDefinedPresets: [EQPreset] = [

        flatPreset,
        
        EQPreset(name: "High bass and treble", state: .active, bands: [15, 12.5, 10, 0, 0, 0, 0, 10, 12.5, 15],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Dance", state: .active, bands: [0, 7, 4, 0, -1, -2, -4, 0, 4, 5],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Electronic", state: .active, bands: [7, 6.5, 0, -2, -5, 0, 0, 0, 6.5, 7],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Hip Hop", state: .active, bands: [7, 7, 0, 0, -3, -3, -2, 1, 1, 7],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Jazz", state: .active, bands: [0, 3, 0, 0, -3, -3, 0, 0, 3, 5],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Latin", state: .active, bands: [8, 5, 0, 0, -4, -4, -4, 0, 6, 8],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Lounge", state: .active, bands: [-5, -2, 0, 2, 4, 3, 0, 0, 3, 0],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Piano", state: .active, bands: [1, -1, -3, 0, 1, -1, 2, 3, 1, 2],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Pop", state: .active, bands: [-2, -1.5, 0, 3, 7, 7, 3.5, 0, -2, -3],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "R&B", state: .active, bands: [0, 7, 4, -3, -5, -4.5, -2, -1.5, 0, 1.5],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Rock", state: .active, bands: [5, 3, 1.5, 0, -5, -6, -2.5, 0, 2.5, 4],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Soft", state: .active, bands: [0, 1, 2, 6, 8, 10, 12, 12, 13, 14],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Karaoke", state: .active, bands: [8, 6, 4, -20, -20, -20, -20, 4, 6, 8],
                 globalGain: 0, systemDefined: true),
        
        EQPreset(name: "Vocal", state: .active, bands: [-20, -20, -20, 12, 14, 14, 12, -20, -20, -20],
                 globalGain: 0, systemDefined: true)
    ]
    
    #endif
    
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
              let bands = persistentState.bands else {return nil}
        
        self.bands = bands
        self.globalGain = persistentState.globalGain ?? AudioGraphDefaults.eqGlobalGain
        
        super.init(name: name, state: unitState, systemDefined: false)
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
