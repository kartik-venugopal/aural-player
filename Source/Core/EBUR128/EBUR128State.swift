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
    
    let pointer: UnsafeMutablePointer<ebur128_state>
    
    var ebur128: ebur128_state {
        pointer.pointee
    }
    
    let channelCount: Int
    let sampleRate: Int
    let mode: EBUR128Mode
    
    static let targetLoudness: Double = -18
    static let maxPeak: Double = 1
    
    init(channelCount: Int, sampleRate: Int, mode: EBUR128Mode) throws {
        
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
    
    func analyze() throws -> EBUR128AnalysisResult {
        
        let loudness = try computeLoudness()
        let peak = try computePeak()
        let replayGain = Self.targetLoudness - loudness
        var replayGainToPreventClipping: Double = replayGain
        
        let newPeak = pow(10.0, replayGain / 20) * peak
        
        if newPeak > Self.maxPeak {
            
            let adjustment = 20 * log10(newPeak / Self.maxPeak)
            replayGainToPreventClipping -= adjustment
        }
        
        return EBUR128AnalysisResult(loudness: loudness, peak: peak, replayGain: replayGain, replayGainToPreventClipping: replayGainToPreventClipping)
    }
    
    func computeLoudness() throws -> Double {
        
        var loudness: Double = 0
        let result: EBUR128ResultCode = ebur128_loudness_global(self.pointer, &loudness)
        
        if result.isEBUR128Failure {
            throw EBURAnalysisError(resultCode: result)
        }
        
        return loudness
    }
    
    func computePeak() throws -> Double {
        
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

struct EBUR128AnalysisResult {
    
    let loudness: Double
    let peak: Double
    
    let replayGain: Double
    let replayGainToPreventClipping: Double
}
