import AVFoundation

class HostedAudioUnit: FXUnit, HostedAudioUnitProtocol {
    
    private let node: HostedAUNode
    
    var name: String {node.audioUnitName}
    
    let presets: AudioUnitPresets = AudioUnitPresets()
    
    var params: [String: Float] {
        
        var params: [String: Float] = [:]
        let paramsMap = node.paramsMap
        
        for (id, param) in paramsMap {
            params[id] = param.value
        }
        
        return params
    }
    
    override var avNodes: [AVAudioNode] {return [node]}
    
    init?(_ componentSubType: OSType) {
        
        guard let node = HostedAUNode.create(ofType: componentSubType) else {return nil}
        self.node = node
        super.init(.au, .active)
    }
    
    init?(_ appState: AudioUnitState) {
        
        guard let node = HostedAUNode.create(ofType: OSType(appState.componentSubType)) else {return nil}
        self.node = node
        
        super.init(.au, appState.state)
        presets.addPresets(appState.userPresets)
    }
    
    override func stateChanged() {

        super.stateChanged()
        node.bypass = !isActive
    }

    override func savePreset(_ presetName: String) {
        presets.addPreset(AudioUnitPreset(presetName, .active, false, params: params))
    }

    override func applyPreset(_ presetName: String) {

        if let preset = presets.presetByName(presetName) {
            applyPreset(preset)
        }
    }

    func applyPreset(_ preset: AudioUnitPreset) {
        node.setParams(preset.params)
    }

    var settingsAsPreset: AudioUnitPreset {
        return AudioUnitPreset("au-\(name)-Settings", state, false, params: params)
    }
    
    var persistentState: AudioUnitState {

        let unitState = AudioUnitState()

        unitState.state = state
        unitState.componentId = self.name
        unitState.componentSubType = Int(self.node.componentSubType)
        unitState.params = self.params
        unitState.userPresets = presets.userDefinedPresets

        return unitState
    }
}
