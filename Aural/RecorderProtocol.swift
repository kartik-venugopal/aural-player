/*
    Contract for an audio recorder that is responsible for recording functionality
 */

import Cocoa

protocol RecorderProtocol {
    
    // Starts a recording with the specified format
    func startRecording(_ format: RecordingFormat)
    
    // Returns metadata for the active recording (if there is one)
    func getRecordingInfo() -> RecordingInfo?
    
    // Returns a value indicating whether or not there is an ongoing recording
    func isRecording() -> Bool
    
    // Stops the current recording
    func stopRecording()
    
    // Saves the new recording to the user-defined file URL
    func saveRecording(_ url: URL)
    
    // Deletes the new recording
    func deleteRecording()
}
