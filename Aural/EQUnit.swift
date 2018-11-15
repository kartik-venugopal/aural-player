import AVFoundation

class EQUnit: FXUnit, EQUnitProtocol {
    
    private let node: ParametricEQ
    let presets: EQPresets = EQPresets()
    
    init(_ appState: AudioGraphState) {
        
        let eqState = appState.eqUnit
        
        node = ParametricEQ(eqState.type, eqState.sync)
        super.init(.eq, eqState.state)
        
        bands = eqState.bands
        globalGain = eqState.globalGain
        
        presets.addPresets(eqState.userPresets)
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
        set(newValue) {node.globalGain = newValue}
    }
    
    var bands: [Int: Float] {
        
        get {return node.allBands()}
        set(newValue) {node.setBands(newValue)}
    }
    
    var sync: Bool {
        
        get {return node.sync}
        set(newValue) {node.sync = newValue}
    }
    
    override var avNodes: [AVAudioNode] {
        return node.allNodes
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
    
    override func savePreset(_ presetName: String) {
        presets.addPreset(EQPreset(presetName, .active, bands, globalGain, false))
    }
    
    override func applyPreset(_ presetName: String) {
        
        if let preset = presets.presetByName(presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: EQPreset) {
        
        state = preset.state
        bands = preset.bands
        globalGain = preset.globalGain
    }
    
    func getSettingsAsPreset() -> EQPreset {
        return EQPreset("eqSettings", state, bands, globalGain, false)
    }
    
    func persistentState() -> EQUnitState {

        let unitState = EQUnitState()

        unitState.state = state
        unitState.type = type
        unitState.bands = bands
        unitState.globalGain = globalGain
        unitState.sync = sync
        unitState.userPresets = presets.userDefinedPresets

        return unitState
    }
}

enum EQType: String {
    
    case tenBand
    case fifteenBand
}
