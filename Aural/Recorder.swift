/*
    Provides all recording functionality (start/stop/save/delete), and maintains all state for the current recording (start time, file path, etc)
 */

import Cocoa
import AVFoundation

class Recorder {
   
    // The audio engine that is to be tapped for recording data
    fileprivate var audioEngine: AVAudioEngine
    
    // The temporary file that will hold the recording, till the user specifies a path
    fileprivate var tempRecordingFilePath: String?
    
    // Used to determine the current recording duration
    fileprivate var recordingStartTime: Date?
    
    // Flag to indicate whether or not a recording is onging
    private var isRecording: Bool = false
    
    // Half a second, expressed in microseconds
    private static let halfSecondMicros: UInt32 = 500000
    
    // Used to append timestamps to temp recording files
    private static var dateFormatter = { () -> DateFormatter in
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy_hh-mm-ss"
        
        return formatter
    }()
    
    init(_ audioEngine: AVAudioEngine) {
        self.audioEngine = audioEngine
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
        self.audioEngine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: nil, block: { buffer, when in
            
            do {
                try recFile?.write(from: buffer)
            } catch let error as NSError {
                NSLog("Error writing to file: %@", error.description)
            }
        })
        
        // Mark the start time and the flag
        recordingStartTime = Date()
        isRecording = true
    }
    
    func stopRecording() {
        
        // This sleep is to make up for the lag in the tap. In other words, continue to collect tapped data for half a second after the stop is requested.
        usleep(Recorder.halfSecondMicros)
        audioEngine.mainMixerNode.removeTap(onBus: 0)
        isRecording = false
    }
    
    func saveRecording(_ url: URL) {
        
        // Rename the file from the temp URL -> user-defined URL
        let srcURL = URL(fileURLWithPath: tempRecordingFilePath!)
        FileSystemUtils.renameFile(srcURL, url)
    }
    
    func getRecordingInfo() -> RecordingInfo? {
        
        if (!isRecording) {
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
