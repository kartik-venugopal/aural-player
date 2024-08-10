//
//  AVFAudioContext.swift
//  Periphony: Spatial Audio Player
//  Copyright © Oli Larkin Plug-ins Ltd. 2022. All rights reserved.
//  Developed by Kartik Venugopal
//

import AVFoundation
import Accelerate

///
/// Audio information for an ``AVFoundation`` audio file.
///
class AVFWaveformDecoder: WaveformDecoderProtocol {
    
    /// The URL used to load the audio asset.
    let file: URL
    
    /// Number of audio channels.
    let channelCount: AVAudioChannelCount
    
    /// Sample rate, in Hz.
    let sampleRate: Double
    
    /// Total number of samples in loaded asset.
    let totalSamples: AVAudioFramePosition
    
    var totalSamplesRead: AVAudioFrameCount = 0
    
    private let audioFile: AVAudioFile
    private let pcmBuffer: AVAudioPCMBuffer
    
    private var sampleCountFromLastRead: AVAudioFrameCount = 1
    
    var reachedEOF: Bool {
        
        (audioFile.framePosition >= totalSamples) || 
        (totalSamplesRead >= totalSamples) ||
        (sampleCountFromLastRead == 0)
    }

    init?(file: URL) {
        
        self.file = file
        
        guard let audioFile = try? AVAudioFile(forReading: file) else {return nil}
        self.audioFile = audioFile
        
        self.channelCount = audioFile.processingFormat.channelCount
        self.sampleRate = audioFile.processingFormat.sampleRate
        self.totalSamples = audioFile.length
        
        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: waveformDecodingChunkSize) else {return nil}
        self.pcmBuffer = pcmBuffer
    }
    
    func decode(intoBuffer processingBuffer: inout Float2DBuffer, currentBufferLength: AVAudioFrameCount) throws -> AVAudioFrameCount {
        
        try audioFile.read(into: pcmBuffer)
        
        guard let srcPointers = pcmBuffer.floatChannelData else {return 0}
        
        let sampleCount = Int32(pcmBuffer.frameLength)
        let processingBufferOffset: Int = Int(currentBufferLength)
        
        // NOTE - The following copy operation assumes a non-interleaved output format (i.e. the standard Core Audio format).

        // Iterate through all the channels.
        for channelIndex in 0..<processingBuffer.count {
            
            // Use Accelerate to perform the copy optimally, starting at the given offset.
            cblas_scopy(sampleCount,
                        srcPointers[channelIndex], 1,
                        processingBuffer[channelIndex].advanced(by: processingBufferOffset), 1)
        }
        
        sampleCountFromLastRead = pcmBuffer.frameLength
        totalSamplesRead += sampleCountFromLastRead
        
        return sampleCountFromLastRead
    }
}
