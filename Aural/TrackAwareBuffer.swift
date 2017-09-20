import AVFoundation

class TrackAwareBuffer: AVAudioPCMBuffer {
    
    // In track seconds
    var startPos: Double = 0
    var endPos: Double = 0
    
    var firstFrame: AVAudioFramePosition = 0
    var lastFrame: AVAudioFramePosition = 0
    
    var avFile: AVAudioFile
    var sampleRate: Double = 44100
    
    var reachedEOF: Bool = false
    
    init(_ avFile: AVAudioFile, _ frameCapacity: AVAudioFrameCount) {
        
        self.avFile = avFile
        let format: AVAudioFormat = avFile.processingFormat
        self.sampleRate = format.sampleRate
        
        super.init(pcmFormat: format, frameCapacity: frameCapacity)
    }
 
    func readFromFile() -> Bool {
        
        firstFrame = avFile.framePosition
        startPos = Double(firstFrame) / sampleRate
        
        do {
            try avFile.read(into: self)
        } catch let error as NSError {
            NSLog("Error reading from audio file '%@' atPos '%d': %@", avFile.url.lastPathComponent, avFile.framePosition, error.description)
        }
        
        lastFrame = avFile.framePosition
        endPos = Double(lastFrame) / sampleRate
        
        let readAllFrames = lastFrame >= avFile.length
        let bufferNotFull = frameLength < frameCapacity
        
        // If all frames have been read, OR the buffer is not full, consider track done playing (EOF)
        self.reachedEOF = readAllFrames || bufferNotFull
        
        return reachedEOF
    }
    
    func subBuffer(_ startFrame: AVAudioFramePosition) -> TrackAwareBuffer {
        
        let tim = TimerUtils.start("subBuffer")
        
        let subBuffer = TrackAwareBuffer(self.avFile, AVAudioFrameCount(self.lastFrame - startFrame))
        
        let offset = AVAudioFrameCount(startFrame - firstFrame)
        let numChannels = Int(avFile.processingFormat.channelCount)
        
        for channel in 0..<numChannels {
            
            let srcData = self.floatChannelData?.advanced(by: channel).pointee
            let destData = subBuffer.floatChannelData?.advanced(by: channel).pointee
            
            var destCtr = 0
            for i in offset..<self.frameLength {
                destData!.advanced(by: destCtr).pointee = (srcData?.advanced(by: Int(i)).pointee)!
                destCtr += 1
            }
        }
        
//        print("Done copying to sub", self.frameLength)
        
        subBuffer.frameLength = subBuffer.frameCapacity
        
//        print("FL", subBuffer.frameLength)
        
        subBuffer.startPos = self.startPos
        subBuffer.endPos = self.endPos
        
//        print("Pos")
        
        subBuffer.firstFrame = startFrame
        subBuffer.lastFrame = self.lastFrame
        
//        print("First and last")
        
        subBuffer.reachedEOF = self.reachedEOF
        
//        print("Returning sub")
        tim.end()
        return subBuffer
    }
}
