//
//  HostedAudioUnitDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa
import AVFoundation
import CoreAudioKit
import AudioToolbox
import CoreAudio

///
/// A delegate representing a hosted AU effects unit.
///
/// Acts as a middleman between the Effects UI and a hosted AU effects unit,
/// providing a simplified interface / facade for the UI layer to control a hosted AU effects unit.
///
/// - SeeAlso: `HostedAudioUnit`
/// - SeeAlso: `HostedAudioUnitDelegateProtocol`
///
class HostedAudioUnitDelegate: EffectsUnitDelegate<HostedAudioUnit>, HostedAudioUnitDelegateProtocol {
    
    var id: String
    
    var name: String {unit.name}
    var version: String {unit.version}
    var manufacturerName: String {unit.manufacturerName}
    
    var componentType: OSType {unit.componentType}
    var componentSubType: OSType {unit.componentSubType}
    
    var params: [AUParameterAddress: Float] {unit.params}
    
    var presets: AudioUnitPresets {unit.presets}
    var supportsUserPresets: Bool {unit.supportsUserPresets}
    
    var factoryPresets: [AudioUnitFactoryPreset] {unit.factoryPresets}
    
    var viewController: AUViewController?
    
    override init(_ unit: HostedAudioUnit) {
        
        self.id = UUID().uuidString
        super.init(unit)
    }
    
    func applyFactoryPreset(_ presetName: String) {
        unit.applyFactoryPreset(presetName)
    }
    
    func presentView(_ handler: @escaping (NSView) -> ()) {
        
        if let viewController = self.viewController {
            
            handler(viewController.view)
            return
        }
        
        unit.auAudioUnit.requestViewController(completionHandler: {viewCon in
            
            if let theViewController = viewCon as? AUViewController {
                
                self.viewController = theViewController
                handler(theViewController.view)
            }
        })
    }
}
