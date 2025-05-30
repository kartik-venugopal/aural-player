//
//  AudioInfo.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// Encapsulates all techincal audio metadata for a track.
///
class AudioInfo {
    
    // The total number of frames in the track
    var frames: AVAudioFramePosition?
    
    // The sample rate of the track (in Hz)
    var sampleRate: Int32?
    
    // eg. "32-bit Floating point planar" or "Signed 16-bit Integer interleaved".
    var sampleFormat: String?
    
    // Number of audio channels
    var numChannels: Int?
    
    // Bit rate (in kbps)
    var bitRate: Int?
    
    // Audio format (e.g. "mp3", "aac", or "lpcm")
    var format: String?
    
    // The codec that was used to decode the track.
    var codec: String?
    
    // A description of the channel layout, eg. "5.1 Surround".
    var channelLayout: String?
    
    var replayGainFromMetadata: ReplayGain?
    var replayGainFromAnalysis: ReplayGain?
    
    init() {}
    
    init(persistentState: AudioInfoPersistentState) {
        
        self.frames = persistentState.frames
        self.sampleRate = persistentState.sampleRate
        self.sampleFormat = persistentState.sampleFormat
        self.numChannels = persistentState.numChannels
        self.bitRate = persistentState.bitRate
        self.format = persistentState.format
        self.codec = persistentState.codec
        self.channelLayout = persistentState.channelLayout
        self.replayGainFromAnalysis = persistentState.replayGainFromAnalysis
        self.replayGainFromMetadata = persistentState.replayGainFromMetadata
    }
}
