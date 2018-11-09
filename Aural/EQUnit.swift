import Foundation

class EQUnit: FXUnit {
    
    private let node: ParametricEQ
    
    init(_ appState: AudioGraphState) {
        
        self.node = ParametricEQ(appState.eqType, appState.eqSync)
        
        super.init(.eq, appState.eqState)
        
        node.bypass = self.state != .active
        node.setBands(appState.eqBands)
        node.globalGain = appState.eqGlobalGain
    }
    
    override func toggleState() -> EffectsUnitState {
        
        node.bypass = super.toggleState() != .active
        return state
    }
    
    var sync: Bool {
        return node.sync
    }
    
    func toggleSync() -> Bool {
        return node.toggleSync()
    }
    
    var type: EQType {
        
        get {
            return node.type
        }
        
        set(newType) {
            node.chooseType(newType)
        }
    }
    
    var globalGain: Float {
        
        get {
            return node.globalGain
        }
        
        set(newValue) {
            node.globalGain = newValue
        }
    }
    
    var bands: [Int: Float] {
        
        get {
            return node.allBands()
        }
        
        set(newValue) {
            node.setBands(newValue)
        }
    }
    
    func setBand(_ index: Int , gain: Float) {
        node.setBand(index, gain: gain)
    }
    
    func increaseBass(_ increment: Float) -> [Int : Float] {
        return node.increaseBass(increment)
    }
    
    func decreaseBass(_ decrement: Float) -> [Int : Float] {
        return node.decreaseBass(decrement)
    }
    
    func increaseMids(_ increment: Float) -> [Int: Float] {
        return node.increaseMids(increment)
    }
    
    func decreaseMids(_ decrement: Float) -> [Int: Float] {
        return node.decreaseMids(decrement)
    }
    
    func increaseTreble(_ increment: Float) -> [Int: Float] {
        return node.increaseTreble(increment)
    }
    
    func decreaseTreble(_ decrement: Float) -> [Int: Float] {
        return node.decreaseTreble(decrement)
    }
    
//    func savePreset(_ presetName: String) {
//        presets.addPreset(EQPreset(presetName, .active, bands, globalGain, false))
//    }
//
//    func applyPreset(_ preset: EQPreset) {
//
//        bands = preset.bands
//        globalGain = preset.globalGain
//    }
}
