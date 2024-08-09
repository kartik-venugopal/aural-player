//
//  WaveformRenderOperation.swift
//  Periphony: Spatial Audio Player
//  Copyright © Oli Larkin Plug-ins Ltd. 2022. All rights reserved.
//  Developed by Kartik Venugopal
//

import AVFoundation
import Accelerate
import AppKit

/// Operation used for rendering waveform images
final class WaveformRenderOperation: Operation {
    
    // MARK: State
    
    /// The audio context used to build the waveform
    let audioContext: WaveformAudioContext
    
    let sampleReceiver: SampleReceiver
    
    /// Size of waveform image to render
    let imageSize: CGSize
    
    /// Range of samples within audio asset to build waveform for
    let sampleRange: CountableRange<Int>
    
    ///
    /// Any operations spawned by this operation.
    ///
    /// **Notes**
    ///
    /// By keeping references to these operations in an
    /// instance member, they can be managed from
    /// anywhere in the class.
    ///
    var childOperations: [Operation] = []
    
    // -------------------------------------------------------------------------------------------------------------------

    // MARK: - NSOperation Overrides
    
    override var isAsynchronous: Bool {true}
    
    /// Backing value for ``isExecuting``.
    private var _isExecuting = false
    override var isExecuting: Bool {_isExecuting}
    
    /// Backing value for ``isFinished``.
    private var _isFinished = false
    override var isFinished: Bool {_isFinished}
    
    // -------------------------------------------------------------------------------------------------------------------
    
    // MARK: - Private state
    
    ///  Handler called when the rendering has completed. nil NSImage indicates that there was an error during processing.
    private let completionHandler: () -> ()
    
    /// Quality of service for the render operation.
    private static let qOS: DispatchQoS.QoSClass = .userInteractive
    
    // -------------------------------------------------------------------------------------------------------------------
    
    // MARK: Initialization
    
    init(audioContext: WaveformAudioContext, sampleReceiver: SampleReceiver, imageSize: CGSize,
         completionHandler: @escaping () -> ()) {
        
        self.audioContext = audioContext
        self.sampleReceiver = sampleReceiver
        self.imageSize = imageSize
        self.sampleRange = 0..<audioContext.totalSamples
        self.completionHandler = completionHandler
        
        super.init()
        
        self.completionBlock = {[weak self] in
            self?.completionHandler()
        }
    }
    
    // -------------------------------------------------------------------------------------------------------------------
    
    // MARK: Functions
    
    ///
    /// Initiates the render operation on a background thread.
    ///
    override func start() {
        
        // Do nothing if any of these flags is set.
        guard !isExecuting, !isFinished, !isCancelled else {return}
        
        // Update state for KVO.
        willChangeValue(forKey: "isExecuting")
        _isExecuting = true
        didChangeValue(forKey: "isExecuting")
        
        // Begin rendering on the global queue.
        DispatchQueue.global(qos: Self.qOS).async {
            self.render()
        }
    }
    
    ///
    /// Updates state once the operation has completed.
    ///
    /// - Parameter renderedImage:  The rendered image (will be *nil*
    ///                             if the render failed).
    ///
    private func finish() {
        
        // Do nothing if any of these flags is set.
        guard !isFinished, !isCancelled else {return}
        
        // Update state for KVO.
        // NOTE - ``completionHandler`` will be called automatically
        // by ``NSOperation`` after these values change.
        
        willChangeValue(forKey: "isExecuting")
        willChangeValue(forKey: "isFinished")
        _isExecuting = false
        _isFinished = true
        didChangeValue(forKey: "isExecuting")
        didChangeValue(forKey: "isFinished")
    }
    
    ///
    /// Actually initiates the render operation.
    ///
    private func render() {
        
        // Validate the render parameters (image size, sample range).
        
        guard
            !sampleRange.isEmpty,
            imageSize.width > 0, imageSize.height > 0
        else {
            finish()
            return
        }
        
        let targetSamples = Int(imageSize.width)
        
        // ----------------------------------------------------------------------------
        
        // Step 1 - Read samples from the audio file and perform downsampling
        // on them.
        
        if !isCancelled {
            _ = analyzeTrack(withRange: sampleRange, andDownsampleTo: targetSamples)
        }
            
        finish()
    }
    
    ///
    /// Delegates to an appropriate sample reading function depending on file format.
    ///
    func analyzeTrack(withRange slice: CountableRange<Int>, andDownsampleTo targetSamples: Int) -> WaveformRenderData? {
        
        guard !isCancelled else {return nil}
        
        var data: WaveformRenderData? = nil
        
        if audioContext.audioFile.isNativelySupported {
            
            let start = CFAbsoluteTimeGetCurrent()
            data = analyzeAudioFile(withRange: slice, andDownsampleTo: targetSamples)
            
            let end = CFAbsoluteTimeGetCurrent()
            print("Sliced track in: \(String(format: "%.3f", end - start)) secs")
            
        } else {
            data = analyzeFFmpegTrack(withRange: slice, andDownsampleTo: targetSamples)
        }
        
        return data
    }
}
