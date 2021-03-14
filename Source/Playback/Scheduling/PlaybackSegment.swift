import AVFoundation

// Encapsulates all data required to schedule one audio file segment for playback. Can be passed around between functions and can be cached for reuse (when playing a segment loop).
struct PlaybackSegment {

    let session: PlaybackSession
    let playingFile: AVAudioFile

    let startTime: Double
    let endTime: Double

    let firstFrame: AVAudioFramePosition
    let lastFrame: AVAudioFramePosition

    let frameCount: AVAudioFrameCount

    init(_ session: PlaybackSession, _ playingFile: AVAudioFile, _ firstFrame: AVAudioFramePosition, _ lastFrame: AVAudioFramePosition, _ frameCount: AVAudioFrameCount, _ startTime: Double, _ endTime: Double) {

        self.session = session
        self.playingFile = playingFile

        self.startTime = startTime
        self.endTime = endTime

        self.firstFrame = firstFrame
        self.lastFrame = lastFrame

        self.frameCount = frameCount
    }
}
