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
    
    func cancel()
    
    var isCancelled: Bool {get}
}

class ReplayGainScanner {
    
    let cache: ConcurrentMap<URL, EBUR128AnalysisResult> = ConcurrentMap()
    
    private var scanOp: ReplayGainScannerOperation? = nil
    
    init(persistentState: ReplayGainAnalysisCachePersistentState?) {
        
        guard let cache = persistentState?.cache else {return}
        
        for (file, result) in cache {
            self.cache[file] = result
        }
        
        print("ReplayGainScanner.init() read \(self.cache.count) cache entries")
    }
    
    func scan(forFile file: URL, _ completionHandler: @escaping (ReplayGain?) -> Void) throws {
        
        cancelOngoingScan()
        
        // First, check the cache
//        if let theResult = cache[file] {
//            
//            // Cache hit
//            print("\nReplayGainScanner.init() CACHE HIT !!! \(theResult.replayGain) for file \(file.lastPathComponent)")
//            completionHandler(ReplayGain(ebur128AnalysisResult: theResult))
//            return
//        }
        
        print("\nReplayGainScanner.init() CACHE MISS for file \(file.lastPathComponent)")
        
        // Cache miss, initiate a scan
        
        scanOp = try ReplayGainScannerOperation(file: file) {[weak self] finishedScanOp, ebur128Result in
            
            // A previously scheduled scan op may finish just before being cancelled. This check
            // will prevent rogue completion handler execution.
            guard self?.scanOp == finishedScanOp else {return}
            
            print("Finished ? \(finishedScanOp.isFinished)")
            
            if let theResult = ebur128Result {
                
                // Scan succeeded, cache the result
                self?.cache[file] = theResult
                completionHandler(ReplayGain(ebur128AnalysisResult: theResult))
                
            } else {
                
                // Scan failed
                completionHandler(nil)
            }
            
            self?.scanOp = nil
        }
        
        scanOp?.start()
    }
    
    func cancelOngoingScan() {
        
        scanOp?.cancel()
        scanOp = nil
    }
    
    var persistentState: ReplayGainAnalysisCachePersistentState {
        .init(cache: cache.map)
    }
}
