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
    let decoder: WaveformDecoderProtocol
    
    let sampleReceiver: SampleReceiver
    
    let targetSamples: AVAudioFrameCount
    
//    var childOperations: [Operation] = []
    
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
    
    init(decoder: WaveformDecoderProtocol, sampleReceiver: SampleReceiver, imageSize: CGSize,
         completionHandler: @escaping () -> ()) {
        
        self.decoder = decoder
        self.sampleReceiver = sampleReceiver
        self.targetSamples = AVAudioFrameCount(imageSize.width)
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
        
        if !isCancelled {
            
            let start = CFAbsoluteTimeGetCurrent()
            analyzeAudioFile(andDownsampleTo: targetSamples)
            let end = CFAbsoluteTimeGetCurrent()
            print("Analyzed track in: \(String(format: "%.3f", end - start)) secs")
        }
            
        finish()
    }
}
