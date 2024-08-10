//
//  WaveformDecoderProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AVFoundation

typealias Float2DBuffer = [FloatPointer]

let waveformDecodingChunkSize: AVAudioFrameCount = 44100 * 10

protocol WaveformDecoderProtocol {
    
    /// The URL used to load the audio asset.
    var file: URL {get}
    
    /// Number of audio channels.
    var channelCount: AVAudioChannelCount {get}
    
    /// Sample rate, in Hz.
    var sampleRate: Double {get}
    
    /// Total number of samples in loaded asset.
    var totalSamples: AVAudioFramePosition {get}
    
    /// The total number of samples read (per channel) so far.
    var totalSamplesRead: AVAudioFrameCount {get}
    
    var reachedEOF: Bool {get}
    
    func decode(intoBuffer processingBuffer: inout Float2DBuffer, currentBufferLength: AVAudioFrameCount) throws -> AVAudioFrameCount
}
