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

protocol ReplayGainScanner {
    
    var file: URL {get}
    
    func scan(_ completionHandler: @escaping (EBUR128AnalysisResult) -> Void)
}

class FFmpegReplayGainScanner: ReplayGainScanner {
    
    let file: URL
    
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
        
        var ctr: Int = 0
        
        var swr: FFmpegReplayGainScanResamplingContext?
        var channelCount: Int = 0
        
        var outputData: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>!
        
        defer {
            outputData?[0]?.deallocate()
            outputData?.deallocate()
        }
        
        var ebur128: EBUR128State?
        
        var consecutiveErrors: Int = 0
        var eof: Bool = false
        
        do {
            
            let ctx = try FFmpegFileContext(for: file)
            
            guard let stream = ctx.bestAudioStream else {return nil}
            let codec = try FFmpegAudioCodec(fromParameters: stream.avStream.codecpar)
            
            channelCount = Int(codec.channelCount)
            
            ebur128 = try EBUR128State(channelCount: channelCount, sampleRate: Int(codec.sampleRate), mode: .samplePeak)
            
            // We need signed 16-bit integers (interleaved)
            if codec.sampleFormat.avFormat != AV_SAMPLE_FMT_S16 {
                
                swr = FFmpegReplayGainScanResamplingContext(inputChannelLayout: codec.channelLayout, sampleRate: Int64(codec.sampleRate), inputSampleFormat: codec.sampleFormat.avFormat)
                outputData = .allocate(capacity: 1)
            }
            
            var curSize: Int = 0
            let sizeOfInt16TimesChannelCount = MemoryLayout<Int16>.size * channelCount
            
            while !eof, consecutiveErrors < 3 {
                
                do {
                    
                    guard let pkt = try ctx.readPacket(from: stream) else {
                        
                        consecutiveErrors += 1
                        continue
                    }
                    
                    let frames = try codec.decode(packet: pkt)
                    
                    for frame in frames.frames {
                        
                        // Only 1 buffer since interleaved. Capacity = sampleCount * number of bytes in Int16 * channelCount
                        let newSize = frame.intSampleCount * sizeOfInt16TimesChannelCount
                        
                        if newSize > curSize {
                            
                            outputData?[0] = .allocate(capacity: newSize)
                            curSize = newSize
                        }
                        
                        swr?.convertFrame(frame, andStoreIn: outputData)
                        
                        let pointer: UnsafeMutablePointer<UInt8>? = outputData?[0] ?? frame.dataPointers[0]
                        
                        pointer?.withMemoryRebound(to: Int16.self, capacity: frame.intSampleCount) {pointer in
                            
                            do {
                                
                                try ebur128?.addFramesAsInt16(framesPointer: pointer, frameCount: frame.intSampleCount)
                                consecutiveErrors = 0
                                
                            } catch let err as EBUR128Error {
                                print(err.description)
                                
                            } catch {
                                print("Unknown error: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                } catch let err as DecoderError {
                    
                    eof = err.isEOF
                    
                    if !err.isEOF {
                        
                        consecutiveErrors += 1
                        print("Error: \(err.code.errorDescription) after reading \(ctr) packets")
                    }
                    
                } catch let err as PacketReadError {
                    
                    eof = err.isEOF
                    
                    if !err.isEOF {
                        
                        consecutiveErrors += 1
                        print("Error: \(err.code.errorDescription) after reading \(ctr) packets")
                    }
                }
            }
            
        } catch {
            print("Error: \(error) after reading \(ctr) packets")
        }
        
        return consecutiveErrors >= 3 ? nil : try ebur128?.analyze()
    }
}
