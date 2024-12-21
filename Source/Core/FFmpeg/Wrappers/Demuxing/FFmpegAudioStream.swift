//
//  FFmpegAudioStream.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates an ffmpeg **AVStream** struct that represents a single audio stream,
/// and provides convenient Swift-style access to its functions and member variables.
///
/// Instantiates and provides the codec corresponding to the stream, and a codec context.
///
class FFmpegAudioStream: FFmpegStreamProtocol {
    
    ///
    /// A pointer to the encapsulated AVStream object.
    ///
    private var pointer: UnsafeMutablePointer<AVStream>
    
    ///
    /// The encapsulated AVStream object.
    ///
    var avStream: AVStream {pointer.pointee}
    
    var codecParams: AVCodecParameters {avStream.codecpar.pointee}
    
    lazy var codecLongName: String? = {
        
        let codecID = codecParams.codec_id
        let pointer = avcodec_find_decoder(codecID)
        
        if let name = pointer?.pointee.long_name {
            return String(cString: name)
        }
        
        return nil
    }()
    
    ///
    /// The media type of data contained within this stream (e.g. audio, video, etc)
    ///
    let mediaType: AVMediaType = AVMEDIA_TYPE_AUDIO
    
    ///
    /// The index of this stream within its container.
    ///
    let index: Int32
    
    ///
    /// The duration of this stream, in seconds, if available. Nil if not available.
    ///
    /// # Notes #
    ///
    /// This may not be available or may not be accurate for some streams
    /// like those in raw audio files without containers (e.g. aac, dts, ac3, etc.)
    ///
    var duration: Double?
    
    ///
    /// Unit of time in which frame timestamps are represented in this stream.
    ///
    var timeBase: AVRational {avStream.time_base}
    
    private(set) lazy var timeBaseRatio: Double = timeBase.ratio
    
    private(set) lazy var timeBaseReciprocalRatio: Double = timeBase.reciprocalRatio
    
    ///
    /// The duration of this stream, in time base units.
    ///
    /// # Notes #
    ///
    /// This may not be available or may not be accurate for some streams
    /// like those in raw audio files without containers (e.g. aac, dts, ac3, etc.)
    ///
    var timeBaseDuration: Int64 {avStream.duration}
    
    var sampleRate: Int32 {codecParams.sample_rate}
    
    var channelCount: Int32 {codecParams.ch_layout.nb_channels}
    
    var avChannelLayout: AVChannelLayout {codecParams.ch_layout}
    
    ///
    /// All metadata key / value pairs available for this stream.
    ///
    lazy var metadata: [String: String] = FFmpegMetadataReader.read(from: avStream.metadata)
    
    ///
    /// Instantiates this stream object and its associated codec and codec context.
    ///
    /// - Parameter pointer: Pointer to the underlying AVStream.
    ///
    /// - Parameter mediaType: The media type of this stream (e.g. audio / video, etc)
    ///
    init(encapsulatingPointeeOf pointer: UnsafeMutablePointer<AVStream>) {
        
        self.pointer = pointer
        self.index = pointer.pointee.index
        self.duration = timeBaseDuration > 0 ? Double(timeBaseDuration) * timeBaseRatio : nil
    }
}
