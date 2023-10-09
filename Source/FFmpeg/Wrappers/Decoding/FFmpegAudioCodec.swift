//
//  FFmpegAudioCodec.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates an ffmpeg audio codec that decodes audio data packets into raw (PCM) frames.
///
class FFmpegAudioCodec: FFmpegCodec {
    
    ///
    /// Constant value to use as the number of parallel threads to use when decoding.
    ///
    /// This should equal the number of physical CPU cores in the system.
    ///
    static let threadCount: Int32 = Int32(max(2, System.physicalCores / 2))
    
    ///
    /// The type of multithreading used by **FFmpeg** when decoding.
    ///
    /// *FF_THREAD_SLICE* means decode multiple segments
    /// or "slices" of a frame concurrently.
    ///
    static let threadType: Int32 = FF_THREAD_SLICE
    
    ///
    /// Average bit rate of the encoded data.
    ///
    var bitRate: Int64 {params.bitRate}
    
    ///
    /// Sample rate of the encoded data (i.e. number of samples per second or Hz).
    ///
    var sampleRate: Int32 {params.sampleRate}
    
    ///
    /// PCM format of the samples.
    ///
    var sampleFormat: FFmpegSampleFormat = FFmpegSampleFormat(encapsulating: AVSampleFormat(0))
    
    ///
    /// Number of channels of audio data.
    ///
    var channelCount: Int32 = 0
    
    ///
    /// Describes the number and physical / spatial arrangement of the channels. (e.g. "5.1 surround" or "stereo")
    ///
    var channelLayout: FFmpegChannelLayout = .zero
    
    ///
    /// Instantiates an AudioCodec object, given a pointer to its parameters.
    ///
    /// - Parameter paramsPointer: A pointer to parameters for the associated AVCodec object.
    ///
    override init(fromParameters paramsPointer: UnsafeMutablePointer<AVCodecParameters>) throws {
        
        try super.init(fromParameters: paramsPointer)
        
        self.sampleFormat = FFmpegSampleFormat(encapsulating: context.sampleFormat)
        self.channelCount = params.channels
        
        // Correct channel layout if necessary.
        // NOTE - This is necessary for some files like WAV files that don't specify a channel layout.
        self.channelLayout = FFmpegChannelLayout(id: context.channelLayout, channelCount: context.channels)
        
        // Use multithreading to speed up decoding.
        self.context.threadCount = Self.threadCount
        self.context.threadType = Self.threadType
    }
    
    override func open() throws {
        
        try super.open()
        
        // The channel layout / sample format may change as a result of opening the codec.
        // Some streams may contain the wrong header information. So, recompute these
        // values after opening the codec.
        
        self.channelLayout = FFmpegChannelLayout(id: context.channelLayout, channelCount: context.channels)
        self.sampleFormat = FFmpegSampleFormat(encapsulating: context.sampleFormat)
    }
    
    ///
    /// Decodes a single packet and produces (potentially) multiple frames.
    ///
    /// - Parameter packet: The packet that needs to be decoded.
    ///
    /// - returns: An ordered list of frames.
    ///
    /// - throws: **DecoderError** if an error occurs during decoding.
    ///
    func decode(packet: FFmpegPacket) throws -> FFmpegPacketFrames {
        
        // Send the packet to the decoder for decoding.
        let resultCode: ResultCode = context.sendPacket(packet)
        
        // If the packet send failed, log a message and throw an error.
        if resultCode.isNegative {
            
            NSLog("Codec failed to send packet. Error: \(resultCode) \(resultCode.errorDescription))")
            throw DecoderError(resultCode)
        }
        
        // Collect the received frames in an array.
        let packetFrames: FFmpegPacketFrames = FFmpegPacketFrames()
        
        // Keep receiving decoded frames while no errors are encountered
        while let frame = context.receiveFrame() {
            packetFrames.appendFrame(frame)
        }
        
        return packetFrames
    }
    
    ///
    /// Decode the given packet and drop (ignore) the received frames.
    ///
    /// ```
    /// This is useful after performing a seek, when the
    /// resulting seek position is less than (before) the target position.
    /// In such a case, it may be necessary to drop a few packets
    /// till the desired seek position is reached.
    /// ```
    ///
    func decodeAndDrop(packet: FFmpegPacket) {
        
        // Send the packet to the decoder for decoding.
        var resultCode: ResultCode = context.sendPacket(packet)
        if resultCode.isNegative {return}
        
        context.receiveAndDropAllFrames()
    }
    
    ///
    /// Drains the codec of all internally buffered frames.
    ///
    /// Call this function after reaching EOF within a stream.
    ///
    /// - returns: All remaining (buffered) frames, ordered.
    ///
    /// - throws: **DecoderError** if an error occurs while draining the codec.
    ///
    func drain() throws -> FFmpegPacketFrames {
        
        // Send the "flush packet" to the decoder
        let resultCode: Int32 = context.sendFlushPacket()
        
        if resultCode.isNonZero {
            
            NSLog("Codec failed to send packet while draining. Error: \(resultCode) \(resultCode.errorDescription))")
            throw DecoderError(resultCode)
        }
        
        // Collect the received frames in an array.
        let packetFrames: FFmpegPacketFrames = FFmpegPacketFrames()
        
        // Keep receiving decoded frames while no errors are encountered
        while let frame = context.receiveFrame() {
            packetFrames.appendFrame(frame)
        }
        
        return packetFrames
    }
    
    ///
    /// Flush this codec's internal buffers.
    ///
    /// Make sure to call this function prior to seeking within a stream.
    ///
    func flushBuffers() {
        context.flushBuffers()
    }
    
#if DEBUG
    
    ///
    /// Print some codec info to the console.
    /// May be used to verify that the codec was properly read / initialized.
    /// Useful for debugging purposes.
    ///
    func printInfo() {
        
        print("\n---------- Codec Info ----------\n")
        
        print(String(format: "Codec ID:    %d", self.id))
        print(String(format: "Codec Name:    %@", self.name))
        print(String(format: "Codec Long Name:    %@", longName))
        print(String(format: "Sample Rate:   %7d", sampleRate))
        print(String(format: "Sample Format: %7@", sampleFormat.name))
        print(String(format: "Planar Samples ?: %7@", String(sampleFormat.isPlanar)))
        print(String(format: "Sample Size:   %7d", sampleFormat.size))
        print(String(format: "Channels:      %7d", channelCount))
        
        print("---------------------------------\n")
    }
    
#endif
    
}
