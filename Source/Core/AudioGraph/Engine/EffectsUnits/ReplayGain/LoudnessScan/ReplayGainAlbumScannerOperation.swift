//
//  ReplayGainAlbumScannerOperation.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class ReplayGainAlbumScannerOperation: Operation {
    
    static let queue: OperationQueue = .init(opCount: System.numberOfActiveCores, qos: .userInitiated)
    
    let files: [URL]
    
    private var scanners: [EBUR128LoudnessScannerProtocol] = []
    private let completionHandler: (ReplayGainAlbumScannerOperation, EBUR128AlbumAnalysisResult?) -> Void
    
    let eburs: ConcurrentArray<EBUR128State> = .init()
    let results: ConcurrentArray<EBUR128TrackAnalysisResult> = .init()
    
    // -------------------------------------------------------------------------------------------------------------------
    
    // MARK: - NSOperation Overrides
    
    override var isAsynchronous: Bool {true}
    
    /// Backing value for ``isExecuting``.
    private var _isExecuting = false
    override var isExecuting: Bool {_isExecuting}
    
    /// Backing value for ``isFinished``.
    private var _isFinished = false
    override var isFinished: Bool {_isFinished}
    
    init(files: [URL], completionHandler: @escaping (ReplayGainAlbumScannerOperation, EBUR128AlbumAnalysisResult?) -> Void) {
        
        self.files = files
        self.completionHandler = completionHandler
        
        super.init()
        
        for file in self.files {
            
            addDependency(BlockOperation {
                
                do {
                    
                    let scanner: EBUR128LoudnessScannerProtocol = file.isNativelySupported ?
                    try AVFReplayGainScanner(file: file) :
                    try FFmpegReplayGainScanner(file: file)
                    
                    self.eburs.append(scanner.ebur128)
                    let result = try scanner.scan()
                    self.results.append(result)
                    
                } catch {
                    NSLog("EBUR128 analysis of file '\(file.path)' failed. Error: \((error as? EBUR128Error)?.description ?? error.localizedDescription)")
                }
            })
        }
    }
    
    override func start() {
        
        // Do nothing if any of these flags is set.
        guard !isExecuting, !isFinished, !isCancelled else {return}
        
        Self.queue.addOperations(dependencies, waitUntilFinished: true)
        
        // Update state for KVO.
        willChangeValue(forKey: "isExecuting")
        _isExecuting = true
        didChangeValue(forKey: "isExecuting")
        
        let result: EBUR128AlbumAnalysisResult = EBUR128State.computeAlbumLoudnessAndPeak(with: eburs.array, andTrackResults: results.array)
        self.completionHandler(self, result)
        self.finish()
    }
    
    private func finish() {
        
        // Do nothing if any of these flags is set.
        guard !isFinished, !isCancelled else {return}
        
        // Update state for KVO.
        // NOTE - ``completionHandler`` will be called automatically
        // by ``NSOperation`` after these values change.
        
        willChangeValue(forKey: "isExecuting")
        willChangeValue(forKey: "isFinished")
        _isExecuting = false
        _isFinished = true
        didChangeValue(forKey: "isExecuting")
        didChangeValue(forKey: "isFinished")
    }
    
    override func cancel() {
        
        super.cancel()
        
        for scanner in scanners {
            scanner.cancel()
        }
    }
}
