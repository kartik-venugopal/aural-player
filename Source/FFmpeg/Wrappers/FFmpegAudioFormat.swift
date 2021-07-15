//
//  FFmpegAudioFormat.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all information about the audio format of a track, as defined by **FFmpeg**.
///
/// Analogous to **AVAudioFormat** in **AVFoundation**.
///
struct FFmpegAudioFormat {
    
    /// Samples per second
    let sampleRate: Int32
    
    /// Number of channels of audio
    let channelCount: Int32
    
    /// An ffmpeg identifier for the physical / spatial layout of channels. eg. "5.1 surround" or "stereo".
    let channelLayout: Int64
    
    /// PCM sample format
    let sampleFormat: FFmpegSampleFormat
    
    /// The AVSampleFormat that **sampleFormat** describes.
    var avSampleFormat: AVSampleFormat {sampleFormat.avFormat}
    
    ///
    /// Whether or not this represents a planar (or non-interleaved) format.
    ///
    /// # Note #
    ///
    /// A planar format is one that requires samples for each channel to be contained in a separate buffer.
    ///
    /// This flag is the inverse of **isInterleaved**.
    ///
    var isPlanar: Bool {sampleFormat.isPlanar}
    
    ///
    /// Whether or not this represents an interleaved (or packed) format
    ///
    /// # Note #
    ///
    /// A packed or interleaved format will contain data for all channels "packed" into a single buffer.
    ///
    /// This flag is the inverse of **isPlanar**.
    ///
    var isInterleaved: Bool {sampleFormat.isInterleaved}
    
    ///
    /// Whether or not samples of this format are integers (as opposed to floating point).
    ///
    var isIntegral: Bool {sampleFormat.isIntegral}
    
    ///
    /// Whether or not samples of this format require conversion before they can be fed into AVAudioEngine for playback.
    ///
    /// Will be true unless the sample format is 32-bit float non-interleaved (i.e. the standard Core Audio format).
    ///
    var needsFormatConversion: Bool {sampleFormat.needsFormatConversion}
}
