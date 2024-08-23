//
//  ReplayGainAlbumScannerOperation.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class ReplayGainAlbumScannerOperation: Operation {
    
    let files: [URL]
    
    private var scanners: [EBUR128LoudnessScannerProtocol] = []
    private let completionHandler: (ReplayGainAlbumScannerOperation, EBUR128AlbumAnalysisResult?) -> Void
    
    // -------------------------------------------------------------------------------------------------------------------
    
    // MARK: - NSOperation Overrides
    
    override var isAsynchronous: Bool {true}
    
    /// Backing value for ``isExecuting``.
    private var _isExecuting = false
    override var isExecuting: Bool {_isExecuting}
    
    /// Backing value for ``isFinished``.
    private var _isFinished = false
    override var isFinished: Bool {_isFinished}
    
    init(files: [URL], completionHandler: @escaping (ReplayGainAlbumScannerOperation, EBUR128AlbumAnalysisResult?) -> Void) throws {
        
        self.files = files
        self.completionHandler = completionHandler
        
//        self.scanner = file.isNativelySupported ?
//        try AVFReplayGainScanner(file: file) :
//        try FFmpegReplayGainScanner(file: file)
        
        super.init()
    }
    
    override func start() {
        
        // Do nothing if any of these flags is set.
        guard !isExecuting, !isFinished, !isCancelled else {return}
        
        // Update state for KVO.
        willChangeValue(forKey: "isExecuting")
        _isExecuting = true
        didChangeValue(forKey: "isExecuting")
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            var result: EBUR128AlbumAnalysisResult? = nil
            
//            do {
//                result = try self.scanner.scan()
//            } catch {
//                NSLog("EBUR128 analysis of file '\(self.file.path)' failed. Error: \((error as? EBUR128Error)?.description ?? error.localizedDescription)")
//            }

            self.completionHandler(self, result)
            self.finish()
        }
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
//        scanner.cancel()
        
//        print("\nScan op cancelled for file: \(file.lastPathComponent)")
    }
}
