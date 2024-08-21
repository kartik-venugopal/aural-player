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
    
    let cache: ConcurrentMap<URL, EBUR128AnalysisResult> = ConcurrentMap()
    
    init(persistentState: ReplayGainAnalysisCachePersistentState?) {
        
        guard let cache = persistentState?.cache else {return}
        
        for (file, result) in cache {
            self.cache[file] = result
        }
        
        print("ReplayGainScanner.init() read \(self.cache.count) cache entries")
    }
    
    func scan(forFile file: URL, _ completionHandler: @escaping (ReplayGain?) -> Void) throws {
        
        // First, check the cache
        if let theResult = cache[file] {
            
            // Cache hit
            print("ReplayGainScanner.init() CACHE HIT !!! \(theResult.replayGain) for file \(file.lastPathComponent)")
            completionHandler(ReplayGain(ebur128AnalysisResult: theResult))
            return
        }
        
        print("ReplayGainScanner.init() CACHE MISS for file \(file.lastPathComponent)")
        
        // Cache miss, initiate a scan
        
        let scanner: EBUR128LoudnessScannerProtocol = file.isNativelySupported ?
        try AVFReplayGainScanner(file: file) :
        try FFmpegReplayGainScanner(file: file)
        
        scanner.scan {[weak self] ebur128Result in
            
            if let theResult = ebur128Result {
                
                // Scan succeeded, cache the result
                self?.cache[file] = theResult
                completionHandler(ReplayGain(ebur128AnalysisResult: theResult))
                
            } else {
                
                // Scan failed
                completionHandler(nil)
            }
        }
    }
    
    var persistentState: ReplayGainAnalysisCachePersistentState {
        .init(cache: cache.map)
    }
}
