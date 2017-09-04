/*
    Delegates requests from the UI to the actual Recorder unit
 */

import Foundation

class RecorderDelegate: RecorderDelegateProtocol {
    
    private var recorder: RecorderProtocol
    
    init(_ recorder: RecorderProtocol) {
        self.recorder = recorder
    }
    
    func startRecording(_ format: RecordingFormat) {
        recorder.startRecording(format)
    }
    
    func stopRecording() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.recorder.stopRecording()
        }
    }
    
    func saveRecording(_ url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.recorder.saveRecording(url)
        }
    }
    
    func deleteRecording() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.recorder.deleteRecording()
        }
    }
    
    func getRecordingInfo() -> RecordingInfo? {
        return recorder.getRecordingInfo()
    }
}
