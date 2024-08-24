//
//  EBUR128State.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

fileprivate typealias PeakAnalysisFunction = (UnsafeMutablePointer<ebur128_state>, UInt32, UnsafeMutablePointer<Double>) -> EBUR128ResultCode

class EBUR128State {
    
    let file: URL
    
    let pointer: UnsafeMutablePointer<ebur128_state>
    
    var ebur128: ebur128_state {
        pointer.pointee
    }
    
    let channelCount: Int
    let sampleRate: Int
    let mode: EBUR128Mode
    
    static let targetLoudness: Double = -18
    static let assumedPeak: Double = 1
    
    init(file: URL, channelCount: Int, sampleRate: Int, mode: EBUR128Mode) throws {
        
        self.file = file
        
        self.channelCount = channelCount
        self.sampleRate = sampleRate
        self.mode = mode
        
        guard let ebur128Ptr = ebur128_init(UInt32(channelCount), UInt(sampleRate), mode.effectiveEBURMode) else {
            throw EBUR128InitializationError(channelCount: channelCount, sampleRate: sampleRate, mode: mode)
        }
        
        self.pointer = ebur128Ptr
    }
    
    func addFramesAsInt16(framesPointer: UnsafeMutablePointer<Int16>, frameCount: Int) throws {
        
        let result = ebur128_add_frames_short(self.pointer, framesPointer, frameCount)
        
        if result.isEBUR128Failure {
            throw EBURFrameAddError(resultCode: result, frameCount: frameCount)
        }
    }
    
    func addFramesAsInt32(framesPointer: UnsafeMutablePointer<Int32>, frameCount: Int) throws {
        
        let result = ebur128_add_frames_int(self.pointer, framesPointer, frameCount)
        
        if result.isEBUR128Failure {
            throw EBURFrameAddError(resultCode: result, frameCount: frameCount)
        }
    }
    
    func addFramesAsFloat(framesPointer: UnsafeMutablePointer<Float>, frameCount: Int) throws {
        
        let result = ebur128_add_frames_float(self.pointer, framesPointer, frameCount)
        
        if result.isEBUR128Failure {
            throw EBURFrameAddError(resultCode: result, frameCount: frameCount)
        }
    }
    
    func addFramesAsDouble(framesPointer: UnsafeMutablePointer<Double>, frameCount: Int) throws {
        
        let result = ebur128_add_frames_double(self.pointer, framesPointer, frameCount)
        
        if result.isEBUR128Failure {
            throw EBURFrameAddError(resultCode: result, frameCount: frameCount)
        }
    }
    
    func analyze() throws -> EBUR128TrackAnalysisResult {
        
        let loudness = try computeLoudness()
        let peak = try computePeak()
        let replayGain = Self.targetLoudness - loudness
        
        return EBUR128TrackAnalysisResult(file: self.file, loudness: loudness, peak: peak, replayGain: replayGain)
    }
    
    private func computeLoudness() throws -> Double {
        
        var loudness: Double = 0
        let result: EBUR128ResultCode = ebur128_loudness_global(self.pointer, &loudness)
        
        if result.isEBUR128Failure {
            throw EBURAnalysisError(resultCode: result)
        }
        
        return loudness
    }
    
    private func computePeak() throws -> Double {
        
        var peaks: [Double] = []
        var result: EBUR128ResultCode = 0
        var peak: Double = 0
        let analysisFunction: PeakAnalysisFunction = self.mode == .samplePeak ? ebur128_sample_peak : ebur128_true_peak
        
        for channel in 0..<channelCount {
            
            result = analysisFunction(pointer, UInt32(channel), &peak)
            
            if result.isEBUR128Failure {
                throw EBURAnalysisError(resultCode: result)
            }
            
            peaks.append(peak)
        }
        
        return peaks.max() ?? 1
    }
    
    static func computeAlbumLoudnessAndPeak(with eburs: [EBUR128State],
                                            andTrackResults trackResults: [EBUR128TrackAnalysisResult]) throws -> EBUR128AlbumAnalysisResult {
        
        var pointers: [UnsafeMutablePointer<ebur128_state>?] = eburs.map {$0.pointer}
        var albumLoudness: Double = 0
        
        ebur128_loudness_global_multiple(&pointers, eburs.count, &albumLoudness)
        let albumPeak = trackResults.map {$0.peak}.max() ?? Self.assumedPeak
        
        var results: [URL: EBUR128TrackAnalysisResult] = [:]
        
        for result in trackResults {
            results[result.file] = result
        }
        
        return EBUR128AlbumAnalysisResult(albumLoudness: albumLoudness, 
                                          albumPeak: albumPeak,
                                          albumReplayGain: Self.targetLoudness - albumLoudness,
                                          trackResults: results)
    }
    
    deinit {
        
        var mutablePointer: UnsafeMutablePointer<ebur128_state>? = self.pointer
        ebur128_destroy(&mutablePointer)
        free(mutablePointer)
    }
}

enum EBUR128Mode {
    
    case samplePeak, truePeak
    
    var eburMode: mode {
        self == .samplePeak ? EBUR128_MODE_SAMPLE_PEAK : EBUR128_MODE_TRUE_PEAK
    }
    
    var effectiveEBURMode: Int32 {
        Int32(EBUR128_MODE_I.rawValue | eburMode.rawValue)
    }
}

struct EBUR128TrackAnalysisResult: Codable {
    
    let file: URL
    
    let loudness: Double
    let peak: Double
    let replayGain: Double
}

struct EBUR128AlbumAnalysisResult: Codable {
    
    let albumLoudness: Double
    let albumPeak: Double
    let albumReplayGain: Double
    
    let trackResults: [URL: EBUR128TrackAnalysisResult]
}
