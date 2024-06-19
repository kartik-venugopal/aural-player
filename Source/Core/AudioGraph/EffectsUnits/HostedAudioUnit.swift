//
//  HostedAudioUnit.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// An effects unit that wraps an Audio Units (AU) plug-in that is "hosted" by the application.
///
/// - SeeAlso: `HostedAudioUnitProtocol`
///
class HostedAudioUnit: EffectsUnit, HostedAudioUnitProtocol, AUNodeBypassStateObserver {
    
    let node: HostedAUNode
    
    var name: String {node.componentName}
    var version: String {node.componentVersion}
    var manufacturerName: String {node.componentManufacturerName}
    
    var componentType: OSType {node.componentType}
    var componentSubType: OSType {node.componentSubType}
    
    var auAudioUnit: AUAudioUnit {node.auAudioUnit}
    
    var hasCustomView: Bool {node.hasCustomView}
    
    var supportsUserPresets: Bool {
        auAudioUnit.supportsUserPresets
    }
    
    let factoryPresets: [AudioUnitFactoryPreset]
    
    var parameterValues: [AUParameterAddress: Float] {
        
        get {node.parameterValues}
        set(newParams) {node.parameterValues = newParams}
    }
    
    let presets: AudioUnitPresets
    var currentPreset: AudioUnitPreset? = nil
    
    var parameterTree: AUParameterTree? {node.parameterTree}
    
    override var avNodes: [AVAudioNode] {[node]}
    
    // Called when the user adds a new audio unit.
    init(forComponent component: AVAudioUnitComponent, presets: AudioUnitPresets) {
        
        self.node = HostedAUNode(forComponent: component)
        self.presets = presets
        self.factoryPresets = node.auAudioUnit.factoryPresets?.map {AudioUnitFactoryPreset(name: $0.name,
                                                                                           number: $0.number)} ?? []
        
        super.init(unitType: .au, unitState: .active)
        self.node.addBypassStateObserver(self)
        
        unitInitialized = true
    }
    
    // Called upon app startup when restoring from persisted state.
    init(forComponent component: AVAudioUnitComponent, persistentState: AudioUnitPersistentState, presets: AudioUnitPresets) {
        
        self.node = HostedAUNode(forComponent: component)
        self.presets = presets
        
        var nodeParams: [AUParameterAddress: Float] = [:]
        for param in persistentState.params ?? [] {
            
            guard let address = param.address, let value = param.value else {continue}
            nodeParams[address] = value
        }
        self.node.parameterValues = nodeParams
        
        self.factoryPresets = node.auAudioUnit.factoryPresets?.map {AudioUnitFactoryPreset(name: $0.name,
                                                                                           number: $0.number)} ?? []
        
        super.init(unitType: .au, unitState: persistentState.state ?? AudioGraphDefaults.auState)
        self.node.addBypassStateObserver(self)
        
        unitInitialized = true
    }
    
    // A flag indicating whether or not the node's bypass state should be updated
    // as a result of unit state being changed. This will always be true, unless
    // the node itself initiated the state change (eg. the user bypassing
    // the node directly from the AU's custom view).
    private var shouldUpdateNodeBypassState: Bool = true
    
    func nodeBypassStateChanged(_ nodeIsBypassed: Bool) {
        
        // This will be true if and only if the state change occurred as a result of the user
        // using a bypass switch on an AU's custom view (i.e. not through Aural's UI).
        if (nodeIsBypassed && state == .active) || ((!nodeIsBypassed) && state != .active) {
            
            shouldUpdateNodeBypassState = false
            self.state = nodeIsBypassed ? .bypassed : .active
            shouldUpdateNodeBypassState = true
            
            messenger.publish(.Effects.unitStateChanged)
        }
    }
    
    override func stateChanged() {

        super.stateChanged()
        
        if shouldUpdateNodeBypassState {
            node.bypass = !isActive
        }
    }

    override func savePreset(named presetName: String) {
        
        presets.addObject(AudioUnitPreset(name: presetName, state: .active, systemDefined: false, componentType: self.componentType,
                                          componentSubType: self.componentSubType, parameterValues: self.parameterValues))
    }

    override func applyPreset(named presetName: String) {

        if let preset = presets.object(named: presetName) {
            applyPreset(preset)
        }
    }

    func applyPreset(_ preset: AudioUnitPreset) {
        node.parameterValues = preset.parameterValues
    }
    
    func applyFactoryPreset(_ preset: AudioUnitFactoryPreset) {
        
        if let auPresets = auAudioUnit.factoryPresets,
           let thePreset = auPresets.first(where: {$0.number == preset.number}) {
            
            auAudioUnit.currentPreset = thePreset
        }
    }
    
    func applyFactoryPreset(named presetName: String) {
        
        if let auPresets = auAudioUnit.factoryPresets,
           let thePreset = auPresets.first(where: {$0.name == presetName}) {
            
            auAudioUnit.currentPreset = thePreset
        }
    }
    
    func setValue(_ value: Float, forParameterWithAddress address: AUParameterAddress) {
        node.setValue(value, forParameterWithAddress: address)
    }
    
    func setCurrentPreset(byName presetName: String) {}

    var settingsAsPreset: AudioUnitPreset {
        
        AudioUnitPreset(name: "au-\(name)-Settings", state: state, systemDefined: false, componentType: self.componentType,
                        componentSubType: self.componentSubType, parameterValues: self.parameterValues)
    }
    
    var persistentState: AudioUnitPersistentState {

        AudioUnitPersistentState(state: self.state,
                                 componentType: self.componentType,
                                 componentSubType: self.componentSubType,
                                 params: self.parameterValues.map {AudioUnitParameterPersistentState(address: $0.key, value: $0.value)})
    }
}
