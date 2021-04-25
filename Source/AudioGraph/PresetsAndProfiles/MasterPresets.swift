import Foundation

class MasterPresets: FXPresets<MasterPreset> {}

class MasterPreset: EffectsUnitPreset {
    
    let eq: EQPreset
    let pitch: PitchPreset
    let time: TimePreset
    let reverb: ReverbPreset
    let delay: DelayPreset
    let filter: FilterPreset
    
    init(_ name: String, _ eq: EQPreset, _ pitch: PitchPreset, _ time: TimePreset, _ reverb: ReverbPreset, _ delay: DelayPreset, _ filter: FilterPreset, _ systemDefined: Bool) {
        
        self.eq = eq
        self.pitch = pitch
        self.time = time
        self.reverb = reverb
        self.delay = delay
        self.filter = filter
        
        super.init(name, .active, systemDefined)
    }
    
    init(persistentState: MasterPresetPersistentState) {
        
        self.eq = EQPreset(persistentState: persistentState.eq)
        self.pitch = PitchPreset(persistentState: persistentState.pitch)
        self.time = TimePreset(persistentState: persistentState.time)
        self.reverb = ReverbPreset(persistentState: persistentState.reverb)
        self.delay = DelayPreset(persistentState: persistentState.delay)
        self.filter = FilterPreset(persistentState: persistentState.filter)
        
        super.init(persistentState: persistentState)
    }
}
