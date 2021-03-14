/*
    Contract for an audio recorder that is responsible for recording functionality
 */

import Cocoa

protocol RecorderProtocol {
    
    // Starts a recording with the specified format
    func startRecording(_ format: RecordingFormat)
    
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
