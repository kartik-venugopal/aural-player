import XCTest
import AVFoundation

class AuralPlayerNodeTests: XCTestCase {
    
    private var playerNode: TestableAuralPlayerNode = TestableAuralPlayerNode()
    private var track: Track!

    override func setUp() {
        
        playerNode.resetMock()
        
        let format: AVAudioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        let audioFile: AVAudioFile = MockAVAudioFile(format)
        
        // Create a dummy track of 5 minutes duration, with a sample rate of 44100 Hz and 2 channels.
        track = Track(URL(fileURLWithPath: "/Dummy/Path"))
        track.setDuration(300)
        
        track.playbackInfo = PlaybackInfo()
        track.playbackInfo?.audioFile = audioFile
        track.playbackInfo?.frames = 44100 * 300
    }

    func testSeekPosition_playing_startedAt0() {
        doTestSeekPosition(0, 12.97537, 44100)
    }
    
    func testSeekPosition_playing_notStartedAt0() {
        doTestSeekPosition(39.61113, 12.97537, 44100)
    }
    
    func testSeekPosition_paused() {
        
        let cachedSeekPosn = 45.6789193
        playerNode.cachedSeekPosn = cachedSeekPosn
        
        playerNode.sampleTime = nil
        playerNode.sampleRate = nil
        
        // When the player node is not playing, the seek position should be the last computed (i.e. cached) seek position.
        XCTAssertEqual(playerNode.seekPosition, cachedSeekPosn, accuracy: 0.001)
    }
    
    /*
        startPos:           The seek position (in seconds) at which the playerNode's sampleTime was reset to 0.
        trackTimePlayed:    The amount of track time (in seconds) that the playerNode has played after being reset at startPos.
        sampleRate:         Sample rate of the track being played.
     */
    private func doTestSeekPosition(_ startPos: Double,_ trackTimePlayed: Double, _ sampleRate: Double) {
        
        playerNode.startFrame = AVAudioFramePosition(sampleRate * startPos)
        playerNode.sampleRate = sampleRate
        playerNode.sampleTime = AVAudioFramePosition(sampleRate * trackTimePlayed)
        
        print("\n\nSeekPos:", playerNode.seekPosition, startPos + trackTimePlayed)
        
        XCTAssertEqual(playerNode.seekPosition, startPos + trackTimePlayed, accuracy: 0.001)
    }
}
