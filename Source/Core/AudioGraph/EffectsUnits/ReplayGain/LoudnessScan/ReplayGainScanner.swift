//
//  ReplayGainScanner.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

protocol EBUR128LoudnessScannerProtocol {
    
    var file: URL {get}
    
    func scan(_ completionHandler: @escaping (EBUR128AnalysisResult?) -> Void)
}

class ReplayGainScanner {
    
    let file: URL
    let scanner: EBUR128LoudnessScannerProtocol
    
    init(file: URL) throws {
        
        self.file = file
        scanner = file.isNativelySupported ? try AVFReplayGainScanner(file: file) : try FFmpegReplayGainScanner(file: file)
    }
    
    func scan(_ completionHandler: @escaping (ReplayGain?) -> Void) {
        
        lazy var filePath = file.path
        
        scanner.scan {ebur128Result in
            
            if let theResult = ebur128Result {
                completionHandler(ReplayGain(ebur128AnalysisResult: theResult))
            } else {
                completionHandler(nil)
            }
        }
    }
}
