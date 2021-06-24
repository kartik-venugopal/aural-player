//
//  FFmpegFrameBuffer.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation
import Accelerate

///
/// A temporary container that accumulates / buffers frames until the number of frames
/// is deemed large enough to schedule for playback.
///
class FFmpegFrameBuffer {
    
    ///
    /// An ordered list of buffered frames. The ordering is important as it reflects the order of
    /// the corresponding samples in the audio file from which they were read.
    ///
    var frames: [FFmpegFrame] = []
    
    ///
    /// The PCM format of the samples in this buffer.
    ///
    let audioFormat: FFmpegAudioFormat
    
    ///
    /// A counter that keeps track of how many samples have been accumulated in this buffer.
    /// i.e. the sum of the sample counts of each of the buffered frames.
    ///
    /// ```
    /// It is updated as individual frames are appended to this buffer.
    /// ```
    ///
    var sampleCount: Int32 = 0
    
    ///
    /// Computes the maximum of the sample counts of all the contained frames.
    ///
    /// ```
    /// This value is useful when allocating reusable memory space for
    /// a sample format conversion, i.e. space large enough to accomodate
    /// any of the frames contained in this buffer.
    /// ```
    ///
    var maxFrameSampleCount: Int32 {frames.map{$0.sampleCount}.max() ?? 0}
    
    ///
    /// Whether or not samples in this buffer require conversion before they can be fed into AVAudioEngine for playback.
    ///
    /// Will be true unless the sample format is 32-bit float non-interleaved (i.e. the standard Core Audio format).
    ///
    var needsFormatConversion: Bool {audioFormat.needsFormatConversion}
    
    ///
    /// A limit on the number of samples to be accumulated.
    ///
    /// ```
    /// It is set exactly once when this buffer is instantiated.
    /// ```
    ///
    let maxSampleCount: Int32
    
    init(audioFormat: FFmpegAudioFormat, maxSampleCount: Int32) {
    
        self.audioFormat = audioFormat
        self.maxSampleCount = maxSampleCount
    }
    
    ///
    /// Attempts to append a single frame to this buffer. Succeeds if this buffer can accommodate the
    /// samples of the new frame, limited by **maxSampleCount**.
    ///
    /// - Parameter frame: The new frame to append to this buffer.
    ///
    /// - returns: Whether or not the frame was successfully appended to the buffer.
    ///
    func appendFrame(_ frame: FFmpegFrame) -> Bool {

        // Check if the sample count of the new frame would cause this buffer to
        // exceed maxSampleCount.
        if self.sampleCount + frame.sampleCount <= maxSampleCount {
            
            // Update the sample count, and append the frame.
            self.sampleCount += frame.sampleCount
            frames.append(frame)
            
            return true
        }
        
        // Buffer cannot accommodate the new frame. It is "full".
        return false
    }
    
    ///
    /// Appends an array of "terminal" frames that constitute the last few frames in an audio stream.
    ///
    /// - Parameter frames: The terminal frames to append to this buffer.
    ///
    /// # Notes #
    ///
    /// Terminal frames are not subject to the **maxSampleCount** limit.
    ///
    /// So, unlike **appendFrame()**, this function will not reject the terminal frames ... they will always
    /// be appended to this buffer.
    ///
    func appendTerminalFrames(_ frames: [FFmpegFrame]) {
        
        for frame in frames {
            
            self.sampleCount += frame.sampleCount
            self.frames.append(frame)
        }
    }
    
    ///
    /// Copies this buffer's samples, as non-interleaved (aka planar) 32-bit floats, to a given (playable) audio buffer.
    ///
    /// - Parameter audioBuffer: The playable audio buffer that will hold the samples contained in this buffer.
    ///
    /// # Note #
    ///
    /// The caller of this function must first verify that this buffer's samples are indeed of the required (playable) standard
    /// Core Audio format. In other words, this function does not do any kind of sample format conversion. It copies
    /// the samples as is.
    ///
    func copySamples(to audioBuffer: AVAudioPCMBuffer) {
        
        // The audio buffer will always be filled to capacity.
        audioBuffer.frameLength = audioBuffer.frameCapacity
        
        // Get pointers to the audio buffer's internal Float data buffers.
        guard let audioBufferChannels = audioBuffer.floatChannelData else {return}
        
        let channelCount: Int = Int(audioFormat.channelCount)
        
        // Keeps track of how many samples have been copied over so far.
        // This will be used as an offset when performing each copy operation.
        var sampleCountSoFar: Int = 0
        
        for frame in frames {
            
            let intSampleCount: Int = Int(frame.sampleCount)
            let intFirstSampleIndex: Int = Int(frame.firstSampleIndex)
            
            for channelIndex in 0..<channelCount {
                
                // Get the pointers to the source and destination buffers for the copy operation.
                guard let srcBytesForChannel = frame.dataPointers[channelIndex] else {break}
                let destFloatsForChannel = audioBufferChannels[channelIndex]
                
                // Re-bind this frame's bytes to Float for the copy operation.
                srcBytesForChannel.withMemoryRebound(to: Float.self, capacity: intSampleCount) {
                    
                    (srcFloatsForChannel: UnsafeMutablePointer<Float>) in
                    
                    // Use Accelerate to perform the copy optimally, starting at the given offset.
                    cblas_scopy(frame.sampleCount, srcFloatsForChannel.advanced(by: intFirstSampleIndex), 1, destFloatsForChannel.advanced(by: sampleCountSoFar), 1)
                }
            }
            
            // Update the sample counter.
            sampleCountSoFar += intSampleCount
        }
    }
    
    /// Indicates whether or not this object has already been destroyed.
    private var destroyed: Bool = false
    
    ///
    /// Performs cleanup (deallocation of allocated memory space) when
    /// this object is about to be deinitialized or is no longer needed.
    ///
    func destroy() {
        
        // This check ensures that the deallocation happens
        // only once. Otherwise, a fatal error will be
        // thrown.
        if destroyed {return}
        
        // Destroy each of the individual frames.
        frames.forEach {$0.destroy()}
        
        destroyed = true
    }
    
    /// When this object is deinitialized, make sure that its allocated memory space is deallocated.
    deinit {
        destroy()
    }
}
