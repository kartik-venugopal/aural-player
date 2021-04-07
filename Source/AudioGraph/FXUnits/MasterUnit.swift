import Foundation

class MasterUnit: FXUnit, NotificationSubscriber {
    
    let presets: MasterPresets = MasterPresets()
    
    var eqUnit: EQUnit
    var pitchUnit: PitchUnit
    var timeUnit: TimeUnit
    var reverbUnit: ReverbUnit
    var delayUnit: DelayUnit
    var filterUnit: FilterUnit
    
    var nativeSlaveUnits: [FXUnit]
    var audioUnits: [HostedAudioUnit]

    init(_ appState: AudioGraphState, _ nativeSlaveUnits: [FXUnit], _ audioUnits: [HostedAudioUnit]) {
        
        self.nativeSlaveUnits = nativeSlaveUnits
        
        eqUnit = nativeSlaveUnits.first(where: {$0 is EQUnit})! as! EQUnit
        pitchUnit = nativeSlaveUnits.first(where: {$0 is PitchUnit})! as! PitchUnit
        timeUnit = nativeSlaveUnits.first(where: {$0 is TimeUnit})! as! TimeUnit
        reverbUnit = nativeSlaveUnits.first(where: {$0 is ReverbUnit})! as! ReverbUnit
        delayUnit = nativeSlaveUnits.first(where: {$0 is DelayUnit})! as! DelayUnit
        filterUnit = nativeSlaveUnits.first(where: {$0 is FilterUnit})! as! FilterUnit
        
        self.audioUnits = audioUnits
        
        super.init(.master, appState.masterUnit.state)
        presets.addPresets(appState.masterUnit.userPresets)
        
        Messenger.subscribe(self, .fx_unitActivated, self.ensureActive)
    }
    
    override func toggleState() -> EffectsUnitState {
        
        if super.toggleState() == .bypassed {

            // Active -> Inactive
            // If a unit was active (i.e. not bypassed), mark it as now being suppressed by the master bypass
            nativeSlaveUnits.forEach {$0.suppress()}
            audioUnits.forEach {$0.suppress()}
            
        } else {
            
            // Inactive -> Active
            nativeSlaveUnits.forEach {$0.unsuppress()}
            audioUnits.forEach {$0.unsuppress()}
        }
        
        return state
    }
    
    override func savePreset(_ presetName: String) {
        
        let eqPreset = eqUnit.settingsAsPreset
        eqPreset.name = String(format: "EQ settings for Master preset: '%@'", presetName)
        
        let pitchPreset = pitchUnit.settingsAsPreset
        pitchPreset.name = String(format: "Pitch settings for Master preset: '%@'", presetName)
        
        let timePreset = timeUnit.settingsAsPreset
        timePreset.name = String(format: "Time settings for Master preset: '%@'", presetName)
        
        let reverbPreset = reverbUnit.settingsAsPreset
        reverbPreset.name = String(format: "Reverb settings for Master preset: '%@'", presetName)
        
        let delayPreset = delayUnit.settingsAsPreset
        delayPreset.name = String(format: "Delay settings for Master preset: '%@'", presetName)
        
        let filterPreset = filterUnit.settingsAsPreset
        filterPreset.name = String(format: "Filter settings for Master preset: '%@'", presetName)
        
        // Save the new preset
        let masterPreset = MasterPreset(presetName, eqPreset, pitchPreset, timePreset, reverbPreset, delayPreset, filterPreset, false)
        presets.addPreset(masterPreset)
    }
    
    var settingsAsPreset: MasterPreset {
        
        let eqPreset = eqUnit.settingsAsPreset
        let pitchPreset = pitchUnit.settingsAsPreset
        let timePreset = timeUnit.settingsAsPreset
        let reverbPreset = reverbUnit.settingsAsPreset
        let delayPreset = delayUnit.settingsAsPreset
        let filterPreset = filterUnit.settingsAsPreset
        
        return MasterPreset("masterSettings", eqPreset, pitchPreset, timePreset, reverbPreset, delayPreset, filterPreset, false)
    }
    
    override func applyPreset(_ presetName: String) {
        
        if let preset = presets.presetByName(presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: MasterPreset) {
        
        eqUnit.applyPreset(preset.eq)
        eqUnit.state = preset.eq.state
        
        pitchUnit.applyPreset(preset.pitch)
        pitchUnit.state = preset.pitch.state
        
        timeUnit.applyPreset(preset.time)
        timeUnit.state = preset.time.state
        
        reverbUnit.applyPreset(preset.reverb)
        reverbUnit.state = preset.reverb.state
        
        delayUnit.applyPreset(preset.delay)
        delayUnit.state = preset.delay.state
        
        filterUnit.applyPreset(preset.filter)
        filterUnit.state = preset.filter.state
    }
    
    func addAudioUnit(_ unit: HostedAudioUnit) {
        audioUnits.append(unit)
    }
    
    func removeAudioUnits(_ descendingIndices: [Int]) {
        descendingIndices.forEach {audioUnits.remove(at: $0)}
    }
    
    var persistentState: MasterUnitState {

        let unitState = MasterUnitState()

        unitState.state = state
        unitState.userPresets = presets.userDefinedPresets

        return unitState
    }
}
