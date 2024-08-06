//
//  FFmpegAudioCodec.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates an ffmpeg **AVCodec** struct, and provides convenient Swift-style access to its functions and member variables.
///
class FFmpegAudioCodec {
    
    ///
    /// A pointer to the encapsulated AVCodec object.
    ///
    var pointer: UnsafePointer<AVCodec>!
    
    ///
    /// The encapsulated AVCodec object.
    ///
    var avCodec: AVCodec {pointer.pointee}
    
    ///
    /// A context for the encapsulated AVCodec object.
    ///
    let context: FFmpegCodecContext
    
    ///
    /// Decoding parameters for the encapsulated AVCodec object.
    ///
    let params: FFmpegCodecParameters
    
    ///
    /// The unique identifier of the encapsulated AVCodec object.
    ///
    var id: UInt32 {avCodec.id.rawValue}
    
    ///
    /// The name of the encapsulated AVCodec object.
    ///
    var name: String {String(cString: avCodec.name)}
    
    ///
    /// The long name of the encapsulated AVCodec object.
    ///
    var longName: String {String(cString: avCodec.long_name)}
    
    var isOpen: Bool = false
    
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
    lazy var sampleFormat: FFmpegSampleFormat = FFmpegSampleFormat(encapsulating: context.sampleFormat)
    
    ///
    /// Number of channels of audio data.
    ///
    var channelCount: Int32 {
        channelLayout.numberOfChannels
    }
    
    ///
    /// Describes the number and physical / spatial arrangement of the channels. (e.g. "5.1 surround" or "stereo")
    ///
    lazy var channelLayout: FFmpegChannelLayout = .init(encapsulating: context.channelLayout)
    
    ///
    /// Instantiates an AudioCodec object, given a pointer to its parameters.
    ///
    /// - Parameter paramsPointer: A pointer to parameters for the associated AVCodec object.
    ///
    init(fromParameters paramsPointer: UnsafeMutablePointer<AVCodecParameters>) throws {
        
        self.params = .init(pointer: paramsPointer)
        self.pointer = try Self.findDecoder(fromParams: params)
        
        // Allocate a context for the codec.
        self.context = try .init(codecPointer: pointer, codecParams: params)
        
        // Use multithreading to speed up decoding.
        self.context.threadCount = Self.threadCount
        self.context.threadType = Self.threadType
        
        try open()
    }
    
    private static func findDecoder(fromParams params: FFmpegCodecParameters) throws -> UnsafePointer<AVCodec> {
        
        let codecID = params.codecID
        
        guard let pointer = avcodec_find_decoder(codecID) else {
            throw CodecInitializationError(description: "Unable to find required codec '\(codecID.name)'")
        }
        
        return pointer
    }
    
    ///
    /// Opens the codec for decoding.
    ///
    /// - throws: **DecoderInitializationError** if the codec cannot be opened.
    ///
    private func open() throws {
        
        let codecOpenResult: ResultCode = avcodec_open2(context.pointer, pointer, nil)
        if codecOpenResult.isNonZero {
            
            NSLog("Failed to open codec '\(name)'. Error: \(codecOpenResult.errorDescription))")
            throw DecoderInitializationError(codecOpenResult)
        }
        
        isOpen = true
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
        let resultCode: ResultCode = context.sendPacket(packet)
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
