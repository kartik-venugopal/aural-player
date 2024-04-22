//
//  HostedAudioUnitDelegate.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    
    var hasCustomView: Bool {unit.hasCustomView}
    
    var parameterValues: [AUParameterAddress: Float] {unit.parameterValues}
    var parameterTree: AUParameterTree? {unit.parameterTree}
    
    var presets: AudioUnitPresets {unit.presets}
    var supportsUserPresets: Bool {unit.supportsUserPresets}
    
    var factoryPresets: [AudioUnitFactoryPreset] {unit.factoryPresets}
    
    private var viewController: NSViewController?
    
    private var generatedView: NSView?
    
    override init(for unit: HostedAudioUnit) {
        
        self.id = UUID().uuidString
        super.init(for: unit)
    }
    
    func applyFactoryPreset(named presetName: String) {
        
        unit.applyFactoryPreset(named: presetName)
        (viewController as? AUControlViewController)?.refreshControls()
    }
    
    func presentView(_ handler: @escaping (NSView) -> Void) {
        
        if !hasCustomView {
            
            if let theGeneratedView = generatedView {
                handler(theGeneratedView)
            }
            
            let generatedView = generateView()
            self.generatedView = generatedView
            handler(generatedView)
            
            return
        }
        
        if let viewController = self.viewController {
            
            handler(viewController.view)
            return
        }
        
        unit.auAudioUnit.requestViewController(completionHandler: {controller in
            
            if let theViewController = controller {
                
                self.viewController = theViewController
                handler(theViewController.view)
            }
        })
    }
    
    private func generateView() -> NSView {
        
        let viewController = AUControlViewController()
        viewController.audioUnit = self
        self.viewController = viewController
        
        return viewController.view
    }
    
    func forceViewRedraw() {
        (viewController as? AUControlViewController)?.refreshControls()
    }
    
    func setValue(_ value: Float, forParameterWithAddress address: AUParameterAddress) {
        unit.setValue(value, forParameterWithAddress: address)
    }
}
