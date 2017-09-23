import Cocoa
import AVFoundation

/*
    Concrete implementation of RecorderProtocol
 */
class Recorder: RecorderProtocol {
    
    // The audio engine that is to be tapped for recording data
    private var graph: RecorderGraphProtocol
    
    // The temporary file that will hold the recording, till the user specifies a path
    private var tempRecordingFilePath: String?
    
    // Used to determine the current recording duration
    private var recordingStartTime: Date?
    
    // Flag to indicate whether or not a recording is onging
    private var recording: Bool = false
    
    // Half a second, expressed in microseconds
    private static let halfSecondMicros: UInt32 = 500000
    
    // Used to append timestamps to temp recording files
    private static var dateFormatter = { () -> DateFormatter in
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy_hh-mm-ss"
        
        return formatter
    }()
    
    init(_ graph: RecorderGraphProtocol) {
        self.graph = graph
    }
    
    // TODO: What if creating the audio file fails ? Return a Bool to indicate success ?
    func startRecording(_ format: RecordingFormat) {
        
        let now = Date()
        let nowString = Recorder.dateFormatter.string(from: now)
        
        tempRecordingFilePath = String(format: "%@/aural-tempRecording_%@.%@", AppConstants.recordingDirURL.path, nowString, format.fileExtension)
        
        let url = URL(fileURLWithPath: tempRecordingFilePath!)
        
        if let recFile = AudioIO.createAudioFileForWriting(url, format.settings) {
        
            // Install a tap on the audio engine to start receiving audio data
            graph.nodeForRecorderTap.installTap(onBus: 0, bufferSize: 1024, format: nil, block: { buffer, when in
                AudioIO.writeAudio(buffer, recFile)
            })
            
            // Mark the start time and the flag
            recordingStartTime = Date()
            recording = true
            
        } else {
            
            NSLog("Unable to create recording audio file with specified format '%@'", format.fileExtension)
        }
    }
    
    func stopRecording() {
        
        // This sleep is to make up for the lag in the tap. In other words, continue to collect tapped data for half a second after the stop is requested.
        usleep(Recorder.halfSecondMicros)
        graph.nodeForRecorderTap.removeTap(onBus: 0)
        recording = false
    }
    
    func saveRecording(_ url: URL) {
        
        // Rename the file from the temp URL -> user-defined URL
        let srcURL = URL(fileURLWithPath: tempRecordingFilePath!)
        FileSystemUtils.renameFile(srcURL, url)
    }
    
    func isRecording() -> Bool {
        return recording
    }
    
    func getRecordingInfo() -> RecordingInfo? {
        
        if (!recording) {
            return nil
        }
        
        // Duration = now - startTime
        let now = Date()
        let duration = now.timeIntervalSince(recordingStartTime!)
        let size = FileSystemUtils.sizeOfFile(path: tempRecordingFilePath!)
        
        return RecordingInfo(duration, size)
    }
    
    // Deletes the temporary recording file if the user discards the recording when prompted to save it
    func deleteRecording() {
        FileSystemUtils.deleteFile(tempRecordingFilePath!)
    }
}
