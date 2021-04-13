import AVFoundation

/*
    Performs I/O of audio data.
 */
class AudioIO {
    
    // Utility method for creating an AVAudioFile from a URL, for writing
    static func createAudioFileForWriting(_ url: URL, _ settings: [String: Any]) -> AVAudioFile? {
        
        // Create the output file with the specified format
        var audioFile: AVAudioFile?
        do {
            
            audioFile = try AVAudioFile(forWriting: url, settings: settings)
            return audioFile
            
        } catch let error as NSError {
            
            NSLog("Error creating audio file '%@' for writing: %@", url.path, error.description)
            return nil
        }
    }
    
    // Writes a single buffer of audio data to the specified audio file
    static func writeAudio(_ buffer: AVAudioPCMBuffer, _ audioFile: AVAudioFile) {
        
        do {
            try audioFile.write(from: buffer)
        } catch let error as NSError {
            NSLog("Error writing to audio file '%@' atPos '%d': %@", audioFile.url.path, audioFile.framePosition, error.description)
        }
    }
}
