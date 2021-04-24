import Foundation

class MasterUnitState: FXUnitState<MasterPresetState> {}

class MasterPresetState: EffectsUnitPresetState {
    
    let eq: EQPresetState?
    let pitch: PitchPresetState?
    let time: TimePresetState?
    let reverb: ReverbPresetState?
    let delay: DelayPresetState?
    let filter: FilterPresetState?
    
    required init?(_ map: NSDictionary) {

        super.init(map)
        
        guard let eq = map.objectValue(forKey: "eq", ofType: EQPresetState.self),
              let pitch = map.objectValue(forKey: "pitch", ofType: PitchPresetState.self),
              let time = map.objectValue(forKey: "time", ofType: TimePresetState.self),
              let reverb = map.objectValue(forKey: "reverb", ofType: ReverbPresetState.self),
              let delay = map.objectValue(forKey: "delay", ofType: DelayPresetState.self),
              let filter = map.objectValue(forKey: "filter", ofType: FilterPresetState.self) else {return nil}
        
        self.eq = eq
        self.pitch = pitch
        self.time = time
        self.reverb = reverb
        self.delay = delay
        self.filter = filter
    }
}
