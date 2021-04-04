import Foundation

class MasterPresets: FXPresets<MasterPreset> {}

class MasterPreset: EffectsUnitPreset {
    
    let eq: EQPreset
    let pitch: PitchPreset
    let time: TimePreset
    let reverb: ReverbPreset
    let delay: DelayPreset
    let filter: FilterPreset
    let audioUnits: [AudioUnitPreset]
    
    init(_ name: String, _ eq: EQPreset, _ pitch: PitchPreset, _ time: TimePreset, _ reverb: ReverbPreset, _ delay: DelayPreset, _ filter: FilterPreset, _ audioUnits: [AudioUnitPreset], _ systemDefined: Bool) {
        
        self.eq = eq
        self.pitch = pitch
        self.time = time
        self.reverb = reverb
        self.delay = delay
        self.filter = filter
        self.audioUnits = audioUnits
        
        super.init(name, .active, systemDefined)
    }
}
