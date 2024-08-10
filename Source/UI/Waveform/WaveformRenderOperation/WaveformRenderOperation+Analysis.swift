//
//  WaveformRenderOperation+AudioFile.swift
//  Aural-Waveform
//
//  Created by Kartik Venugopal on 08.08.24.
//

import AVFoundation
import Accelerate

///
/// Part of ``WaveformRenderOperation`` that performs sample reading
/// and processing of AVFoundation files (WAV / CAF).
///
extension WaveformRenderOperation {
    
    /// Scalar to convert samples in the range [-1, 1] to samples in the range [-32768, 32767]
    static let vsMulScalar: [Float] = [32768]
    
    // MARK: Sample reading
    
    ///
    /// Reads the asset (audio file) and creates a lower resolution set of samples by downsampling.
    ///
    /// - Parameter slice:                  The range of PCM samples to be read from within the audio file.
    ///
    /// - Parameter andDownsampleTo:        The number of target samples to be produced by downsampling the samples
    ///                                     read from the audio  file.
    ///
    /// - Returns:                          An object containing all the info necessary to render a waveform image for the given data set.
    ///
    func analyzeAudioFile(andDownsampleTo targetSamples: AVAudioFrameCount) {
        
        // MARK: Set up an ``AVAssetReader`` for sample reading.
        
        // Validate the method arguments and initialize an ``AVAssetReader``.
        guard targetSamples > 0 else {return}
        
        let channelCount = decoder.channelCount
        let outputChannelCount: AVAudioChannelCount = min(channelCount, 2)
        
        // ------------------------------------------------------------------------------------------
        
        // MARK: Compute parameters and allocate buffers for the sample reading / processing loop.
        
        /// The results of the downsampling.
        var renderData: WaveformRenderData = WaveformRenderData(outputChannelCount: outputChannelCount)
        
        /// Number of samples read per pixel rendered.
        let samplesPerPixel: AVAudioFrameCount = AVAudioFrameCount(max(1, decoder.totalSamples / AVAudioFramePosition(targetSamples)))
        
        /// Finite impulse response (FIR) filter for downsampling.
        let filter = [Float](repeating: 1.0 / Float(samplesPerPixel), count: Int(samplesPerPixel))
        
        // ------------------------------------------------------------------------------------------
        
        // MARK: Allocate sample processing buffers.
        
        let processingBufferCapacity: Int = Int(samplesPerPixel + waveformDecodingChunkSize)
        
        /// Number of samples each buffer currently contains.
        var processingBufferLength: AVAudioFrameCount = 0
        
        /// Float buffers that will hold samples in planar form during downsampling.
        var processingBuffers: Float2DBuffer = (0..<outputChannelCount).map {_ in
            
            // Allocate a ``Float`` buffer for each rendered output channel.
            FloatPointer.allocate(capacity: processingBufferCapacity)
        }
        
        // Ensure that the buffers do not outlive the function, to
        // prevent a memory leak.
        defer {
            
            processingBuffers.forEach {
                $0.deallocate()
            }
        }
        
        // ------------------------------------------------------------------------------------------
        
        // MARK: Read / process samples in a loop.
        var loops: Int = 0
        
        while !decoder.reachedEOF {
            
            guard !isCancelled else {return}
            
            // ------------------------------------------------------------------------------------------
            
            // MARK: Read samples into the PCM buffer.
            
            do {
                
                processingBufferLength += try decoder.decode(intoBuffer: &processingBuffers, 
                                                             currentBufferLength: processingBufferLength)
                loops += 1
                
            } catch {
                print("IO Error: \(error)")
            }
            
            // ------------------------------------------------------------------------------------------
            
            // MARK: Compute parameters for downsampling.
            
            /// Number of output samples to be produced by the next downsampling iteration.
            let downSampledLength = processingBufferLength / samplesPerPixel
            
            /// Number of samples the next downsampling iteration will process (per output channel).
            let samplesToProcess = downSampledLength * samplesPerPixel
            
            // ------------------------------------------------------------------------------------------
            
            // MARK: Process a batch of samples (downsampling).
            
            guard samplesToProcess > 0 else {continue}
            
            processAudioFileSamples(from: &processingBuffers,
                              renderData: &renderData,
                              samplesToProcess: samplesToProcess,
                              outputChannelCount: outputChannelCount,
                              downSampledLength: downSampledLength,
                              samplesPerPixel: samplesPerPixel,
                              filter: filter)
            
            // ------------------------------------------------------------------------------------------
            
            // MARK: Post-processing (update state).
            
            // Copy unprocessed samples to the beginning of the sample buffer, so that
            // they will be the first samples processed by the next loop iteration.
            
            /// Total number of samples left unprocessed (remainder) after the most recent downsampling iteration.
            let unprocessedSampleCount = Int32(processingBufferLength - samplesToProcess)
            
            // Update the buffer's length and move the unprocessed samples to the beginning
            // of the buffer for the next processing loop iteration.
            processingBufferLength -= samplesToProcess
            
            let intSamplesToProcess = Int(samplesToProcess)
            
            for channel in 0..<Int(outputChannelCount) {
                
                cblas_scopy(unprocessedSampleCount,
                            processingBuffers[channel].advanced(by: intSamplesToProcess), 1,
                            processingBuffers[channel], 1)
            }
        }
        
        // ------------------------------------------------------------------------------------------
        
        // MARK: Process the final batch (remainder) of samples.
        // Process the remaining samples that did not fit into samplesPerPixel at the end.
        
        /// Number of samples the next downsampling iteration will process.
        let samplesToProcess = processingBufferLength
        
        if samplesToProcess > 0 {
            
            guard !isCancelled else {return}
            
            /// We will render only one more pixel.
            let downSampledLength = AVAudioFrameCount(1)
            
            /// Number of samples processed per rendered pixel.
            let samplesPerPixel = samplesToProcess
            
            /// Finite impulse response (FIR) filter for downsampling.
            let filter = [Float](repeating: 1.0 / Float(samplesPerPixel), count: Int(samplesPerPixel))
            
            processAudioFileSamples(from: &processingBuffers,
                              renderData: &renderData,
                              samplesToProcess: samplesToProcess,
                              outputChannelCount: outputChannelCount,
                              downSampledLength: downSampledLength,
                              samplesPerPixel: samplesPerPixel,
                              filter: filter)
        }
    }
    
    // -------------------------------------------------------------------------------------------------------------------

    ///
    /// Downsamples a batch of PCM samples, and stores the results in the given result object, using the given parameters.
    ///
    /// - Parameter from:                           Input data buffers containing ``Float`` samples in a planar representation.
    ///
    /// - Parameter result:                         An object that accumulates result data.
    ///
    /// - Parameter samplesToProcess:               The number of samples to process (per output channel).
    ///
    /// - Parameter outputChannelCount:             The number of audio channels for which waveform data is to be processed.
    ///
    /// - Parameter downSampledLength:              The number of samples of output data to produce by downsampling.
    ///
    /// - Parameter samplesPerPixel:                The number of samples processed per rendered pixel.
    ///                                             Used as a "stride" when downsampling.
    ///
    /// - Parameter filter:                         Finite impulse response (FIR) filter for downsampling.
    ///
    func processAudioFileSamples(from planarSamplesBuffers: inout Float2DBuffer,
                           renderData: inout WaveformRenderData,
                           samplesToProcess: AVAudioFrameCount,
                           outputChannelCount: AVAudioChannelCount,
                           downSampledLength: AVAudioFrameCount,
                           samplesPerPixel: AVAudioFrameCount,
                           filter: [Float]) {
        
        let sampleCount = vDSP_Length(samplesToProcess)
        var downSampledData = [Float](repeating: 0.0, count: Int(downSampledLength))
        
        // Convert the parameters to the required types for Accelerate.
        
        let samplesPerPixel_vDSP_Stride = vDSP_Stride(samplesPerPixel)
        let downSampledLength_vDSP_Length = vDSP_Length(downSampledLength)
        let samplesPerPixel_vDSP_Length = vDSP_Length(samplesPerPixel)
        
        // Iterate through the planar buffers containing samples for the output channels.

        for (channel, planarBuffer) in planarSamplesBuffers.enumerated() {
            
            // ------------------------------------------------------------------------------------------
            
            // MARK: Scale the samples (in place).
            
            // Multiply each of the float values with a scalar so that they
            // fit into the range of Int16 sample values.
            
            vDSP_vsmul(planarBuffer, 1, Self.vsMulScalar, planarBuffer, 1, sampleCount)
            
            // ------------------------------------------------------------------------------------------
            
            // MARK: Compute absolute values (in place) to get amplitude.
            
            vDSP_vabs(planarBuffer, 1, planarBuffer, 1, sampleCount)
            
            // ------------------------------------------------------------------------------------------
            
            // MARK: Let waveform options further process the samples (in place).
            
            process(normalizedSamples: planarBuffer, count: samplesToProcess)
            
            // ------------------------------------------------------------------------------------------
            
            // MARK: Downsample and average the samples.
            
            vDSP_desamp(planarBuffer,
                        samplesPerPixel_vDSP_Stride,
                        filter, &downSampledData,
                        downSampledLength_vDSP_Length,
                        samplesPerPixel_vDSP_Length)
            
            // Append the new data to the existing result data.
            renderData.appendData(downSampledData, forChannel: channel)
        }
        
        sampleReceiver.setSamples(renderData.samples)
        sp += Int32(samplesToProcess)
    }
    
    ///
    /// Converts power / amplitude samples from a ``Float`` buffer to clipped (logarithmic) decibel values.
    ///
    func process(normalizedSamples: FloatPointer, count: AVAudioFrameCount) {
        
        // Convert samples to a log scale.
        
        //            var zero: Float = 32768.0
        var zero: Float = 65536
        let vDSP_Length_count = vDSP_Length(count)
        
        vDSP_vdbcon(normalizedSamples, 1, &zero, normalizedSamples, 1, vDSP_Length_count, 1)
        
        // Clip to [noiseFloor, 0].
        
        var ceil: Float = 0.0
        var noiseFloorFloat = Float(WaveformView.noiseFloor)
        vDSP_vclip(normalizedSamples, 1, &noiseFloorFloat, &ceil, normalizedSamples, 1, vDSP_Length_count)
    }
}

var sp: Int32 = 0
