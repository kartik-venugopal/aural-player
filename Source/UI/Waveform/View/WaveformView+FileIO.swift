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
            resetState()
            
            guard let audioFile = newFile else {return}
            
            if let lookup = lookUpCache(forFile: audioFile) {
                
                self.setSamples(lookup.data.samples)
                return
            }
            
            WaveformAudioContext.load(fromAudioFile: audioFile) {audioContext in
                
                DispatchQueue.main.async {
                    
                    guard self.audioFile == audioContext?.audioFile else { return }

                    guard let audioContext = audioContext else {
                        
                        NSLog("WaveformView failed to load URL: \(audioFile)")
                        return
                    }

                    self.renderOp = WaveformRenderOperation(audioContext: audioContext,
                                                            sampleReceiver: self,
                                                            imageSize: self.bounds.size) {
                        
                        self.cacheCurrentWaveform()
                        print("Done!")
                    }
                    
                    self.renderOp?.start()
                }
            }
            
        }
    }
}
