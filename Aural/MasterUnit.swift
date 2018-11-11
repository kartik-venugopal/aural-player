import Foundation

class MasterUnit: FXUnit, MessageSubscriber {
    
    var slaveUnits: [FXUnit]
    let presets: MasterPresets = MasterPresets()
    
    var eqUnit: EQUnit
    var pitchUnit: PitchUnit
    var timeUnit: TimeUnit
    var reverbUnit: ReverbUnit
    var delayUnit: DelayUnit
    var filterUnit: FilterUnit

    init(_ appState: AudioGraphState, _ slaveUnits: [FXUnit]) {
        
        self.slaveUnits = slaveUnits
        
        eqUnit = slaveUnits.first(where: {$0 is EQUnit})! as! EQUnit
        pitchUnit = slaveUnits.first(where: {$0 is PitchUnit})! as! PitchUnit
        timeUnit = slaveUnits.first(where: {$0 is TimeUnit})! as! TimeUnit
        reverbUnit = slaveUnits.first(where: {$0 is ReverbUnit})! as! ReverbUnit
        delayUnit = slaveUnits.first(where: {$0 is DelayUnit})! as! DelayUnit
        filterUnit = slaveUnits.first(where: {$0 is FilterUnit})! as! FilterUnit
        
        super.init(.master, appState.masterUnitState.unitState)
        presets.addPresets(appState.masterUnitState.userPresets)
        
        SyncMessenger.subscribe(messageTypes: [.fxUnitActivatedNotification], subscriber: self)
    }
    
    override func toggleState() -> EffectsUnitState {
        
        if super.toggleState() == .bypassed {

            // Active -> Inactive
            // If a unit was active (i.e. not bypassed), mark it as now being suppressed by the master bypass
            slaveUnits.forEach({$0.suppress()})
            
        } else {
            
            // Inactive -> Active
            slaveUnits.forEach({$0.unsuppress()})
        }
        
        return state
    }
    
    override func savePreset(_ presetName: String) {
        
        let eqPreset = eqUnit.getSettingsAsPreset()
        let pitchPreset = pitchUnit.getSettingsAsPreset()
        let timePreset = timeUnit.getSettingsAsPreset()
        let reverbPreset = reverbUnit.getSettingsAsPreset()
        let delayPreset = delayUnit.getSettingsAsPreset()
        let filterPreset = filterUnit.getSettingsAsPreset()
        
        // Save the new preset
        let masterPreset = MasterPreset(presetName, eqPreset, pitchPreset, timePreset, reverbPreset, delayPreset, filterPreset, false)
        presets.addPreset(masterPreset)
    }
    
    func getSettingsAsPreset() -> MasterPreset {
        
        let eqPreset = eqUnit.getSettingsAsPreset()
        let pitchPreset = pitchUnit.getSettingsAsPreset()
        let timePreset = timeUnit.getSettingsAsPreset()
        let reverbPreset = reverbUnit.getSettingsAsPreset()
        let delayPreset = delayUnit.getSettingsAsPreset()
        let filterPreset = filterUnit.getSettingsAsPreset()
        
        return MasterPreset("masterSettings", eqPreset, pitchPreset, timePreset, reverbPreset, delayPreset, filterPreset, false)
    }
    
    override func applyPreset(_ presetName: String) {
        
        if let preset = presets.presetByName(presetName) {
            
            eqUnit.applyPreset(preset.eq)
            pitchUnit.applyPreset(preset.pitch)
            timeUnit.applyPreset(preset.time)
            reverbUnit.applyPreset(preset.reverb)
            delayUnit.applyPreset(preset.delay)
            filterUnit.applyPreset(preset.filter)
        }
    }
    
    func persistentState() -> MasterUnitState {

        let unitState = MasterUnitState()

        unitState.unitState = state
        unitState.userPresets = presets.userDefinedPresets

        return unitState
    }
    
    // MARK: Message handling
    
    func getID() -> String {
        return "MasterFXUnit"
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if notification.messageType == .fxUnitActivatedNotification {
            ensureActive()
        }
    }
}
