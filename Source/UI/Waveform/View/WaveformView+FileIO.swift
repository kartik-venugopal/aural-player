//
//  WaveformView+FileIO.swift
//  Aural-Waveform
//
//  Created by Kartik Venugopal on 08.08.24.
//

import Foundation

extension WaveformView {
    
    var audioFile: URL? {
        
        get {
            _audioFile
        }
        
        set(newFile) {
            
            if newFile == audioFile {return}
            
            self._audioFile = newFile
            
            resetState(resetProgress: true)
            analyzeAudioFile()
        }
    }
    
    func analyzeAudioFile() {
        
        guard let audioFile = self.audioFile else {return}
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            if let lookup = Self.lookUpCache(forFile: audioFile, matchingImageSize: self.waveformSize) {
                
                self.setCachedSamples(lookup.data.samples, forFile: audioFile)
                return
            }
            
            guard let decoder = self.createDecoder(forFile: audioFile) else {return}
            
            self.renderOp = WaveformRenderOperation(decoder: decoder,
                                                    sampleReceiver: self,
                                                    imageSize: self.waveformSize) {finishedOp in
                
                if finishedOp.isFinished && finishedOp.analysisSucceeded {
                    Self.addToCache(waveformData: self.samples, forAudioFile: audioFile, renderedForImageSize: finishedOp.imageSize)
                }
                
                if self.renderOp == finishedOp {
                    self.renderOp = nil
                }
            }
            
            self.renderOp?.start()
        }
    }
    
    private func createDecoder(forFile audioFile: URL) -> WaveformDecoderProtocol? {
       
        // Check the type of file to determine how to load information.
        
        if audioFile.isNativelySupported {
            return AVFWaveformDecoder(file: audioFile)
            
        } else if audioFile.isSupportedAudioFile {
            return try? FFmpegWaveformDecoder(for: audioFile)
        }
        
        return nil
    }
}
