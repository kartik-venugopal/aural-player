import AVFoundation

class HostedAudioUnit: FXUnit, HostedAudioUnitProtocol {
    
    private let node: HostedAUNode
    
    var name: String {node.audioUnitName}
    
    var componentSubType: OSType {node.componentSubType}
    
    var auAudioUnit: AUAudioUnit {node.auAudioUnit}
    
    let presets: AudioUnitPresets = AudioUnitPresets()
    
    var supportsUserPresets: Bool {
        
        if #available(OSX 10.15, *) {
            return auAudioUnit.supportsUserPresets
        }
        
        return false
    }
    
    let factoryPresets: [AudioUnitFactoryPreset]
    
    var params: [AUParameterAddress: Float] {
        
        get {node.params}
        set(newParams) {node.params = newParams}
    }
    
    func printParams() {node.printParams()}
    
    override var avNodes: [AVAudioNode] {return [node]}
    
    init(withComponentDescription description: AudioComponentDescription) {
        
        self.node = HostedAUNode(audioComponentDescription: description)
        
        self.factoryPresets = node.auAudioUnit.factoryPresets?.map {AudioUnitFactoryPreset(name: $0.name, number: $0.number)} ?? []
        
        super.init(.au, .active)
    }
    
    init(withComponentDescription description: AudioComponentDescription, appState: AudioUnitState) {
        
        self.node = HostedAUNode(audioComponentDescription: description)
        
        var nodeParams: [AUParameterAddress: Float] = [:]
        for param in appState.params {
            nodeParams[param.address] = param.value
        }
        self.node.params = nodeParams
        
        self.factoryPresets = node.auAudioUnit.factoryPresets?.map {AudioUnitFactoryPreset(name: $0.name, number: $0.number)} ?? []
        
        super.init(.au, appState.state)
        presets.addPresets(appState.userPresets)
    }
    
    override func stateChanged() {

        super.stateChanged()
        node.bypass = !isActive
    }

    override func savePreset(_ presetName: String) {
        
        if let preset = node.savePreset(presetName) {
            presets.addPreset(AudioUnitPreset(presetName, .active, false, number: preset.number))
        }
    }

    override func applyPreset(_ presetName: String) {

        if let preset = presets.presetByName(presetName) {
            applyPreset(preset)
        }
    }

    func applyPreset(_ preset: AudioUnitPreset) {
        node.applyPreset(preset.number)
    }
    
    func applyFactoryPreset(_ preset: AudioUnitFactoryPreset) {
        
        if let auPresets = auAudioUnit.factoryPresets,
           let thePreset = auPresets.first(where: {$0.number == preset.number}) {
            
            auAudioUnit.currentPreset = thePreset
        }
    }
    
    func applyFactoryPreset(_ presetName: String) {
        
        if let auPresets = auAudioUnit.factoryPresets,
           let thePreset = auPresets.first(where: {$0.name == presetName}) {
            
            auAudioUnit.currentPreset = thePreset
        }
    }

    // TODO: This is not meaningful
    var settingsAsPreset: AudioUnitPreset {
        return AudioUnitPreset("au-\(name)-Settings", state, false, number: 0)
    }
    
    var persistentState: AudioUnitState {

        let unitState = AudioUnitState()

        unitState.state = state
        unitState.componentSubType = Int(self.node.componentSubType)
        
        for (address, value) in self.params {
            
            let paramState = AudioUnitParameterState()
            paramState.address = address
            paramState.value = value
            
            unitState.params.append(paramState)
        }
        
        unitState.userPresets = presets.userDefinedPresets

        return unitState
    }
}
