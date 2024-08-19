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
    
    private static let chunkSize: AVAudioFrameCount = 5 * 44100
    
    init(file: URL) {
        self.file = file
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
            
            var time: Double = 0, st: Double = 0
            var ebur128: EBUR128State?
            
            let audioFile = try AVAudioFile(forReading: file)
            
            let totalSamples = audioFile.length
            var samplesRead: AVAudioFramePosition = 0
            
            let audioFormat = audioFile.processingFormat
            let channelCount = audioFormat.channelCount
            let sampleRate = audioFormat.sampleRate
            
            ebur128 = try EBUR128State(channelCount: Int(channelCount), sampleRate: Int(sampleRate), mode: .samplePeak)
            
            let channelLayout = audioFormat.channelLayout ?? .defaultLayoutForChannelCount(channelCount)
            
            let analysisFormat: AVAudioFormat = .init(commonFormat: .pcmFormatInt16,
                                                      sampleRate: sampleRate,
                                                      interleaved: true,
                                                      channelLayout: channelLayout)
            
            guard let readBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: Self.chunkSize),
                  let analyzeBuffer = AVAudioPCMBuffer(pcmFormat: analysisFormat, frameCapacity: Self.chunkSize) else {return nil}
            
            guard let converter: AVAudioConverter = .init(from: audioFormat,
                                                          to: analysisFormat) else {return nil}
            
            while samplesRead < totalSamples {
                
                try audioFile.read(into: readBuffer)
                samplesRead += AVAudioFramePosition(readBuffer.frameLength)
                
                try converter.convert(to: analyzeBuffer, from: readBuffer)
                
                guard let int16Buffer = analyzeBuffer.int16ChannelData else {return nil}
                
                st = CFAbsoluteTimeGetCurrent()
                
                do {
                    
                    try ebur128?.addFramesAsInt16(framesPointer: int16Buffer[0], frameCount: Int(analyzeBuffer.frameLength))
                    
                } catch let err as EBUR128Error {
                    print(err.description)
                    
                } catch {
                    print("Unknown error: \(error.localizedDescription)")
                }
                
                time += CFAbsoluteTimeGetCurrent() - st
            }
            
            return try ebur128?.analyze()
            
        } catch {
            
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
}
