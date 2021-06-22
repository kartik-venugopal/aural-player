import AVFoundation

class EQUnit: FXUnit, EQUnitProtocol {
    
    private let node: ParametricEQ
    let presets: EQPresets = EQPresets()
    
    init(persistentState: EQUnitPersistentState?) {
        
        node = ParametricEQ(persistentState?.type ?? AudioGraphDefaults.eqType)
        super.init(.eq, persistentState?.state ?? AudioGraphDefaults.eqState)
        
        bands = persistentState?.bands ?? AudioGraphDefaults.eqBands
        globalGain = persistentState?.globalGain ?? AudioGraphDefaults.eqGlobalGain
        
        presets.addPresets((persistentState?.userPresets ?? []).map {EQPreset(persistentState: $0)})
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    var type: EQType {
        
        get {return node.type}
        set(newType) {node.chooseType(newType)}
    }
    
    var globalGain: Float {
        
        get {return node.globalGain}
        set {node.globalGain = newValue}
    }
    
    var bands: [Float] {
        
        get {return node.allBands()}
        set {node.setBands(newValue)}
    }
    
    override var avNodes: [AVAudioNode] {
        return node.allNodes
    }
    
    func setBand(_ index: Int , gain: Float) {
        node.setBand(index, gain: gain)
    }
    
    func increaseBass(_ increment: Float) -> [Float] {
        return node.increaseBass(increment)
    }
    
    func decreaseBass(_ decrement: Float) -> [Float] {
        return node.decreaseBass(decrement)
    }
    
    func increaseMids(_ increment: Float) -> [Float] {
        return node.increaseMids(increment)
    }
    
    func decreaseMids(_ decrement: Float) -> [Float] {
        return node.decreaseMids(decrement)
    }
    
    func increaseTreble(_ increment: Float) -> [Float] {
        return node.increaseTreble(increment)
    }
    
    func decreaseTreble(_ decrement: Float) -> [Float] {
        return node.decreaseTreble(decrement)
    }
    
    override func savePreset(_ presetName: String) {
        presets.addPreset(EQPreset(presetName, .active, bands, globalGain, false))
    }
    
    override func applyPreset(_ presetName: String) {
        
        if let preset = presets.presetByName(presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: EQPreset) {
        
        bands = preset.bands
        globalGain = preset.globalGain
    }
    
    var settingsAsPreset: EQPreset {
        return EQPreset("eqSettings", state, bands, globalGain, false)
    }
    
    var persistentState: EQUnitPersistentState {

        let unitState = EQUnitPersistentState()

        unitState.state = state
        unitState.type = type
        unitState.bands = bands
        unitState.globalGain = globalGain
        unitState.userPresets = presets.userDefinedPresets.map {EQPresetPersistentState(preset: $0)}

        return unitState
    }
}

enum EQType: String {
    
    case tenBand
    case fifteenBand
}
