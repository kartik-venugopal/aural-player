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
        
        normalDeviceBufferSize = audioGraph.outputDeviceBufferSize
        audioGraph.setUpForVisualizationAnalysis()
        
        fft.setUp(sampleRate: Float(audioGraph.outputDeviceSampleRate),
                  bufferSize: audioGraph.outputDeviceBufferSize)
    }
    
    func destroy() {
        fft.destroy()
    }
    
    // MARK: Client (analysis) functions -------------------------
    
    func startAnalysis() {
        audioGraph.registerRenderObserver(self)
    }
    
    func pauseAnalysis() {
        audioGraph.pauseRenderObserver(self)
    }
    
    func resumeAnalysis() {
        audioGraph.resumeRenderObserver(self)
    }
    
    func stopAnalysis() {

        audioGraph.removeRenderObserver(self)
        audioGraph.outputDeviceBufferSize = normalDeviceBufferSize
    }
    
    // MARK: AudioGraphRenderObserverProtocol functions -------------------
    
    func rendered(audioBuffer: AudioBufferList) {
        
        fft.analyze(buffer: audioBuffer)
        renderCallback()
    }
    
    func deviceChanged(newDeviceBufferSize: Int, newDeviceSampleRate: Double) {
        
        normalDeviceBufferSize = newDeviceBufferSize
        
        if !audioGraph.isSetUpForVisualizationAnalysis {
            
            audioGraph.setUpForVisualizationAnalysis()
            
            fft.setUp(sampleRate: Float(audioGraph.outputDeviceSampleRate),
                      bufferSize: audioGraph.outputDeviceBufferSize)
        }
    }
    
    // TODO
    func deviceSampleRateChanged(newSampleRate: Double) {
//        NSLog("**** Device SR changed: \(newSampleRate)")
    }
}
