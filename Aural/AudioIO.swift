import AVFoundation

/*
    Performs I/O of audio data.
 */
class AudioIO {
   
    // Utility method for creating an AVAudioFile from a URL, for reading
    static func createAudioFileForReading(_ url: URL) -> AVAudioFile? {
        
        var audioFile: AVAudioFile? = nil
        do {
            
            audioFile = try AVAudioFile(forReading: url)
            return audioFile
            
        } catch let error as NSError {
            
            NSLog("Error creating audio file '%@' for reading: %@", url.path, error.description)
            return nil
        }
    }
    
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
    
    // Reads a single buffer, with a specified length, of audio data from the specified audio file
    static func readAudio(_ seconds: Double, _ audioFile: AVAudioFile) -> (buffer: AVAudioPCMBuffer, eof: Bool) {
        
        let buffer: AVAudioPCMBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(seconds * audioFile.processingFormat.sampleRate))
        
        do {
            try audioFile.read(into: buffer)
        } catch let error as NSError {
            NSLog("Error reading from audio file '%@' atPos '%d': %@", audioFile.url.path, audioFile.framePosition, error.description)
        }
        
        let readAllFrames = audioFile.framePosition >= audioFile.length
        let bufferNotFull = buffer.frameLength < buffer.frameCapacity
        
        // If all frames have been read, OR the buffer is not full, consider track done playing (EOF)
        return (buffer, readAllFrames || bufferNotFull)
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
