//
//  WaveformRenderOperation+FFmpeg.swift
//  Aural-Waveform
//
//  Created by Kartik Venugopal on 08.08.24.
//

import AVFoundation
import Accelerate
import Foundation

///
/// Part of ``WaveformRenderOperation`` that performs sample reading
/// and processing of FFmpeg files.
///
extension WaveformRenderOperation {

    // -------------------------------------------------------------------------------------------------------------------

    // MARK: Functions

    // -------------------------------------------------------------------------------------------------------------------

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
    func analyzeFFmpegTrack(withRange slice: CountableRange<Int>, andDownsampleTo targetSamples: Int) -> WaveformRenderData? {
        
        // Validate the method arguments.
        guard
            !slice.isEmpty,
            targetSamples > 0,
            let decoder = audioContext.ffmpegDecoder
        else {return nil}
        
        // ------------------------------------------------------------------------------------------

        // MARK: Compute parameters and allocate buffers for the sample reading / processing loop.

        let channelCount = decoder.channelCount
        
        ///
        /// Number of channels to be rendered.
        ///
        /// **Notes**
        ///
        /// If the file contains Ambisonics-encoded surround, we will render only the first channel.
        ///
        let outputChannelCount: Int = min(channelCount, 2)
        
        /// The results of the downsampling.
        var result: WaveformRenderData = WaveformRenderData(outputChannelCount: outputChannelCount)

        /// Number of samples read per pixel rendered.
        let samplesPerPixel = max(1, slice.count / targetSamples)

        /// Finite impulse response (FIR) filter for downsampling.
        let filter = [Float](repeating: 1.0 / Float(samplesPerPixel), count: samplesPerPixel)

        /// Number of samples read from the audio file in one processing loop iteration.
//        let chunkSize = computeChunkSize(samplesPerPixel: samplesPerPixel,
//                                         channelCount: channelCount, outputChannelCount: outputChannelCount)
        
        let chunkSize: Int = Int(Self.chunkSize)
        
        // ------------------------------------------------------------------------------------------

        // MARK: Allocate sample processing buffers.

        ///
        /// Number of ``Float`` values each planar sample buffer can store.
        ///
        /// **Notes**
        ///
        /// The capacity will be equal to the chunk size plus the number of
        /// samples for a single rendered pixel - this is the theoretical maximum number
        /// of samples these buffers will ever need to store.
        ///
        let planarSampleBufferCapacity: Int = chunkSize + samplesPerPixel
        
        /// Float buffers that will hold samples in planar form during downsampling.
        var processingBuffers: [UnsafeMutablePointer<Float>] = (0..<outputChannelCount).map {_ in
            
            // Allocate a ``Float`` buffer for each rendered output channel.
            UnsafeMutablePointer<Float>.allocate(capacity: planarSampleBufferCapacity)
        }
        
        // Ensure that the ``Float`` buffers do not outlive the function, to
        // prevent a memory leak.
        defer {processingBuffers.forEach {$0.deallocate()}}
        
        /// Number of samples each planar processing buffer currently contains.
        var processingBufferLength: Int = 0

        // ------------------------------------------------------------------------------------------

        // MARK: Initialize and configure concurrent ``Operation``s to read samples efficiently.

        /// Flag indicating whether the end of file (EOF) has been reached yet during sample reading.
        var eof: Bool = false

        /// The total number of samples to be read (per channel) from the audio file (equal to the count of the slice).
        let totalSamplesToRead: Int32 = Int32(slice.count)

        /// The total number of samples read (per channel) so far.
        var totalSamplesRead: Int32 = 0

        // ------------------------------------------------------------------------------------------

        // MARK: Read / process samples in a loop.

        while !eof, totalSamplesRead < totalSamplesToRead {

            // Check for operation cancellation at the beginning of each loop iteration.
            guard !isCancelled else {return nil}

            // ------------------------------------------------------------------------------------------

            // MARK: Read the samples.
            
            let samplesReadForChunk = decoder.decode(intoBuffer: &processingBuffers)

            // Determine whether or not we reached EOF.
            eof = decoder.eof || samplesReadForChunk <= 0

            // Update the sample read counter variable.
            totalSamplesRead += samplesReadForChunk
            
            // Update buffer length after the copy.
            processingBufferLength += Int(samplesReadForChunk)
            
            // ------------------------------------------------------------------------------------------

            // MARK: Compute parameters for downsampling.

            /// Number of output samples to be produced by the next downsampling iteration.
            let downSampledLength = processingBufferLength / samplesPerPixel

            /// Number of samples (per output channel) the next downsampling iteration will process.
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

            // Update the buffer's length and move (copy) the unprocessed samples to the beginning
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

            /// Number of samples processed per output channel.
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
        
        // ------------------------------------------------------------------------------------------

        // MARK: Prepare and return the result.

        // If we read enough samples or reached the end of the file, we succeeded.
        if eof || totalSamplesRead >= totalSamplesToRead {
            return result

        } else {
            return nil
        }
    }
}
