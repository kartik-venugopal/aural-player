/*
    Contract for an audio recorder that is responsible for recording functionality
 */

import Cocoa

protocol AuralRecorder {
    
    // Starts a recording with the specified format
    func startRecording(_ format: RecordingFormat)
    
    // Returns the current duration of the active recording, in seconds
    func getRecordingDuration() -> Double
    
    // Stops the current recording
    func stopRecording()
    
    // Saves the new recording to the user-defined file URL
    func saveRecording(_ url: URL)
    
    // Deletes the new recording
    func deleteRecording()
}
