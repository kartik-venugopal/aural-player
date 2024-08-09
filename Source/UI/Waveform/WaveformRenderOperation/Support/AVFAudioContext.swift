//
//  AVFAudioContext.swift
//  Periphony: Spatial Audio Player
//  Copyright © Oli Larkin Plug-ins Ltd. 2022. All rights reserved.
//  Developed by Kartik Venugopal
//

import AVFoundation

///
/// Audio information for an ``AVFoundation`` audio file.
///
class AVFAudioContext {
    
    /// The URL used to load the audio asset.
    let file: URL
    
    /// Loaded asset.
    let avfAsset: AVAsset
    
    /// Loaded audio track.
    let avfAssetTrack: AVAssetTrack
    
    let audioFile: AVAudioFile
    
    /// Number of audio channels.
    let channelCount: Int
    
    /// Sample rate, in Hz.
    let sampleRate: CMTimeScale
    
    /// Total number of samples in loaded asset.
    let totalSamples: Int

    init(file: URL, avfAsset: AVAsset, avfAssetTrack: AVAssetTrack, audioFile: AVAudioFile, channelCount: Int, sampleRate: CMTimeScale, totalSamples: Int) {
        
        self.file = file
        
        self.avfAsset = avfAsset
        self.avfAssetTrack = avfAssetTrack
        self.audioFile = audioFile
        
        self.channelCount = channelCount
        self.sampleRate = sampleRate
        self.totalSamples = totalSamples
    }
}
