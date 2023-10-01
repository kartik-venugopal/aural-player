//
//  HostedAUNode.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation
import CoreAudioKit
import Cocoa

///
/// A specialized subclass of **AVAudioUnitEffect** that represents an Audio Unit (AU) plug-in.
///
/// Provides convenient access to various properties / functions of the plug-in (eg. name, version, manufacturer).
///
class HostedAUNode: AVAudioUnitEffect {
    
    private var avComponent: AVAudioUnitComponent!
    
    var componentType: OSType {avComponent.componentType}
    var componentSubType: OSType {avComponent.componentSubType}
    
    var componentName: String {avComponent.name}
    var componentVersion: String {avComponent.versionString}
    var componentManufacturerName: String {avComponent.manufacturerName}
    
    var hasCustomView: Bool {avComponent.hasCustomView}
    
    var parameterTree: AUParameterTree? {auAudioUnit.parameterTree}
    private var bypassStateObservers: [AUNodeBypassStateObserver] = []
    
    var parameterValues: [AUParameterAddress: Float] {
        
        get {
            
            var dict: [AUParameterAddress: Float] = [:]
            
            for param in parameterTree?.allParameters ?? [] {
                dict[param.address] = param.value
            }
            
            return dict
        }
        
        set(newParams) {
            
            for (address, value) in newParams {
                parameterTree?.parameter(withAddress: address)?.value = value
            }
        }
    }
    
    private static let bypassPropertyKey: String = "shouldBypassEffect"
    
    convenience init(forComponent component: AVAudioUnitComponent) {
        
        self.init(audioComponentDescription: component.audioComponentDescription)
        self.avComponent = component

        auAudioUnit.addObserver(self, forKeyPath: Self.bypassPropertyKey, options: .init(), context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == Self.bypassPropertyKey {
            bypassStateObservers.forEach {$0.nodeBypassStateChanged(auAudioUnit.shouldBypassEffect)}
        }
    }
    
    func addBypassStateObserver(_ observer: AUNodeBypassStateObserver) {
        bypassStateObservers.append(observer)
    }
    
    func savePreset(named presetName: String) -> AUAudioUnitPreset? {
        
        guard #available(OSX 10.15, *), auAudioUnit.supportsUserPresets else {
            
            NSLog("User presets not supported for audio unit: \(name)")
            return nil
        }
        
        let preset = AUAudioUnitPreset()
        preset.name = presetName
        preset.number = -1 * (auAudioUnit.userPresets.count + 1)
        
        do {
            
            try auAudioUnit.saveUserPreset(preset)
            return preset
            
        } catch {
            
            NSLog("Failed to save user preset '\(presetName)'. Error: \(error)")
            return nil
        }
    }
    
    func applyPreset(number: Int) {
        
        if #available(OSX 10.15, *),
           let preset = auAudioUnit.userPresets.first(where: {$0.number == number}) {
            
            auAudioUnit.currentPreset = preset
        }
    }
    
    func setValue(_ value: Float, forParameterWithAddress address: AUParameterAddress) {
        parameterTree?.parameter(withAddress: address)?.value = value
    }
}

///
/// Contract for observers that observe the bypass state of a hosted AU node.
///
protocol AUNodeBypassStateObserver {
    
    func nodeBypassStateChanged(_ nodeIsBypassed: Bool)
}
