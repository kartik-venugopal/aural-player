//
//  ReplayGainUnitDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

// TODO: Caching of ReplayGain scan data

class ReplayGainUnitDelegate: EffectsUnitDelegate<ReplayGainUnit>, ReplayGainUnitDelegateProtocol {
    
    var dataSource: ReplayGainDataSource {
        
        get {unit.dataSource}
        set {unit.dataSource = newValue}
    }
    
    var targetLoudness: ReplayGainTargetLoudness {
        
        get {unit.targetLoudness}
        set {unit.targetLoudness = newValue}
    }
    
    var maxPeakLevel: ReplayGainMaxPeakLevel {
        
        get {unit.maxPeakLevel}
        set {unit.maxPeakLevel = newValue}
    }
    
    var mode: ReplayGainMode {
        
        get {unit.mode}
        set {unit.mode = newValue}
    }
    
    var preAmp: Float {
        
        get {unit.preAmp}
        set {unit.preAmp = newValue}
    }
    
    var preventClipping: Bool {
        
        get {unit.preventClipping}
        set {unit.preventClipping = newValue}
    }
    
    func applyGain(_ replayGain: ReplayGain?) {
        unit.replayGain = replayGain
    }
    
    var appliedGain: Float {
        unit.appliedGain
    }
    
    var hasAppliedGain: Bool {
        unit.replayGain != nil
    }
    
    var effectiveGain: Float {
        unit.effectiveGain
    }
    
    var isScanning: Bool {_isScanning.value}
    private var _isScanning: AtomicBool = AtomicBool(value: false)
    
    func initiateScan(forFile file: URL) {
        
        do {
            
            let scanner = try ReplayGainScanner(file: file)
            
            _isScanning.setTrue()
            Messenger.publish(.Effects.ReplayGainUnit.scanInitiated)
            
            scanner.scan {[weak self] replayGain in
                
                guard let strongSelf = self else {return}
                
                strongSelf.unit.replayGain = replayGain
                strongSelf._isScanning.setFalse()
                
                Messenger.publish(.Effects.ReplayGainUnit.scanCompleted)
            }
            
        } catch {
            
            _isScanning.setFalse()
            print("Scan failed: \(error.localizedDescription)")
        }
    }
}
