import Foundation
import AVFoundation

class FXUnit {
    
    var unitType: EffectsUnit
    var state: EffectsUnitState {
        didSet {stateChanged()}
    }
    var avNodes: [AVAudioNode] {return []}
    
    var isActive: Bool {return state == .active}
    
    init(_ unitType: EffectsUnit, _ state: EffectsUnitState) {
        
        self.unitType = unitType
        self.state = state
        stateChanged()
    }
    
    func stateChanged() {
        
        if isActive && unitType != .master {
            SyncMessenger.publishNotification(FXUnitActivatedNotification.instance)
        }
    }
    
    // Toggles the state of the effects unit, and returns its new state
    func toggleState() -> EffectsUnitState {
        
        state = state == .active ? .bypassed : .active
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
    
    func reset() {}
    
    func savePreset(_ presetName: String) {}
    
    func applyPreset(_ presetName: String) {}
}

protocol FXUnitPresetsProtocol {
    
    associatedtype PresetType: EffectsUnitPreset
    associatedtype PresetsType: FXPresetsProtocol
    
    var presets: PresetsType {get}
    
    func savePreset(_ presetName: String)
    
    func applyPreset(_ preset: PresetType)
    
//    func getSettingsAsPreset() -> PresetType
}
