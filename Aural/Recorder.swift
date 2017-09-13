/*
 Provides all recording functionality (start/stop/save/delete), and maintains all state for the current recording (start time, file path, etc)
 */

import Cocoa
import AVFoundation

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
    
    func startRecording(_ format: RecordingFormat) {
        
        let now = Date()
        let nowString = Recorder.dateFormatter.string(from: now)
        
        tempRecordingFilePath = String(format: "%@/aural-tempRecording_%@.%@", AppConstants.recordingDirURL.path, nowString, format.fileExtension)
        
        let url = URL(fileURLWithPath: tempRecordingFilePath!, isDirectory: false)
        
        // Create the output file with the specified format
        var recFile: AVAudioFile?
        do {
            recFile = try AVAudioFile(forWriting: url, settings: format.settings)
        } catch let error as NSError {
            NSLog("Error creating recording file: %@", error.description)
        }
        
        // Install a tap on the audio engine to start receiving audio data
        graph.nodeForRecorderTap.installTap(onBus: 0, bufferSize: 1024, format: nil, block: { buffer, when in
            
            do {
                try recFile?.write(from: buffer)
            } catch let error as NSError {
                NSLog("Error writing to file: %@", error.description)
            }
        })
        
        // Mark the start time and the flag
        recordingStartTime = Date()
        recording = true
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
