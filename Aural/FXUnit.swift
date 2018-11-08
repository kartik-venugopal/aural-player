import Foundation
import AVFoundation

class FXUnit {
    
    var unitType: EffectsUnit
    var state: EffectsUnitState
//    var avNodes: [AVAudioNode]
    
    init(_ unitType: EffectsUnit, _ state: EffectsUnitState) {
        
        self.unitType = unitType
        self.state = state
    }
    
    // Toggles the state of the effects unit, and returns its new state
    func toggleState() -> EffectsUnitState {
        
        state = state == .active ? .bypassed : .active
        
        if unitType != .master && state == .active {
            SyncMessenger.publishNotification(FXUnitActivatedNotification.instance)
        }
        
        return state
    }
    
    func ensureActive() {
        
        if state != .active {
            _ = toggleState()
        }
    }
    
    func suppress() {
        state = state == .active ? .suppressed : state
    }
    
    func unsuppress() {
        state = state == .suppressed ? .active : state
    }
}

protocol FXUnitPresetsProtocol {
    
    associatedtype PresetType: EffectsUnitPreset
    associatedtype PresetsType: FXPresetsProtocol
    
    var presets: PresetsType {get}
    
    func savePreset(_ presetName: String)
    
    func applyPreset(_ preset: PresetType)
    
//    func getSettingsAsPreset() -> PresetType
}
