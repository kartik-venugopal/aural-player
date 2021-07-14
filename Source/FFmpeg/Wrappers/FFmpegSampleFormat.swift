//
//  FFmpegSampleFormat.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Wrapper around an **AVSampleFormat**.
///
/// Reads and provides useful information about the format of audio samples,
/// e.g. whether or not samples of this format need to be resampled for playback.
///
struct FFmpegSampleFormat {
    
    ///
    /// The AVSampleFormat that this object describes.
    ///
    let avFormat: AVSampleFormat
    
    ///
    /// The name of this format. (e.g. s16 or fltp)
    ///
    let name: String
    
    ///
    /// The size, in bytes, of each sample of this format. (e.g s16 samples consist of 2 bytes each)
    ///
    let size: Int
    
    ///
    /// Whether or not this represents a planar (or non-interleaved) format.
    ///
    /// # Note #
    ///
    /// A planar format is one that requires samples for each channel to be contained in a separate buffer.
    ///
    /// This flag is the inverse of **isInterleaved**.
    ///
    let isPlanar: Bool
    
    ///
    /// Whether or not this represents an interleaved (or packed) format
    ///
    /// # Note #
    ///
    /// A packed or interleaved format will contain data for all channels "packed" into a single buffer.
    ///
    /// This flag is the inverse of **isPlanar**.
    ///
    let isInterleaved: Bool
    
    ///
    /// Whether or not samples of this format are integers (as opposed to floating point).
    ///
    let isIntegral: Bool
    
    ///
    /// Whether or not samples of this format require conversion in order to
    /// be able to be fed into AVAudioEngine for playback.
    ///
    /// Will be true unless the sample format is 32-bit float non-interleaved (i.e. the standard Core Audio format).
    ///
    let needsFormatConversion: Bool
    
    static let integralFormats: Set<AVSampleFormat> = [AV_SAMPLE_FMT_U8, AV_SAMPLE_FMT_U8P, AV_SAMPLE_FMT_S16, AV_SAMPLE_FMT_S16P, AV_SAMPLE_FMT_S32, AV_SAMPLE_FMT_S32P, AV_SAMPLE_FMT_S64, AV_SAMPLE_FMT_S64P]
    
    ///
    /// Instantiates a SampleFormat from an AVSampleFormat.
    ///
    /// - Parameter avFormat: The AVSampleFormat to be wrapped by this object.
    ///
    init(encapsulating avFormat: AVSampleFormat) {
        
        self.avFormat = avFormat
        
        // Determine a name for this format, if possible.
        if let formatNamePointer = av_get_sample_fmt_name(avFormat) {
            self.name = String(cString: formatNamePointer)
            
        } else {
            self.name = "<Unknown sample format>"
        }
        
        self.size = Int(av_get_bytes_per_sample(avFormat))
        
        self.isPlanar = av_sample_fmt_is_planar(avFormat) == 1
        
        self.isInterleaved = !isPlanar
        
        self.isIntegral = Self.integralFormats.contains(avFormat)
        
        // Apparently, AVAudioEngine can only play 32-bit non-interleaved (planar) floating point samples.
        self.needsFormatConversion = avFormat != AV_SAMPLE_FMT_FLTP
    }
    
    ///
    /// A human-readable description of this format.
    ///
    var description: String {
        
        switch avFormat {
            
        case AV_SAMPLE_FMT_U8:       return "Unsigned 8-bit integer (Interleaved)"
            
        case AV_SAMPLE_FMT_S16:      return "Signed 16-bit integer (Interleaved)"
            
        case AV_SAMPLE_FMT_S32:      return "Signed 32-bit integer (Interleaved)"
            
        case AV_SAMPLE_FMT_S64:      return "Signed 64-bit integer (Interleaved)"
            
        case AV_SAMPLE_FMT_FLT:      return "Floating-point (Interleaved)"
            
        case AV_SAMPLE_FMT_DBL:      return "Double precision floating-point (Interleaved)"
            
        case AV_SAMPLE_FMT_U8P:       return "Unsigned 8-bit integer (Planar)"
            
        case AV_SAMPLE_FMT_S16P:      return "Signed 16-bit integer (Planar)"
            
        case AV_SAMPLE_FMT_S32P:      return "Signed 32-bit integer (Planar)"
            
        case AV_SAMPLE_FMT_S64P:      return "Signed 64-bit integer (Planar)"
            
        case AV_SAMPLE_FMT_FLTP:      return "Floating-point (Planar)"
                
        case AV_SAMPLE_FMT_DBLP:      return "Double precision floating-point (Planar)"
            
        default:                      return "<Unknown Sample Format>"
            
        }
    }
}

extension AVSampleFormat: Hashable {
    
    public var hashValue: Int {rawValue.hashValue}
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
