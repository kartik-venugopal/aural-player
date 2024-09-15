//
//  ReplayGainUnitDelegate.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class ReplayGainUnitDelegate: EffectsUnitDelegate<ReplayGainUnit>, ReplayGainUnitDelegateProtocol {
    
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
        
        set {
            unit.mode = newValue
            applyReplayGain(forTrack: playbackInfoDelegate.playingTrack)
        }
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
    
    private(set) var scanStatus: String? = nil
    
    func applyReplayGain(forTrack track: Track?) {
        
        guard let theTrack = track else {
            
            unit.replayGain = nil
            self._isScanning.setFalse()
            replayGainScanner.cancelOngoingScan()
            Messenger.publish(.Effects.ReplayGainUnit.scanCompleted)
            
            return
        }
        
        switch unit.dataSource {
            
        case .metadataOrAnalysis:
            
            if let replayGain = theTrack.replayGain, hasEnoughInfo(replayGain: replayGain) {
                
                // Has metadata
                unit.replayGain = replayGain
                
            } else {
                
                // First reset replay gain (before analysis)
                unit.replayGain = nil
                
                // Analyze
                analyze(track: theTrack)
            }
            
        case .metadataOnly:
            unit.replayGain = theTrack.replayGain
            
        case .analysisOnly:
            analyze(track: theTrack)
        }
    }
    
    private func hasEnoughInfo(replayGain: ReplayGain) -> Bool {
        
        switch unit.mode {
            
        case .preferAlbumGain:
            return replayGain.albumGain != nil && (preventClipping ? replayGain.albumPeak != nil : true)
            
        case .preferTrackGain, .trackGainOnly:
            return replayGain.trackGain != nil && (preventClipping ? replayGain.trackPeak != nil : true)
        }
    }
    
    private func analyze(track: Track) {
        
        let file = track.file
        
        let completionHandler: ReplayGainScanCompletionHandler = {[weak self] (replayGain: ReplayGain?) in
            
            guard let strongSelf = self else {return}
            
            strongSelf.unit.replayGain = replayGain
            strongSelf._isScanning.setFalse()
            
            Messenger.publish(.Effects.ReplayGainUnit.scanCompleted)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            self._isScanning.setTrue()
            
            if self.unit.mode == .preferAlbumGain, let albumName = track.album {
                
                let albumFiles = playQueueDelegate.tracks.filter {$0.album == albumName}.map {$0.file}
                
                if albumFiles.count > 1 {
                    
                    self.scanStatus = "Analyzing album ..."
                    Messenger.publish(.Effects.ReplayGainUnit.scanInitiated)
                    
                    replayGainScanner.scanAlbum(named: albumName, withFiles: albumFiles, forFile: track.file, completionHandler)
                    return
                }
            }
            
            self.scanStatus = "Analyzing track ..."
            Messenger.publish(.Effects.ReplayGainUnit.scanInitiated)
            
            replayGainScanner.scanTrack(file: file, completionHandler)
        }
    }
}
