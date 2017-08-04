import Foundation
import AVFoundation

class AudioBufferCache {
    
    private static var cache: [Track: (AVAudioPCMBuffer, Bool)] = [Track: (AVAudioPCMBuffer, Bool)]()
    
    private static let placeholderBuffer: AVAudioPCMBuffer = AVAudioPCMBuffer()
    
    static func loadForTrack(_ track: Track, _ bufferSize: UInt32 = AppConstants.audioBufferSize_initial) {
        
        let tim = TimerUtils.start("loadForTrack")
        
        // Already loaded, don't do anything
        if (getForTrack(track) != nil) {
            return
        }
        
        // Hack to ensure that only one thread loads a track into the cache
        cache[track] = (placeholderBuffer, true)
        
        // Can assume that track.avFile is non-nil, because track has been prepared for playback
        var avFile: AVAudioFile
        
        do {
            avFile = try AVAudioFile(forReading: track.file! as URL)
            
            // Set the framePosition to zero to read from beginning of file
            avFile.framePosition = BufferManager.FRAME_ZERO
            
            let sampleRate = avFile.processingFormat.sampleRate
            let buffer: AVAudioPCMBuffer = AVAudioPCMBuffer(pcmFormat: avFile.processingFormat, frameCapacity: AVAudioFrameCount(Double(bufferSize) * sampleRate))
            
            do {
                try avFile.read(into: buffer)
                
                let readAllFrames = avFile.framePosition >= track.frames!
                let bufferNotFull = buffer.frameLength < buffer.frameCapacity
                
                // If all frames have been read, OR the buffer is not full, consider track done playing (EOF)
                let reachedEOF = readAllFrames || bufferNotFull
                
                // Cache the buffer for later use
                cache[track] = (buffer, reachedEOF)
                track.avFile = avFile
                
                NSLog("Loaded for track %@", track.shortDisplayName!)
                
            } catch let error as NSError {
                cache[track] = nil
                NSLog("Error reading from audio file '%@': %@", avFile.url.lastPathComponent, error.description)
            }
            
        } catch let error as NSError {
            cache[track] = nil
            NSLog("Error reading track '%@': %@", track.file!.path, error.description)
        }
        
        tim.end()
    }
    
    static func getForTrack(_ track: Track) -> (buffer: AVAudioPCMBuffer, reachedEOF: Bool)? {
        return cache[track]
    }
    
    static func containsForTrack(_ track: Track) -> Bool {
        return getForTrack(track) != nil
    }
    
    static func removeForTrack(_ track: Track) {
        cache.removeValue(forKey: track)
    }
}
