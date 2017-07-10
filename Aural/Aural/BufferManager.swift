
import Cocoa
import AVFoundation

/*
    Manages audio buffer allocation, scheduling, and playback. Provides two main operations - play() and seekToTime(). Works in conjunction with a playerNode to perform playback.
*/
class BufferManager {
    
    // Indicates the beginning of a file, used when starting file playback
    static let FRAME_ZERO = AVAudioFramePosition(0)
    
    // Don't schedule buffers with less than this number of frames
    private static let MIN_PLAYBACK_FRAMES: Int64 = 1000
    
    // Seconds of playback
    private static let BUFFER_SIZE: UInt32 = 5
    
    // Timer used to schedule buffers at regular intervals
    private var bufferTimer: StoppableScheduledTaskExecutor?
    
    // Player node used for actual playback
    private var playerNode: AVAudioPlayerNode
    
    init(playerNode: AVAudioPlayerNode) {
        self.playerNode = playerNode
    }
    
    // Start track playback from the beginning
    func play(avFile: AVAudioFile) {
        startPlaybackFromFrame(avFile, frame: 0)
    }
    
    // Starts track playback from a given frame position
    private func startPlaybackFromFrame(avFile: AVAudioFile, frame: AVAudioFramePosition) {
        
        // Set the position in the audio file from which reading is to begin
        avFile.framePosition = frame
        
        // Schedule one buffer for immediate playback
        scheduleNextBuffer(avFile)
        
        // Start playing the file
        playerNode.play()
        
        // Then, start a timer to schedule more "look-ahead" buffers as playback progresses
        // This will ensure x seconds of playback data is always available
        bufferTimer = StoppableScheduledTaskExecutor(intervalMillis: BufferManager.BUFFER_SIZE * 1000, task: {
            
            if (!self.bufferTimer!.isStopped() && !self.bufferTimer!.isPaused()) {
                
                let done = self.scheduleNextBuffer(avFile)
                if (done) {
                    self.bufferTimer!.stop()
                }
            }   
            
        }, queue: "Aural.player.bufferManager")
        
        bufferTimer!.start()
    }
    
    // Schedules a single audio buffer for playback
    private func scheduleNextBuffer(avFile: AVAudioFile) -> Bool {
        
        let sampleRate = avFile.processingFormat.sampleRate
        
        let buffer: AVAudioPCMBuffer = AVAudioPCMBuffer(PCMFormat: avFile.processingFormat, frameCapacity: AVAudioFrameCount(Double(BufferManager.BUFFER_SIZE) * sampleRate))
        
        do {
            try avFile.readIntoBuffer(buffer)
        } catch let error as NSError {
            print(error.description)
        }
        
        if (Int64(buffer.frameLength) >= BufferManager.MIN_PLAYBACK_FRAMES) {
        
            playerNode.scheduleBuffer(buffer, atTime: nil, options: AVAudioPlayerNodeBufferOptions(), completionHandler: nil)
        }

        let readAllFrames = avFile.framePosition >= avFile.length
        let bufferNotFull = buffer.frameLength < buffer.frameCapacity
        
        // If all frames have been read, OR the buffer is not full, consider track done playing (EOF)
        return readAllFrames || bufferNotFull
    }
    
    // Seeks to a certain position (seconds) in the audio file being played back. Returns the calculated start frame and whether or not playback has completed after this seek (i.e. end of file)
    func seekToTime(avFile: AVAudioFile, seconds: Double) -> (playbackCompleted: Bool, startFrame: AVAudioFramePosition?) {
        
        // Stop scheduling more buffers, *** wait for currently executing scheduling tasks ***, and invalidate the timer
        stop()
        
        let sampleRate = avFile.processingFormat.sampleRate
        let startFrameDouble = seconds * sampleRate
        
        //  Multiply your sample rate by the new time in seconds. This will give you the exact frame of the song at which you want to start the player
        let firstFrame = Int64(startFrameDouble)
        
        let framesToPlay = avFile.length - firstFrame
        
        // If not enough frames left to play, consider playback finished
        if framesToPlay > BufferManager.MIN_PLAYBACK_FRAMES {
            
            // Stop player node, start scheduling buffers of audio, and restart the player node
            
            playerNode.stop()
            
            // Seek to the new first frame, within the audio file
            avFile.framePosition = firstFrame
            
            // Start playback
            startPlaybackFromFrame(avFile, frame: firstFrame)
            
            // Return the start frame to later determine seek position and end of file
            return (false, firstFrame)
            
        } else {
            
            // Reached end of track. Stop playback
            return (true, nil)
        }
    }
    
    // Stops the scheduling of audio buffers, in response to a request to stop playback (or when seeking to a new position)
    func stop() {
        
        if (bufferTimer != nil) {
            
            // TODO: Figure out why this is needed (a GCD timer cannot be paused, then stopped, then deallocated)
            if (bufferTimer!.isPaused()) {
                bufferTimer!.resume()
            }
            
            bufferTimer!.stop()
            bufferTimer = nil
        }
    }
    
    // Pause buffer scheduling (when playback is paused)
    func pause() {
        
        if (bufferTimer != nil) {
            bufferTimer!.pause()
        }
    }
    
    // Resume buffer scheduling (when playback is resumed)
    func resume() {
        
        if (bufferTimer != nil) {
            bufferTimer!.resume()
        }
    }
}