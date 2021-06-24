//
//  RecorderDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    Concrete implementation of RecorderDelegateProtocol
 */

import Foundation

class RecorderDelegate: RecorderDelegateProtocol {
    
    private var recorder: RecorderProtocol
    
    private let dispatchQueue: DispatchQueue = DispatchQueue.global(qos: .userInitiated)
    
    init(_ recorder: RecorderProtocol) {
        self.recorder = recorder
    }
    
    func startRecording(_ params: RecordingParams) {
        recorder.startRecording(params)
    }
    
    func stopRecording() {
        
        // Perform asynchronously, to unblock the main thread
        dispatchQueue.async {
            self.recorder.stopRecording()
        }
    }
    
    func saveRecording(_ url: URL) {
        
        // Perform asynchronously, to unblock the main thread
        dispatchQueue.async {
            self.recorder.saveRecording(url)
        }
    }
    
    func deleteRecording() {
        
        // Perform asynchronously, to unblock the main thread
        dispatchQueue.async {
            self.recorder.deleteRecording()
        }
    }
    
    var recordingInfo: RecordingInfo? {
        return recorder.recordingInfo
    }
    
    var isRecording: Bool {
        return recorder.isRecording
    }
}
