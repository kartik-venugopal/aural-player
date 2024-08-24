//
//  AVFReplayGainScanner.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import AVFoundation

class AVFReplayGainScanner: EBUR128LoudnessScannerProtocol {
    
    let file: URL
    
    private let audioFile: AVAudioFile
    
    private let audioFormat: AVAudioFormat
    private let analysisFormat: AVAudioFormat
    
    private let channelLayout: AVAudioChannelLayout
    private let channelCount: AVAudioChannelCount
    private let sampleRate: Double
    private let totalSamples: AVAudioFramePosition
    
    let ebur128: EBUR128State
    
    private(set) var isCancelled: Bool = false
    
    private static let analysisSampleFormat: AVAudioCommonFormat = .pcmFormatFloat32
    private static let chunkSize: AVAudioFrameCount = 5 * 44100
    private static let maxConsecutiveIOErrors: Int = 3
    private static let maxTotalIOErrors: Int = 10
    
    required init(file: URL) throws {
        
        self.file = file
        
        self.audioFile = try AVAudioFile(forReading: file)
        
        self.totalSamples = audioFile.length
        self.audioFormat = audioFile.processingFormat
        self.channelCount = audioFormat.channelCount
        self.sampleRate = audioFormat.sampleRate
        
        ebur128 = try EBUR128State(channelCount: Int(channelCount), sampleRate: Int(sampleRate), mode: .samplePeak)
        
        self.channelLayout = audioFormat.channelLayout ?? .defaultLayoutForChannelCount(channelCount)
        
        self.analysisFormat = .init(commonFormat: Self.analysisSampleFormat,
                                                  sampleRate: sampleRate,
                                                  interleaved: true,
                                                  channelLayout: channelLayout)
    }
    
    func scan() throws -> EBUR128TrackAnalysisResult {
        
        var samplesRead: AVAudioFramePosition = 0
        
        guard let readBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: Self.chunkSize),
              let analyzeBuffer = AVAudioPCMBuffer(pcmFormat: analysisFormat, frameCapacity: Self.chunkSize) else {
            
            throw AVFoundationError("Unable to create AVAudioPCMBuffer with format: \(audioFormat) and capacity: \(Self.chunkSize)")
        }
        
        guard let converter: AVAudioConverter = .init(from: audioFormat,
                                                      to: analysisFormat) else {
            
            throw AVFoundationError("Unable to create AVAudioConverter with source format: \(audioFormat) and target format: \(analysisFormat)")
        }
        
        var eof: Bool = false
        var sampleCountFromLastRead: AVAudioFramePosition = 0
        var consecutiveIOErrors: Int = 0
        var totalIOErrors: Int = 0
        var mostRecentError: Error? = nil
        
        while (!isCancelled) && (!eof) {
            
            do {
                
                try audioFile.read(into: readBuffer)
                sampleCountFromLastRead = AVAudioFramePosition(readBuffer.frameLength)
                samplesRead += sampleCountFromLastRead
                
                try converter.convert(to: analyzeBuffer, from: readBuffer)
                
                guard let floatBuffer = analyzeBuffer.floatChannelData else {
                    throw AVFoundationError("Unable to get floatChannelData property of AVAudioPCMBuffer")
                }
                
                try ebur128.addFramesAsFloat(framesPointer: floatBuffer[0], frameCount: Int(analyzeBuffer.frameLength))
                
                // Reset the error counter if the read after a failed iteration succeeds.
                if consecutiveIOErrors > 0 {
                    consecutiveIOErrors = 0
                }
                
            } catch {
                
                let description = (error as? EBUR128Error)?.description ?? error.localizedDescription
                NSLog("Waveform Decoder IO Error: \(description)")
                
                mostRecentError = error
                consecutiveIOErrors.increment()
                totalIOErrors.increment()
                
                if consecutiveIOErrors >= Self.maxConsecutiveIOErrors {
                    
                    NSLog("Encountered too many consecutive IO errors. Terminating scan loop.")
                    break
                    
                } else if totalIOErrors > Self.maxTotalIOErrors {
                    
                    NSLog("Encountered too many total IO errors. Terminating scan loop.")
                    break
                }
            }
            
            eof = (audioFile.framePosition >= totalSamples) ||
            (samplesRead >= totalSamples) ||
            (sampleCountFromLastRead == 0)
        }
        
        if isCancelled {
            throw EBURAnalysisInterruptedError(rootCause: mostRecentError, message: "Operation was cancelled.")
        } else if consecutiveIOErrors >= 3 {
            throw EBURAnalysisInterruptedError(rootCause: mostRecentError, message: "Too many consecutive errors encountered.")
        } else if !eof {
            throw EBURAnalysisInterruptedError(rootCause: mostRecentError, message: "Did not reach EOF.")
        }
        
        return try ebur128.analyze()
    }
    
    func cancel() {
        isCancelled = true
    }
}

class AVFoundationError: DisplayableError {}
