//
//  FFmpegReplayGainScanner.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

class FFmpegReplayGainScanner: EBUR128LoudnessScannerProtocol {
    
    let file: URL
    
    let ctx: FFmpegFileContext
    let stream: FFmpegAudioStream
    let codec: FFmpegAudioCodec
    var swr: FFmpegReplayGainScanResamplingContext? = nil
    
    let channelCount: Int
    let sampleRate: Int
    let sampleFormat: AVSampleFormat
    var targetFormat: AVSampleFormat
    
    let ebur128: EBUR128State
    
    private(set) var isCancelled: Bool = false
    
    var outputData: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>! = nil

    var consecutiveErrors: Int = 0
    var eof: Bool = false
    
    init(file: URL) throws {
        
        self.file = file
        
        self.ctx = try FFmpegFileContext(for: file)
        
        guard let theAudioStream = ctx.bestAudioStream else {
            throw FormatContextInitializationError(description: "\nUnable to find audio stream in file: '\(file.path)'")
        }
        
        self.stream = theAudioStream
        self.codec = try FFmpegAudioCodec(fromParameters: theAudioStream.avStream.codecpar)
        
        channelCount = Int(codec.channelCount)
        sampleFormat = codec.sampleFormat.avFormat
        sampleRate = Int(codec.sampleRate)
        
        ebur128 = try EBUR128State(channelCount: channelCount, sampleRate: sampleRate, mode: .samplePeak)
        
        self.targetFormat = sampleFormat
        
        // We need signed 16-bit integers (interleaved)
        if let theTargetFormat = codec.sampleFormat.conversionFormatForEBUR128 {
            
            self.targetFormat = theTargetFormat
            
            swr = FFmpegReplayGainScanResamplingContext(channelLayout: codec.channelLayout,
                                                        sampleRate: Int64(sampleRate),
                                                        inputSampleFormat: sampleFormat,
                                                        outputSampleFormat: theTargetFormat)
            outputData = .allocate(capacity: 1)
        }
    }
    
    func scan(_ completionHandler: @escaping (EBUR128AnalysisResult?) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            do {
                
                var result: EBUR128AnalysisResult? = nil
                
                switch self.targetFormat {
                    
                case AV_SAMPLE_FMT_S16:
                    result = try self.scanAsInt16()
                    
                case AV_SAMPLE_FMT_S32:
                    result = try self.scanAsInt32()
                    
                case AV_SAMPLE_FMT_FLT:
                    result = try self.scanAsFloat()
                    
                case AV_SAMPLE_FMT_DBL:
                    result = try self.scanAsDouble()
                    
                default:
                    break
                }
                
                completionHandler(result)
                
            } catch let err as EBUR128Error {
                print("Error: \(err.description)")
                
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    func cleanUpAfterScan() {
        
        outputData?[0]?.deallocate()
        outputData?.deallocate()
    }
    
    func cancel() {
        isCancelled = true
    }
}
