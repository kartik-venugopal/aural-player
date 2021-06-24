//
//  RecorderDelegateProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    Contract for a middleman/delegate that relays all recording operations to the recorder
 */

import Cocoa

protocol RecorderDelegateProtocol {
    
    // Starts a recording with the specified format
    func startRecording(_ params: RecordingParams)
    
    // Stops the current recording
    func stopRecording()
    
    // Returns metadata for the active recording (if there is one)
    var recordingInfo: RecordingInfo? {get}
    
    // Returns a value indicating whether or not there is an ongoing recording
    var isRecording: Bool {get}
    
    // Saves the new recording to the user-defined file URL
    func saveRecording(_ url: URL)
    
    // Deletes the new recording
    func deleteRecording()
}
