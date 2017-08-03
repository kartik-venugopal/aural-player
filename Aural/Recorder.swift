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
    
    init(_ audioEngine: AVAudioEngine) {
        self.audioEngine = audioEngine
    }
    
    func startRecording(_ format: RecordingFormat) {
        
        tempRecordingFilePath = AppConstants.recordingDirURL.path.appending("/temp.").appending(format.fileExtension)
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
        
        // Mark the start time
        recordingStartTime = Date()
    }
    
    func stopRecording() {
        
        // Execute this block asynchronously so as not to block the main thread
        AsyncExecutor.execute({
            
            // This sleep is to make up for the lag in the tap. In other words, continue to collect tapped data for half a second after the stop is requested.
            usleep(500000)
            
            self.audioEngine.mainMixerNode.removeTap(onBus: 0)
        
        }, dispatchQueue: GCDDispatchQueue(queueType: QueueType.global))
    }
    
    func saveRecording(_ url: URL) {
        
        // Rename the file from the temp URL -> user-defined URL
        do {
            let originURL = URL(fileURLWithPath: tempRecordingFilePath!)
            try FileManager.default.moveItem(at: originURL, to: url)
        } catch let error as NSError {
            NSLog("Error renaming recording file to '%@': %@", url.path, error.description)
        }
    }
    
    func getRecordingInfo() -> RecordingInfo {
        
        // Duration = now - startTime
        let now = Date()
        let duration = now.timeIntervalSince(recordingStartTime!)
        let size = Utils.sizeOfFile(path: tempRecordingFilePath!)
        
        return RecordingInfo(duration, size)
    }
    
    // Deletes the temporary recording file if the user discards the recording when prompted to save it
    func deleteRecording() {
        do {
            try FileManager.default.removeItem(atPath: tempRecordingFilePath!)
        } catch let error as NSError {
            NSLog("Error deleting temporary recording file: %@", error.description)
        }
    }
}
