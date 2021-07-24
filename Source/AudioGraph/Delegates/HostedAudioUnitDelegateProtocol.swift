//
//  HostedAudioUnitDelegateProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa
import AVFoundation

///
/// A functional contract for a delegate representing a hosted AU effects unit.
///
/// Acts as a middleman between the Effects UI and a hosted AU effects unit,
/// providing a simplified interface / facade for the UI layer to control a hosted AU effects unit.
///
/// - SeeAlso: `HostedAudioUnit`
///
protocol HostedAudioUnitDelegateProtocol: EffectsUnitDelegateProtocol {
    
    var id: String {get}
    
    var name: String {get}
    var version: String {get}
    var manufacturerName: String {get}
    
    var componentType: OSType {get}
    var componentSubType: OSType {get}
    
    var params: [AUParameterAddress: Float] {get}

    var presets: AudioUnitPresets {get}
    var supportsUserPresets: Bool {get}
    
    var factoryPresets: [AudioUnitFactoryPreset] {get}
    
    func applyFactoryPreset(named presetName: String)
    
    func presentView(_ handler: @escaping (NSView) -> Void)
}
