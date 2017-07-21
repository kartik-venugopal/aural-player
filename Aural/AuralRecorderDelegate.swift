/*
    Contract for a middleman/facade, between the UI and the recorder, that defines app-level (UI-level) operations to record audio
 */

import Cocoa

protocol AuralRecorderDelegate {
    
    // Starts a recording with the specified format
    func startRecording(_ format: RecordingFormat)
    
    // Returns the current duration of the active recording, in seconds
    func getRecordingDuration() -> Double
    
    // Stops the current recording
    func stopRecording()
    
    // Saves the new recording to the user-defined file URL
    func saveRecording(_ url: URL)
}
