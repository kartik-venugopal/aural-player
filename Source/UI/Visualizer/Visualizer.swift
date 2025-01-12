//
//  Visualizer.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import AVFoundation

typealias VisualizerRenderCallback = () -> Void

///
/// Sets up render callbacks and obtains and analyzes rendered audio sample data for
/// visualization.
///
class Visualizer: AudioGraphRenderObserverProtocol, Destroyable {
    
    private var normalDeviceBufferSize: Int = 0
    
    private let renderCallback: VisualizerRenderCallback
    
    init(renderCallback: @escaping VisualizerRenderCallback) {
        self.renderCallback = renderCallback
    }
    
    func setUp() {
        
        normalDeviceBufferSize = audioGraphDelegate.outputDeviceBufferSize
        audioGraphDelegate.outputDeviceBufferSize = audioGraphDelegate.visualizationAnalysisBufferSize
        
        fft.setUp(sampleRate: Float(audioGraphDelegate.outputDeviceSampleRate),
                  bufferSize: audioGraphDelegate.outputDeviceBufferSize)
    }
    
    func destroy() {
        fft.destroy()
    }
    
    // MARK: Client (analysis) functions -------------------------
    
    func startAnalysis() {
        audioGraphDelegate.registerRenderObserver(self)
    }
    
    func pauseAnalysis() {
        audioGraphDelegate.pauseRenderObserver(self)
    }
    
    func resumeAnalysis() {
        audioGraphDelegate.resumeRenderObserver(self)
    }
    
    func stopAnalysis() {

        audioGraphDelegate.removeRenderObserver(self)
        audioGraphDelegate.outputDeviceBufferSize = normalDeviceBufferSize
    }
    
    // MARK: AudioGraphRenderObserverProtocol functions -------------------
    
    func rendered(audioBuffer: AudioBufferList) {
        
        fft.analyze(buffer: audioBuffer)
        renderCallback()
    }
    
    func deviceChanged(newDeviceBufferSize: Int, newDeviceSampleRate: Double) {
        
        normalDeviceBufferSize = newDeviceBufferSize
        
        if newDeviceBufferSize != audioGraphDelegate.visualizationAnalysisBufferSize {
            
            audioGraphDelegate.outputDeviceBufferSize = audioGraphDelegate.visualizationAnalysisBufferSize
            
            fft.setUp(sampleRate: Float(audioGraphDelegate.outputDeviceSampleRate),
                      bufferSize: audioGraphDelegate.outputDeviceBufferSize)
        }
    }
    
    // TODO
    func deviceSampleRateChanged(newSampleRate: Double) {
//        NSLog("**** Device SR changed: \(newSampleRate)")
    }
}
