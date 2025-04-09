//
//  ReplayGainScanner.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

protocol EBUR128LoudnessScannerProtocol {
    
    var file: URL {get}
    
    var ebur128: EBUR128State {get}
    
    init(file: URL) throws
    
    func scan() throws -> EBUR128TrackAnalysisResult
    
    func cancel()
    
    var isCancelled: Bool {get}
}

typealias ReplayGainScanCompletionHandler = (ReplayGain?) -> Void

class ReplayGainScanner {
    
    let trackGainCache: ConcurrentMap<URL, ReplayGain> = ConcurrentMap()
    let albumGainCache: ConcurrentMap<String, AlbumReplayGain> = ConcurrentMap()
    
    private var scanOp: Operation? = nil
    
    init(persistentState: ReplayGainAnalysisCachePersistentState?) {
        
        if let trackGainCache = persistentState?.trackGainCache {
            self.trackGainCache.bulkAdd(map: trackGainCache)
        }
        
        if let albumGainCache = persistentState?.albumGainCache {
            self.albumGainCache.bulkAdd(map: albumGainCache)
        }
    }
    
    func cachedReplayGainData(forTrack track: Track) -> ReplayGain? {
        trackGainCache[track.file]
    }
    
    func scanTrack(file: URL, _ completionHandler: @escaping ReplayGainScanCompletionHandler) {
        
        cancelOngoingScan()
        
        // First, check the cache
        if let theResult = trackGainCache[file] {
            
            // Cache hit
            completionHandler(theResult)
            return
        }
        
        // Cache miss, initiate a scan
        
        scanOp = ReplayGainTrackScannerOperation(file: file) {[weak self] finishedScanOp, ebur128Result in
            
            // A previously scheduled scan op may finish just before being cancelled. This check
            // will prevent rogue completion handler execution.
            guard self?.scanOp == finishedScanOp else {return}
            
            if let theResult = ebur128Result {
                
                // Scan succeeded, cache the result
                let replayGain = ReplayGain(ebur128TrackAnalysisResult: theResult)
                self?.trackGainCache[file] = replayGain
                completionHandler(replayGain)
                
            } else {
                
                // Scan failed
                completionHandler(nil)
            }
            
            self?.scanOp = nil
        }
        
        scanOp?.start()
    }
    
    func scanAlbum(named albumName: String, withFiles files: [URL], forFile file: URL, _ completionHandler: @escaping ReplayGainScanCompletionHandler) {
        
        cancelOngoingScan()
        
        // First, check the cache
        if let theResult = albumGainCache[albumName], theResult.containsResultsForAllFiles(files), let trackResult = trackGainCache[file] {
            
            // Cache hit
            completionHandler(trackResult)
            return
        }
        
        // Cache miss, initiate a scan
        
        scanOp = ReplayGainAlbumScannerOperation(files: files) {[weak self] finishedScanOp, ebur128Result in
            
            // A previously scheduled scan op may finish just before being cancelled. This check
            // will prevent rogue completion handler execution.
            guard self?.scanOp == finishedScanOp else {return}
            
            if let theAlbumResult = ebur128Result {
                
                for (trackFile, trackResult) in theAlbumResult.trackResults {
                
                    self?.trackGainCache[trackFile] = ReplayGain(ebur128TrackAnalysisResult: trackResult,
                                                                 ebur128AlbumAnalysisResult: theAlbumResult)
                }
                
                // Scan succeeded, cache the result
                self?.albumGainCache[albumName] = AlbumReplayGain(albumName: albumName, files: files,
                                                                  loudness: theAlbumResult.albumLoudness,
                                                                  replayGain: theAlbumResult.albumReplayGain,
                                                                  peak: theAlbumResult.albumPeak)
                
                completionHandler(self?.trackGainCache[file])
                
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
        .init(trackGainCache: trackGainCache.map, albumGainCache: albumGainCache.map)
    }
}
