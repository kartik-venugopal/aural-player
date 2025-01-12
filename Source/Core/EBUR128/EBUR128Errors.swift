//
//  EBUR128Errors.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

typealias EBUR128ResultCode = Int32

extension EBUR128ResultCode {
    
    var isEBUR128Success: Bool {
        self == EBUR128_SUCCESS.rawValue
    }
    
    var isEBUR128Failure: Bool {
        self != EBUR128_SUCCESS.rawValue
    }
}

class EBUR128Error: Error {
    
    let description: String
    
    init(description: String) {
        self.description = description
    }
}

class EBUR128InitializationError: EBUR128Error {
    
    let channelCount: Int
    let sampleRate: Int
    let mode: EBUR128Mode
    
    init(channelCount: Int, sampleRate: Int, mode: EBUR128Mode) {
        
        self.channelCount = channelCount
        self.sampleRate = sampleRate
        self.mode = mode
        
        super.init(description: "Failed to initialize EBUR128 for channelCount=\(channelCount), sampleRate=\(sampleRate), and mode=\(mode)")
    }
}

class EBURFrameAddError: EBUR128Error {
    
    let resultCode: EBUR128ResultCode
    let frameCount: Int
    
    init(resultCode: EBUR128ResultCode, frameCount: Int) {
        
        self.resultCode = resultCode
        self.frameCount = frameCount
        
        super.init(description: "Failed to add \(frameCount) frames to EBUR128. Result code: \(resultCode)")
    }
}

class EBURAnalysisError: EBUR128Error {
    
    let resultCode: EBUR128ResultCode
    
    init(resultCode: EBUR128ResultCode) {
        
        self.resultCode = resultCode
        
        super.init(description: "EBUR128 failed to analyze frames. Result code: \(resultCode)")
    }
}

class EBURAnalysisInterruptedError: Error, CustomStringConvertible {
    
    let rootCause: Error?
    let message: String?
    
    var description: String {
        message ?? rootCause?.localizedDescription ?? "Unknown error"
    }
    
    init(rootCause: Error?, message: String) {
        
        self.rootCause = rootCause
        self.message = message
    }
}
