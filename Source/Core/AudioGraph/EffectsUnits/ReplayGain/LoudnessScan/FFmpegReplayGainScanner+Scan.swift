//
//  FFmpegReplayGainScanner+Int16.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

fileprivate typealias EBUR128FramesAddFunction = (UnsafeMutablePointer<UInt8>?, FFmpegFrame) -> Void

extension FFmpegReplayGainScanner {
    
    func scanAsInt16() throws -> EBUR128AnalysisResult? {
        
        try doScan {pointer, frame in
            
            pointer?.withMemoryRebound(to: Int16.self, capacity: frame.intSampleCount) {pointer in
                
                do {
                    
                    try self.ebur128.addFramesAsInt16(framesPointer: pointer, frameCount: frame.intSampleCount)
                    self.consecutiveErrors = 0
                    
                } catch {
                    
                    consecutiveErrors.increment()
                    print((error as? EBUR128Error)?.description ?? error.localizedDescription)
                }
            }
        }
    }
    
    func scanAsInt32() throws -> EBUR128AnalysisResult? {
        
        try doScan {pointer, frame in
            
            pointer?.withMemoryRebound(to: Int32.self, capacity: frame.intSampleCount) {pointer in
                
                do {
                    
                    try self.ebur128.addFramesAsInt32(framesPointer: pointer, frameCount: frame.intSampleCount)
                    self.consecutiveErrors = 0
                    
                } catch {
                    
                    consecutiveErrors.increment()
                    print((error as? EBUR128Error)?.description ?? error.localizedDescription)
                }
            }
        }
    }
    
    func scanAsFloat() throws -> EBUR128AnalysisResult? {
        
        try doScan {pointer, frame in
            
            pointer?.withMemoryRebound(to: Float.self, capacity: frame.intSampleCount) {pointer in
                
                do {
                    
                    try self.ebur128.addFramesAsFloat(framesPointer: pointer, frameCount: frame.intSampleCount)
                    self.consecutiveErrors = 0
                    
                } catch {
                    
                    consecutiveErrors.increment()
                    print((error as? EBUR128Error)?.description ?? error.localizedDescription)
                }
            }
        }
    }
    
    func scanAsDouble() throws -> EBUR128AnalysisResult? {
        
        try doScan {pointer, frame in
            
            pointer?.withMemoryRebound(to: Double.self, capacity: frame.intSampleCount) {pointer in
                
                do {
                    
                    try self.ebur128.addFramesAsDouble(framesPointer: pointer, frameCount: frame.intSampleCount)
                    self.consecutiveErrors = 0
                    
                } catch {
                    
                    consecutiveErrors.increment()
                    print((error as? EBUR128Error)?.description ?? error.localizedDescription)
                }
            }
        }
    }
    
    fileprivate func doScan(addFramesFunction: EBUR128FramesAddFunction) throws -> EBUR128AnalysisResult? {
        
        defer {
            self.cleanUpAfterScan()
        }
        
        do {
            
            var curSize: Int = 0
            let sizeOfAFrame = codec.sampleFormat.size * channelCount
            
            while !isCancelled, !eof, consecutiveErrors < 3 {
                
                do {
                    
                    guard let pkt = try ctx.readPacket(from: stream) else {
                        
                        consecutiveErrors.increment()
                        continue
                    }
                    
                    let frames = try codec.decode(packet: pkt)
                    
                    for frame in frames.frames {
                        
                        // Only 1 buffer since interleaved. Capacity = sampleCount * number of bytes in Int16 * channelCount
                        let newSize = frame.intSampleCount * sizeOfAFrame
                        
                        if newSize > curSize {
                            
                            outputData?[0] = .allocate(capacity: newSize)
                            curSize = newSize
                        }
                        
                        swr?.convertFrame(frame, andStoreIn: outputData)
                        addFramesFunction(outputData?[0] ?? frame.dataPointers[0], frame)
                    }
                    
                } catch let err as CodedError {
                    
                    eof = err.isEOF
                    
                    if !err.isEOF {
                        
                        consecutiveErrors.increment()
                        print("Error: \(err.code.errorDescription)")
                    }
                }
            }
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        
        return isCancelled || (consecutiveErrors >= 3) || (!eof) ? nil : try ebur128.analyze()
    }
}
