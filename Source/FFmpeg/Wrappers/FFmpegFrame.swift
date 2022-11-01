//
//  FFmpegFrame.swift
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
/// Encapsulates an ffmpeg **AVFrame** struct that represents a single (decoded) frame,
/// i.e. audio data in its raw decoded / uncompressed form, post-decoding,
/// and provides convenient Swift-style access to its functions and member variables.
///
class FFmpegFrame {
 
    ///
    /// The encapsulated AVFrame object.
    ///
    var avFrame: AVFrame {pointer.pointee}
    
    ///
    /// A pointer to the encapsulated AVFrame object.
    ///
    private var pointer: UnsafeMutablePointer<AVFrame>!
    
    ///
    /// Describes the number and physical / spatial arrangement of the channels. (e.g. "5.1 surround" or "stereo")
    ///
    var channelLayout: UInt64 {avFrame.channel_layout}
    
    ///
    /// Number of channels of audio data.
    ///
    var channelCount: Int32 {avFrame.channels}
    
    lazy var intChannelCount: Int = Int(channelCount)

    ///
    /// PCM format of the samples.
    ///
    var sampleFormat: FFmpegSampleFormat
    
    ///
    /// Total number of samples in this frame.
    ///
    /// ```
    /// If frame truncation has occurred, this value will equal
    /// the (lesser) **truncatedSampleCount**. Otherwise, it will
    /// equal the sample count of the encapsulated AVFrame.
    /// ```
    ///
    /// # Note #
    ///
    /// See member **truncatedSampleCount** for an explanation of frame truncation.
    ///
    var sampleCount: Int32 {truncatedSampleCount ?? avFrame.nb_samples}
    
    lazy var intSampleCount: Int = Int(sampleCount)
    
    var actualSampleCount: Int32 {avFrame.nb_samples}
    
    ///
    /// The (lesser) number of samples to read, as a result of frame truncation. May be nil (if no truncation has occurred).
    /// For most samples, this value will be nil, i.e. most frames are not truncated.
    ///
    /// ```
    /// Frame truncation occurs when a frame has more samples
    /// than desired for scheduling or when seeking. So, only
    /// a subset of the frame's samples is actually used.
    ///
    /// Truncation can occur at either the beginning of the frame,
    /// via keepLastNSamples(), or at the end of the frame, via
    /// keepFirstNSamples().
    ///
    /// Example:
    ///
    /// Before truncation (has 1000 samples),
    /// sampleCount = 1000
    /// truncatedSampleCount = nil
    /// firstSampleIndex = 0
    ///
    /// Truncation at the beginning of the frame (keep the last 300 samples):
    /// keepLastNSamples(300)
    ///
    /// Result (Use only the last 300 samples of this frame, starting at index 700):
    /// sampleCount = 300
    /// truncatedSampleCount = 300
    /// firstSampleIndex = 700
    /// ```
    ///
    var truncatedSampleCount: Int32?
    
    ///
    /// Represents a starting offset to use when scheduling this frame's samples for playback.
    ///
    /// ```
    /// If frame truncation has occurred, i.e. through keepLastNSamples(),
    /// this value will represent the (non-zero) index of the first sample
    /// to be used. Otherwise, it will be 0.
    ///
    /// If truncation occurred at the end of the frame, i.e. when
    /// keepFirstNSamples() was called, this value will remain 0.
    /// ```
    ///
    /// # Note #
    ///
    /// See member **truncatedSampleCount** for an explanation of frame truncation.
    ///
    var firstSampleIndex: Int32
    
    ///
    /// Sample rate of the decoded data (i.e. number of samples per second or Hz).
    ///
    var sampleRate: Int32 {avFrame.sample_rate}
    
    ///
    /// A timestamp indicating this frame's position (order) within the parent audio stream,
    /// specified in stream time base units.
    ///
    /// ```
    /// This can be useful when using concurrency to decode multiple
    /// packets simultaneously. The received frames, in that case,
    /// would be in arbitrary order, and this timestamp can be used
    /// to sort them in the proper presentation order.
    /// ```
    ///
    var timestamp: Int64 {avFrame.best_effort_timestamp}
    
    ///
    /// Presentation timestamp (PTS) of this frame, specified in the source stream's time base units.
    ///
    /// ```
    /// For packets containing a single frame, this frame timestamp will
    /// match that of the corrsponding packet.
    /// ```
    ///
    var pts: Int64 {avFrame.pts}
    
    ///
    /// The frame's starting timestamp, in seconds.
    ///
    /// ```
    /// This value is useful when scheduling segment loops, for example.
    /// It can be directly compared to the loop's start/end time.
    ///
    /// It will be set by the decoder.
    /// ```
    ///
    var startTimestampSeconds: Double = -1
    
    ///
    /// The frame's ending timestamp, in seconds.
    ///
    /// ```
    /// This value is useful when scheduling segment loops, for example.
    /// It can be directly compared to the loop's start/end time.
    ///
    /// It will be set by the decoder.
    /// ```
    ///
    var endTimestampSeconds: Double = -1
    
    ///
    /// Pointers to the raw data (unsigned bytes) constituting this frame's samples.
    ///
    var dataPointers: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>! {avFrame.extended_data}
    
    ///
    /// Instantiates a Frame, reading an AVFrame from the given codec context, and sets its sample format.
    ///
    /// - Parameter codecCtx: The codec context (i.e. decoder) from which to receive the new frame.
    ///
    /// - Parameter sampleFormat: The format of the samples in this frame.
    ///
    init?(readingFrom codecCtx: UnsafeMutablePointer<AVCodecContext>, withSampleFormat sampleFormat: FFmpegSampleFormat) {
        
        // Allocate memory for the frame.
        self.pointer = av_frame_alloc()
        
        // Check if memory allocation was successful. Can't proceed otherwise.
        guard pointer != nil else {
            
            NSLog("Unable to allocate memory for frame.")
            return nil
        }
        
        // Receive the frame from the codec context.
        guard avcodec_receive_frame(codecCtx, pointer).isNonNegative else {return nil}
        
        self.sampleFormat = sampleFormat
        self.firstSampleIndex = 0
    }
    
    ///
    /// Updates the frame's sample count to the given value, so that
    /// only the given number of samples, from the beginning of the frame,
    /// will be used when scheduling this frame for playback.
    ///
    /// - Parameter sampleCount: The new effective sample count.
    ///
    /// # Note #
    ///
    /// See member **truncatedSampleCount** for an explanation of frame truncation.
    ///
    func keepFirstNSamples(sampleCount: Int32) {
        
        if sampleCount < self.actualSampleCount {

            firstSampleIndex = 0
            truncatedSampleCount = sampleCount
        }
    }
    
    ///
    /// Updates the frame's sample count to the given value, and updates the starting sample
    /// offset (**firstSampleIndex**) accordingly, so that only the given number of samples,
    /// from the end of the frame, will be used when scheduling this frame for playback.
    ///
    /// - Parameter sampleCount: The new effective sample count.
    ///
    /// # Note #
    ///
    /// See member **truncatedSampleCount** for an explanation of frame truncation.
    ///
    func keepLastNSamples(sampleCount: Int32) {
        
        if sampleCount < self.actualSampleCount {

            firstSampleIndex = self.actualSampleCount - sampleCount
            truncatedSampleCount = sampleCount
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
        
        // Free up the space allocated to this frame.
        av_frame_free(&pointer)
        
        destroyed = true
    }
    
    /// When this object is deinitialized, make sure that its allocated memory space is deallocated.
    deinit {
        destroy()
    }
}
