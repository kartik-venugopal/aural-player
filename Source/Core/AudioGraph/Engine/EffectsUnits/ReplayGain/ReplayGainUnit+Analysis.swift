//
// ReplayGainUnit+Analysis.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension ReplayGainUnit {
    
    func applyReplayGain(forTrack track: Track?) {
        
        guard let track else {
            
            noReplayGain()
            return
        }
        
        switch dataSource {
            
        case .metadataOrAnalysis:
            
            if let replayGain = track.replayGain, hasEnoughInfo(replayGain: replayGain) {
                
                // Has metadata
                self.replayGain = replayGain
                
            } else {
                
                // First reset replay gain (before analysis)
                self.replayGain = nil
                
                // Analyze
                analyze(track: track)
            }
            
        case .metadataOnly:
            self.replayGain = track.replayGain
            
        case .analysisOnly:
            analyze(track: track)
        }
    }
    
    func noReplayGain() {
        
        replayGain = nil
        self._isScanning.setFalse()
        replayGainScanner.cancelOngoingScan()
        Messenger.publish(.Effects.ReplayGainUnit.scanCompleted)
    }
    
    private func hasEnoughInfo(replayGain: ReplayGain) -> Bool {
        
        switch mode {
            
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
            
            strongSelf.replayGain = replayGain
            strongSelf._isScanning.setFalse()
            
            Messenger.publish(.Effects.ReplayGainUnit.scanCompleted)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            self._isScanning.setTrue()
            
            if self.mode == .preferAlbumGain, let albumName = track.album {
                
                let albumFiles = playQueue.tracks.filter {$0.album == albumName}.map {$0.file}
                
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
    
    func preTrackPlayback(_ notification: PreTrackPlaybackNotification) {
        
        if isActive {
            applyReplayGain(forTrack: notification.newTrack)
        }
    }
}
