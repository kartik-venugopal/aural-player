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

class ReplayGainUnitDelegate: EffectsUnitDelegate<ReplayGainUnit>, ReplayGainUnitDelegateProtocol {
    
    static let cache: ConcurrentMap<URL, EBUR128TrackAnalysisResult> = ConcurrentMap()
    
    var dataSource: ReplayGainDataSource {
        
        get {unit.dataSource}
        
        set {
            unit.dataSource = newValue
            applyReplayGain(forTrack: playbackInfoDelegate.playingTrack)
        }
    }
    
    var maxPeakLevel: ReplayGainMaxPeakLevel {
        
        get {unit.maxPeakLevel}
        set {unit.maxPeakLevel = newValue}
    }
    
    var mode: ReplayGainMode {
        
        get {unit.mode}
        
        // TODO: When the mode changes, if effective dataSource == .analysis and
        // changing from album gain to track gain, need to perform a scan
        
        // TODO: If dataSource == analysis and new mode is albumGain, perform an album scan
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
    
    var appliedGain: Float? {
        unit.appliedGain
    }
    
    var appliedGainType: ReplayGainType? {
        unit.appliedGainType
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
                
            } else {
                
                // First reset replay gain (before analysis)
                unit.replayGain = nil
                
                // Analyze
                analyze(file: theTrack.file)
            }
            
        case .metadataOnly:
            unit.replayGain = theTrack.replayGain
            
        case .analysisOnly:
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
            Messenger.publish(.Effects.ReplayGainUnit.scanCompleted)
        }
    }
}
