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
    
    static let chunkSize: AVAudioFrameCount = 44100 * 10
    
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
    func analyzeAudioFile(withRange slice: CountableRange<Int>, andDownsampleTo targetSamples: Int) -> WaveformRenderData? {
        
        print("Analyzing track ... \(slice)")
        
        // MARK: Set up an ``AVAssetReader`` for sample reading.
        
        // Validate the method arguments and initialize an ``AVAssetReader``.
        guard
            !slice.isEmpty,
            targetSamples > 0,
            let avfFile = audioContext.avfFile
        else {
            return nil
        }
        
        let audioFile = avfFile.audioFile
        let channelCount = avfFile.channelCount
        let sampleRate: CMTimeScale = avfFile.sampleRate
        
        ///
        /// Number of channels to be rendered.
        ///
        /// **Notes**
        ///
        /// If the file contains Ambisonics-encoded surround, we will render only the first channel.
        ///
        let outputChannelCount: Int = min(channelCount, 2)
        
        var pcmBufferLength: Int = 0
        let pcmBufferCapacity = Self.chunkSize
        
        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: pcmBufferCapacity) else {return nil}
        
        // ------------------------------------------------------------------------------------------
        
        // MARK: Compute parameters and allocate buffers for the sample reading / processing loop.
        
        /// The results of the downsampling.
        var result: WaveformRenderData = WaveformRenderData(outputChannelCount: outputChannelCount)
        
        /// Number of samples read per pixel rendered.
        let samplesPerPixel = max(1, slice.count / targetSamples)
        
        /// Finite impulse response (FIR) filter for downsampling.
        let filter = [Float](repeating: 1.0 / Float(samplesPerPixel), count: samplesPerPixel)
        
        // ------------------------------------------------------------------------------------------
        
        // MARK: Allocate sample processing buffers.
        
        ///
        /// Number of ``Float`` values each planar sample buffer can store.
        ///
        /// **Notes**
        ///
        /// This capacity will be updated (i.e. increased) as needed over processing
        /// loop iterations.
        ///
        let processingBufferCapacity: Int = samplesPerPixel + Int(pcmBufferCapacity)
        
        /// Number of samples each buffer currently contains.
        var processingBufferLength: Int = 0
        
        /// Float buffers that will hold samples in planar form during downsampling.
        var processingBuffers: [UnsafeMutablePointer<Float>] = (0..<outputChannelCount).map {_ in
            
            // Allocate a ``Float`` buffer for each rendered output channel.
            UnsafeMutablePointer<Float>.allocate(capacity: processingBufferCapacity)
        }
        
        // Ensure that the buffers do not outlive the function, to
        // prevent a memory leak.
        defer {
            
            processingBuffers.forEach {
                $0.deallocate()
            }
        }
        
        // ------------------------------------------------------------------------------------------
        
        /// The total number of samples to be read (per channel) from the audio file (equal to the count of the slice).
        let totalSamplesToRead: Int32 = Int32(slice.count)

        /// The total number of samples read (per channel) so far.
        var totalSamplesRead: Int32 = 0
        
        // MARK: Read / process samples in a loop.
        var loops: Int = 0
        
        while audioFile.framePosition < avfFile.totalSamples {
            
            guard !isCancelled else {return nil}
            
            // ------------------------------------------------------------------------------------------
            
            // MARK: Read samples into the PCM buffer.
            
            do {
                
                try audioFile.read(into: pcmBuffer)
                loops += 1
                pcmBufferLength = Int(pcmBuffer.frameLength)
                totalSamplesRead += Int32(pcmBuffer.frameLength)
                
            } catch {
                print("IO Error: \(error)")
            }
            
            // ------------------------------------------------------------------------------------------
            
            // MARK: Copy over samples from PCM buffer into processing buffers
            
            self.copy(samplesIn: pcmBuffer, to: &processingBuffers, offset: processingBufferLength, outputChannelCount: outputChannelCount)
            processingBufferLength += pcmBufferLength
            
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
                              result: &result,
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
            
            for channel in 0..<outputChannelCount {
                
                cblas_scopy(unprocessedSampleCount,
                            processingBuffers[channel].advanced(by: samplesToProcess), 1,
                            processingBuffers[channel], 1)
            }
        }
        
        // ------------------------------------------------------------------------------------------
        
        // MARK: Process the final batch (remainder) of samples.
        // Process the remaining samples that did not fit into samplesPerPixel at the end.
        
        /// Number of samples the next downsampling iteration will process.
        let samplesToProcess = processingBufferLength
        
        if samplesToProcess > 0 {
            
            guard !isCancelled else {return nil}
            
            /// We will render only one more pixel.
            let downSampledLength = 1
            
            /// Number of samples processed per rendered pixel.
            let samplesPerPixel = samplesToProcess
            
            /// Finite impulse response (FIR) filter for downsampling.
            let filter = [Float](repeating: 1.0 / Float(samplesPerPixel), count: samplesPerPixel)
            
            processAudioFileSamples(from: &processingBuffers,
                              result: &result,
                              samplesToProcess: samplesToProcess,
                              outputChannelCount: outputChannelCount,
                              downSampledLength: downSampledLength,
                              samplesPerPixel: samplesPerPixel,
                              filter: filter)
        }
        
//            print("\(totalSamplesRead) read, total: \(totalSamplesToRead)")
            print("Processed: \(sp), in \(loops) loops")
        
        // ------------------------------------------------------------------------------------------
        
        // MARK: Prepare and return the result.
        return result
    }
    
    private func copy(samplesIn pcmBuffer: AVAudioPCMBuffer, to processingBuffers: inout [UnsafeMutablePointer<Float>], offset: Int, outputChannelCount: Int) {
        
        guard let srcPointers = pcmBuffer.floatChannelData else {return}
        
        let sampleCount = Int32(pcmBuffer.frameLength)
        
        // NOTE - The following copy operation assumes a non-interleaved output format (i.e. the standard Core Audio format).
        
        // Iterate through all the channels.
        for channelIndex in 0..<outputChannelCount {
            
            // Use Accelerate to perform the copy optimally, starting at the given offset.
            cblas_scopy(sampleCount,
                        srcPointers[channelIndex], 1,
                        processingBuffers[channelIndex].advanced(by: offset), 1)
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
    func processAudioFileSamples(from planarSamplesBuffers: inout [UnsafeMutablePointer<Float>],
                           result: inout WaveformRenderData,
                           samplesToProcess: Int,
                           outputChannelCount: Int,
                           downSampledLength: Int,
                           samplesPerPixel: Int,
                           filter: [Float]) {
        
        let sampleCount = vDSP_Length(samplesToProcess)
        var downSampledData = [Float](repeating: 0.0, count: downSampledLength)
        
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
            result.appendData(downSampledData, forChannel: channel)
        }
        
        sampleReceiver.setSamples(result.inSamples)
        sp += Int32(samplesToProcess)
    }
    
    ///
    /// Converts power / amplitude samples from a ``Float`` buffer to clipped (logarithmic) decibel values.
    ///
    func process(normalizedSamples: UnsafeMutablePointer<Float>, count: Int) {
        
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
