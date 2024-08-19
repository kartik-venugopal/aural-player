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

class AVFReplayGainScanner: ReplayGainScanner {
    
    let file: URL
    
    private let audioFile: AVAudioFile
    
    private let audioFormat: AVAudioFormat
    private let analysisFormat: AVAudioFormat
    
    private let channelLayout: AVAudioChannelLayout
    private let channelCount: AVAudioChannelCount
    private let sampleRate: Double
    private let totalSamples: AVAudioFramePosition
    
    private let ebur128: EBUR128State
    
    private static let analysisSampleFormat: AVAudioCommonFormat = .pcmFormatFloat32
    private static let chunkSize: AVAudioFrameCount = 5 * 44100
    
    init(file: URL) throws {
        
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
    
    func scan(_ completionHandler: @escaping (EBUR128AnalysisResult) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            do {
                
                if let result: EBUR128AnalysisResult = try self.doScan() {
                    completionHandler(result)
                } else {
                    print("No result")
                }
                
            } catch let err as EBUR128Error {
                print("Error: \(err.description)")
                
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    private func doScan() throws -> EBUR128AnalysisResult? {
        
        do {
            
            var samplesRead: AVAudioFramePosition = 0
            
            guard let readBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: Self.chunkSize),
                  let analyzeBuffer = AVAudioPCMBuffer(pcmFormat: analysisFormat, frameCapacity: Self.chunkSize) else {return nil}
            
            guard let converter: AVAudioConverter = .init(from: audioFormat,
                                                          to: analysisFormat) else {return nil}
            
            while samplesRead < totalSamples {
                
                try audioFile.read(into: readBuffer)
                samplesRead += AVAudioFramePosition(readBuffer.frameLength)
                
                try converter.convert(to: analyzeBuffer, from: readBuffer)
                
                guard let floatBuffer = analyzeBuffer.floatChannelData else {return nil}
                
                do {
                    try ebur128.addFramesAsFloat(framesPointer: floatBuffer[0], frameCount: Int(analyzeBuffer.frameLength))
                    
                } catch let err as EBUR128Error {
                    print(err.description)
                    
                } catch {
                    print("Unknown error: \(error.localizedDescription)")
                }
            }
         
            return try ebur128.analyze()
            
        } catch {
            
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
}
