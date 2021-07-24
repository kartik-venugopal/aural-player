//
//  HostedAudioUnitProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import AVFoundation

///
/// A functional contract for an effects unit that wraps an Audio Units (AU) plug-in that is "hosted" by the application.
///
/// AU plug-ins can be used for applying effects or to monitor, analyze, or visualize
/// audio signals.
///
protocol HostedAudioUnitProtocol: EffectsUnitProtocol {
    
    var name: String {get}
    
    var componentType: OSType {get}
    var componentSubType: OSType {get}
    
    var params: [AUParameterAddress: Float] {get}
    
    var auAudioUnit: AUAudioUnit {get}
    
    var factoryPresets: [AudioUnitFactoryPreset] {get}
    
    func applyFactoryPreset(_ preset: AudioUnitFactoryPreset)
    
    func applyFactoryPreset(named presetName: String)
}
