import Foundation

class MasterUnit: FXUnit, MessageSubscriber {
    
    var slaveUnits: [FXUnit]
    let presets: MasterPresets = MasterPresets()

    init(_ appState: AudioGraphState, _ slaveUnits: [FXUnit]) {
        
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
    
    override func savePreset(_ presetName: String) {
//        presets.addPreset(PitchPreset(presetName, .active, pitch, overlap, false))
    }
    
    override func applyPreset(_ presetName: String) {
        
//        if let preset = presets.presetByName(presetName) {
//            pitch = preset.pitch
//            overlap = preset.overlap
//        }
    }
    
//    func persistentState() -> PitchUnitState {
//
//        let unitState = PitchUnitState()
//
//        unitState.unitState = state
//        unitState.pitch = pitch
//        unitState.overlap = overlap
//        unitState.userPresets = presets.userDefinedPresets
//
//        return unitState
//    }
}
