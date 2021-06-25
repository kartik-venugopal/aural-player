//
//  AudioInfo.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

class AudioInfo {
    
    // The total number of frames in the track
    var frames: AVAudioFramePosition?
    
    // The sample rate of the track (in Hz)
    var sampleRate: Int32?
    
    // eg. 32-bit Floating point planar or Signed 16-bit Integer interleaved.
    var sampleFormat: String?
    
    // Number of audio channels
    var numChannels: Int?
    
    // Bit rate (in kbps)
    var bitRate: Int?
    
    // Audio format (e.g. "mp3", "aac", or "lpcm")
    var format: String?
    
    var codec: String?
    
    var channelLayout: String?
}
