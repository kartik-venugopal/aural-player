import Foundation

class MasterUnit: FXUnit, MessageSubscriber, FXUnitPresetsProtocol {
    
    var presets: MasterPresets
    
    var slaveUnits: [FXUnit]

    init(_ appState: AudioGraphState, _ slaveUnits: [FXUnit]) {
        
        self.presets = MasterPresets()
        presets.addPresets(appState.masterUserPresets)
        
        self.slaveUnits = slaveUnits
        
        super.init(.master, appState.masterState)
        
        SyncMessenger.subscribe(messageTypes: [.fxUnitActivatedNotification], subscriber: self)
    }
    
    override func toggleState() -> EffectsUnitState {
        
        let newState = super.toggleState()
        
        if newState == .bypassed {
            
            // Active -> Inactive
            
            // If a unit was active (i.e. not bypassed), mark it as now being suppressed by the master bypass
            slaveUnits.forEach({$0.suppress()})
            
        } else {
            
            // Inactive -> Active
            slaveUnits.forEach({$0.unsuppress()})
        }
        
        return newState
    }
    
    func savePreset(_ presetName: String) {
        
//        let eqUnit = slaveUnits.first(where: {$0.type == .eq})!
//        let pitchUnit = slaveUnits.first(where: {$0.type == .pitch})!
//        let timeUnit = slaveUnits.first(where: {$0.type == .time})!
//        let reverbUnit = slaveUnits.first(where: {$0.type == .reverb})!
//        let delayUnit = slaveUnits.first(where: {$0.type == .delay})!
//        let filterUnit = slaveUnits.first(where: {$0.type == .filter})!
//
//        // Save the new preset
//        let masterPreset = MasterPreset(presetName, eqPreset, pitchPreset, timePreset, reverbPreset, delayPreset, filterPreset, false)
//        masterPresets.addPreset(masterPreset)
    }
    
//    func getSettingsAsPreset() -> MasterPreset {
//
//        let dummyPresetName = "masterPreset_for_soundProfile"
//
//        var slavePresets = [EffectsUnitPreset]()
//
//
//        // EQ state
//        let eqState = getEQState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
//        let eqBands = eqNode.allBands()
//        let eqGlobalGain = eqNode.globalGain
//
//        let eqPreset = EQPreset(dummyPresetName, eqState, eqBands, eqGlobalGain, false)
//
//        // Pitch state
//        let pitchState = getPitchState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
//        let pitch = pitchNode.pitch
//        let pitchOverlap = pitchNode.overlap
//
//        let pitchPreset = PitchPreset(dummyPresetName, pitchState, pitch, pitchOverlap, false)
//
//        // Time state
//        let timeState = getTimeState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
//        let rate = timeNode.rate
//        let timeOverlap = timeNode.overlap
//        let timePitchShift = timeNode.shiftPitch
//
//        let timePreset = TimePreset(dummyPresetName, timeState, rate, timeOverlap, timePitchShift, false)
//
//        // Reverb state
//        let reverbState = getReverbState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
//        let space = getReverbSpace()
//        let reverbAmount = reverbNode.wetDryMix
//
//        let reverbPreset = ReverbPreset(dummyPresetName, reverbState, space, reverbAmount, false)
//
//        // Delay state
//        let delayState = getDelayState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
//        let delayTime = delayNode.delayTime
//        let delayAmount = delayNode.wetDryMix
//        let cutoff = delayNode.lowPassCutoff
//        let feedback = delayNode.feedback
//
//        let delayPreset = DelayPreset(dummyPresetName, delayState, delayAmount, delayTime, feedback, cutoff, false)
//
//        // Filter state
//        let filterState = getFilterState() == EffectsUnitState.active ? EffectsUnitState.active : EffectsUnitState.bypassed
//        let filterPreset = FilterPreset(dummyPresetName, filterState, filterNode.allBands(), false)
//
//        return MasterPreset("_masterPreset_for_soundProfile", eqPreset, pitchPreset, timePreset, reverbPreset, delayPreset, filterPreset, false)
//    }
    
    func applyPreset(_ preset: MasterPreset) {
        
//        applyEQPreset(preset.eq)
//        applyPitchPreset(preset.pitch)
//        applyTimePreset(preset.time)
//        applyReverbPreset(preset.reverb)
//        applyDelayPreset(preset.delay)
//        applyFilterPreset(preset.filter)
//
//        // Apply unit states and determine master state
//        eqNode.bypass = preset.eq.state != .active
//        pitchNode.bypass = preset.pitch.state != .active
//        timeNode.bypass = preset.time.state != .active
//        reverbNode.bypass = preset.reverb.state != .active
//        delayNode.bypass = preset.delay.state != .active
//        filterNode.bypass = preset.filter.state != .active
//
//        let needMasterActive = !(eqNode.bypass && pitchNode.bypass && timeNode.bypass && reverbNode.bypass && delayNode.bypass && filterNode.bypass)
//
//        if needMasterActive && masterBypass {
//            masterBypass = false
//        }
    }
    
    func getID() -> String {
        return "MasterFXUnit"
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if notification.messageType == .fxUnitActivatedNotification {
            
            if state == .bypassed {
                
                // Activate the master and unsuppress all the slaves
                _ = self.toggleState()
            }
        }
    }
}
