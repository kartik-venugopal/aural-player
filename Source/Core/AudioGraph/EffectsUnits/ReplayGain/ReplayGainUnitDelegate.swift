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
    
    static let cache: ConcurrentMap<URL, EBUR128AnalysisResult> = ConcurrentMap()
    
    var dataSource: ReplayGainDataSource {
        
        get {unit.dataSource}
        set {unit.dataSource = newValue}
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
    
    func applyReplayGain(forTrack track: Track?) {
        
        guard let theTrack = track else {
            
            unit.replayGain = nil
            replayGainScanner.cancelOngoingScan()
            Messenger.publish(.Effects.ReplayGainUnit.scanCompleted)
            
            return
        }
        
        switch unit.dataSource {
            
        case .metadataOrAnalysis:
            
            if let replayGain = theTrack.replayGain {
                
                // Has metadata
                unit.replayGain = replayGain
                print("Found RG metadata: \(replayGain.trackGain ?? -100) for \(theTrack)")
                
            } else {
                
                // First reset replay gain (before analysis)
                unit.replayGain = nil
                
                // Analyze
                analyze(file: theTrack.file)
                print("No RG metadata for \(theTrack), analyzing ...")
            }
            
        case .metadataOnly:
            
            print("Applying RG metadata: \(theTrack.replayGain?.trackGain ?? -100) for \(theTrack)")
            unit.replayGain = theTrack.replayGain
            
        case .analysisOnly:
            
            print("Analyzing \(theTrack)")
            analyze(file: theTrack.file)
        }
    }
    
    private func analyze(file: URL) {
        
        do {
            
            _isScanning.setTrue()
            Messenger.publish(.Effects.ReplayGainUnit.scanInitiated)
            
            try replayGainScanner.scan(forFile: file) {[weak self] (replayGain: ReplayGain?) in
                
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
