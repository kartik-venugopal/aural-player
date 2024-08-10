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
            
            if newFile == audioFile {
                
                print("SAME FILE, doing nothing ...")
                return
            }
            
            self._audioFile = newFile
            
            resetState()
            analyzeAudioFile()
        }
    }
    
    func analyzeAudioFile() {
        
        guard let audioFile = self.audioFile else {return}
        
        if let lookup = lookUpCache(forFile: audioFile) {
            
            self.setSamples(lookup.data.samples)
            return
        }
        
        guard let decoder = createDecoder() else {return}
            
        DispatchQueue.global(qos: .userInteractive).async {
            
            self.renderOp = WaveformRenderOperation(decoder: decoder,
                                                    sampleReceiver: self,
                                                    imageSize: self.waveformSize) {
                
                self.cacheCurrentWaveform()
                print("Done!")
            }
            
            self.renderOp?.start()
        }
    }
    
    private func createDecoder() -> WaveformDecoderProtocol? {
       
        // Check the type of file to determine how to load information.
        guard let audioFile = self.audioFile else {return nil}
        
        if audioFile.isNativelySupported {
            return AVFWaveformDecoder(file: audioFile)
            
        } else if audioFile.isSupportedAudioFile {
            return try? FFmpegWaveformDecoder(for: audioFile)
        }
        
        return nil
    }
}
