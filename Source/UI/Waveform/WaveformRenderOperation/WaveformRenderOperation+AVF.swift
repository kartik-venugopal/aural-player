//
//  WaveformRenderOperation+AVF.swift
//  Periphony: Spatial Audio Player
//  Copyright © Oli Larkin Plug-ins Ltd. 2022. All rights reserved.
//  Developed by Kartik Venugopal
//

import AVFoundation
import Accelerate

///
/// Part of ``WaveformRenderOperation`` that performs sample reading
/// and processing of AVFoundation files (WAV / CAF).
///
extension WaveformRenderOperation {
    
    // MARK: Constants
    
    /// Settings used when reading samples from a file using an ``AVAssetReader``.
    private static let readerOutputSettingsDict: [String : Any] = [
        
        AVFormatIDKey: Int(kAudioFormatLinearPCM),
        AVLinearPCMBitDepthKey: 16,
        AVLinearPCMIsBigEndianKey: false,
        AVLinearPCMIsFloatKey: false,
        AVLinearPCMIsNonInterleaved: false  // Interleaved
    ]
    
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
    func sliceAVFTrack(withRange slice: CountableRange<Int>, andDownsampleTo targetSamples: Int) -> WaveformRenderData? {
        
        print("Slicing track ... \(slice)")
        
        // MARK: Set up an ``AVAssetReader`` for sample reading.
        
        // Validate the method arguments and initialize an ``AVAssetReader``.
        guard
            !slice.isEmpty,
            targetSamples > 0,
            let avfFile = audioContext.avfFile,
            let reader = try? AVAssetReader(asset: avfFile.avfAsset)
        else {
            return nil
        }
        
        let assetTrack = avfFile.avfAssetTrack
        let channelCount = avfFile.channelCount
        let sampleRate: CMTimeScale = avfFile.sampleRate
        
        // Set time range, based on sample range and sample rate, for the read operation.
        reader.timeRange = CMTimeRange(start: CMTime(value: Int64(slice.lowerBound), timescale: sampleRate),
                                       duration: CMTime(value: Int64(slice.count), timescale: sampleRate))
        
        let readerOutput = AVAssetReaderTrackOutput(track: assetTrack, outputSettings: Self.readerOutputSettingsDict)
        readerOutput.alwaysCopiesSampleData = false
        reader.add(readerOutput)
        
        // ------------------------------------------------------------------------------------------
        
        // MARK: Compute parameters and allocate buffers for the sample reading / processing loop.
        
        ///
        /// Number of channels to be rendered.
        ///
        /// **Notes**
        ///
        /// If the file contains Ambisonics-encoded surround, we will render only the first channel.
        ///
        let outputChannelCount: Int = min(audioContext.channelCount, 2)
//        let outputChannelCount: Int = 1
        
        /// The results of the downsampling.
        var result: WaveformRenderData = WaveformRenderData(outputChannelCount: outputChannelCount)
        
        /// Number of samples read per pixel rendered.
        let samplesPerPixel = max(1, slice.count / targetSamples)
        
        /// Finite impulse response (FIR) filter for downsampling.
        let filter = [Float](repeating: 1.0 / Float(samplesPerPixel), count: samplesPerPixel)
        
        // ------------------------------------------------------------------------------------------
        
        // MARK: Allocate sample processing buffers.
        
        /// Float buffers that will hold samples in planar form during downsampling.
        var processingBuffers: [UnsafeMutablePointer<Float>] = (0..<outputChannelCount).map {_ in
            
            // Allocate a ``Float`` buffer for each rendered output channel.
            UnsafeMutablePointer<Float>.allocate(capacity: 1)
        }
        
        // Ensure that the buffers do not outlive the function, to
        // prevent a memory leak.
        defer {
            
            processingBuffers.forEach {
                $0.deallocate()
            }
        }
        
        var totalSamplesRead: Int64 = 0
        
        ///
        /// Number of ``Float`` values each planar sample buffer can store.
        ///
        /// **Notes**
        ///
        /// This capacity will be updated (i.e. increased) as needed over processing
        /// loop iterations.
        ///
        var processingBufferCapacity: Int = 0
        
        /// Number of samples each buffer currently contains.
        var processingBufferLength: Int = 0
        
        // ------------------------------------------------------------------------------------------
        
        // MARK: Read / process samples in a loop.
        
        // 16-bit samples
        reader.startReading()
        
        // Cancel reading if we exit early or if the operation is cancelled.
        defer {reader.cancelReading()}
        
        while reader.status == .reading {
            
            guard !isCancelled else {return nil}
            
            // ------------------------------------------------------------------------------------------
            
            // MARK: Read samples into a byte buffer.
            
            guard let readSampleBuffer = readerOutput.copyNextSampleBuffer(),
                  let readBuffer = CMSampleBufferGetDataBuffer(readSampleBuffer) else {
                break
            }
            
            // Append the read samples into our sample processing buffer.
            
            var readBufferLength = 0
            var readBufferPointer: UnsafeMutablePointer<Int8>?
            CMBlockBufferGetDataPointer(readBuffer, atOffset: 0, lengthAtOffsetOut: &readBufferLength,
                                        totalLengthOut: nil, dataPointerOut: &readBufferPointer)
            
            // Ensure that we have a pointer to the read buffer.
            guard let readBufferPointer = readBufferPointer else {return nil}
            
            // ------------------------------------------------------------------------------------------
            
            // MARK: Ensure that the processing buffers have enough space.
            
            let samplesRead: Int = readBufferLength / .sizeOfInt16
            let samplesReadPerChannel: Int = samplesRead / channelCount
            
            totalSamplesRead += Int64(samplesReadPerChannel)
            
            //
            // The maximum total number of samples we will store at any given time will equal
            // the number of samples required to render one pixel, plus the number of samples
            // read by the asset reader for our output channels.
            //
            let spaceRequired = samplesPerPixel + samplesReadPerChannel
            
            // Resize the interleaved sample processing buffer if required.
            if spaceRequired > processingBufferCapacity {
                
                processingBufferCapacity = spaceRequired
                let processingBufferLength_Int32 = Int32(processingBufferLength)
                
                for channel in 0..<outputChannelCount {
                    
                    let oldBuffer = processingBuffers[channel]
                    let newBuffer = UnsafeMutablePointer<Float>.allocate(capacity: spaceRequired)
                    
                    // In very rare cases, the sample buffer capacity will need to increase
                    // over loop iterations, and we will need to transfer samples
                    // over from the previously allocated sample buffer to the new
                    // larger one.
                    
                    if processingBufferLength > 0 {
                        
                        // Transfer samples from the old buffer to the newly allocated one.
                        cblas_scopy(processingBufferLength_Int32,
                                    oldBuffer, 1,
                                    newBuffer, 1)
                    }
                    
                    processingBuffers[channel] = newBuffer
                    
                    oldBuffer.deallocate()
                }
            }
            
            // ------------------------------------------------------------------------------------------
            
            // MARK: Convert the ``Int16`` samples read from the file to ``Float`` samples, only keeping samples for output channels.
            
            readBufferPointer.withMemoryRebound(to: Int16.self, capacity: samplesRead) {intSamples in
                
                /// Number of samples that need to be converted to ``Float`` (per output channel).
                let samplesReadPerChannel_vDSP_Length = vDSP_Length(samplesReadPerChannel)
                
                for channel in 0..<outputChannelCount {

                    // Convert ``Int16`` samples to ``Float``.
                    
                    vDSP_vflt16(intSamples.advanced(by: channel), channelCount,
                                processingBuffers[channel].advanced(by: processingBufferLength), 1,
                                samplesReadPerChannel_vDSP_Length)
                }
                
                // Update buffer length after the copy.
                processingBufferLength += samplesReadPerChannel
            }

            // We are done with ``readSampleBuffer``, so release it.
            CMSampleBufferInvalidate(readSampleBuffer)
            
            // ------------------------------------------------------------------------------------------

            // MARK: Compute parameters for downsampling.

            /// Number of output samples to be produced by the next downsampling iteration.
            let downSampledLength = processingBufferLength / samplesPerPixel

            /// Number of samples the next downsampling iteration will process (per output channel).
            let samplesToProcess = downSampledLength * samplesPerPixel
            
            // ------------------------------------------------------------------------------------------

            // MARK: Process a batch of samples (downsampling).

            guard samplesToProcess > 0 else {continue}

            processAVFSamples(from: &processingBuffers,
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

            processAVFSamples(from: &processingBuffers,
                              result: &result,
                              samplesToProcess: samplesToProcess,
                              outputChannelCount: outputChannelCount,
                              downSampledLength: downSampledLength,
                              samplesPerPixel: samplesPerPixel,
                              filter: filter)
        }
        
        // ------------------------------------------------------------------------------------------
        
        // MARK: Prepare and return the result.
        
        // if (reader.status == AVAssetReaderStatusFailed || reader.status == AVAssetReaderStatusUnknown)
        // Something went wrong. Handle it or do not, depending on if you can get above to work
        
        if reader.status == .completed {
            return result
            
        } else {
            NSLog("WaveformRenderOperation failed to read audio: \(String(describing: reader.error))")
            return nil
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
    func processAVFSamples(from planarSamplesBuffers: inout [UnsafeMutablePointer<Float>],
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
    }
}

var ctr: Int = 0
