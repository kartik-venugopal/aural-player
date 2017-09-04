/*
 Contract for a middleman/facade, between the UI and the recorder, that defines app-level (UI-level) operations to record audio
 */

import Cocoa

protocol RecorderDelegateProtocol {
    
    // Starts a recording with the specified format
    func startRecording(_ format: RecordingFormat)
    
    // Returns the current duration of the active recording, in seconds, if there is one
    func getRecordingInfo() -> RecordingInfo?
    
    // Stops the current recording
    func stopRecording()
    
    // Saves the new recording to the user-defined file URL
    func saveRecording(_ url: URL)
    
    // Deletes the new recording
    func deleteRecording()
}
