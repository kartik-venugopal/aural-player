import Cocoa
import AVFoundation

/*
    Concrete implementation of RecorderProtocol
 */
class Recorder: RecorderProtocol {
    
    // The audio engine that is to be tapped for recording data
    private var graph: RecorderGraphProtocol
    
    // Half a second, expressed in microseconds
    private static let halfSecondMicros: UInt32 = 500000
    
    init(_ graph: RecorderGraphProtocol) {
        self.graph = graph
    }
    
    // TODO: What if creating the audio file fails ? Return a Bool to indicate success ?
    func startRecording(_ format: RecordingFormat) {
        
        let session = RecordingSession.start(format)
        
        let url = URL(fileURLWithPath: session.tempFilePath)
        
        if let recordingFile = AudioIO.createAudioFileForWriting(url, format.settings) {
        
            // Install a tap on the audio engine to start receiving audio data
            graph.nodeForRecorderTap.installTap(onBus: 0, bufferSize: 1024, format: nil, block: { buffer, when in
                AudioIO.writeAudio(buffer, recordingFile)
            })
            
            // Mark the start time of the session
            session.startTime = Date()
            
        } else {
            
            NSLog("Unable to create recording audio file with specified format '%@'", format.fileExtension)
        }
    }
    
    func stopRecording() {
        
        // This sleep is to make up for the lag in the tap. In other words, continue to collect tapped data for half a second after the stop is requested.
        usleep(Recorder.halfSecondMicros)
        graph.nodeForRecorderTap.removeTap(onBus: 0)
        
        RecordingSession.endCurrentSession()
    }
    
    func saveRecording(_ url: URL) {
        
        // Rename the file from the temp URL -> user-defined URL
        let tempRecordingFilePath = RecordingSession.getCurrentSession()!.tempFilePath
        let srcURL = URL(fileURLWithPath: tempRecordingFilePath)
        FileSystemUtils.renameFile(srcURL, url)
        
        RecordingSession.invalidateCurrentSession()
    }
    
    func isRecording() -> Bool {
        let session = RecordingSession.getCurrentSession()
        return session != nil ? session!.active : false
    }
    
    func getRecordingInfo() -> RecordingInfo? {
        
        if (!isRecording()) {
            return nil
        }
        
        return RecordingSession.getCurrentSession()!.getRecordingInfo()
    }
    
    // Deletes the temporary recording file if the user discards the recording when prompted to save it
    func deleteRecording() {
        
        let tempRecordingFilePath = RecordingSession.getCurrentSession()!.tempFilePath
        FileSystemUtils.deleteFile(tempRecordingFilePath)
        
        RecordingSession.invalidateCurrentSession()
    }
}
