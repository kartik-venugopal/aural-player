import XCTest
import Cocoa
@testable import Aural

class PlaybackSchedulerTests: XCTestCase, AsyncMessageSubscriber {
    
    private var scheduler: PlaybackScheduler!
    private var mockPlayerNode: MockPlayerNode!
    
    private var track: Track = Track(URL(fileURLWithPath: "/Dummy/Path"))
    
    var subscriberId: String {return self.className + String(describing: self.hashValue)}
    var msgReceived: Bool = false
    var trackCompletionExpectation: XCTestExpectation?

    override func setUp() {
        
        // This will be done only once
        if scheduler == nil {
            
            mockPlayerNode = MockPlayerNode()
            scheduler = PlaybackScheduler(mockPlayerNode)
            
            AsyncMessenger.subscribe([.playbackCompleted], subscriber: self, dispatchQueue: DispatchQueue.global(qos: .userInteractive))
        }
        
        trackCompletionExpectation = nil
        msgReceived = false
        _ = PlaybackSession.endCurrent()
    }
    
    override func tearDown() {
        AsyncMessenger.unsubscribe([.playbackCompleted], subscriber: self)
    }

    func testSegmentCompleted_trackCompletion() {

        // Start a session, put the player node in a playing state, then invoke segmentCompleted() with that same session.
        // This should trigger a track completion notification.
        let session = PlaybackSession.start(track)
        mockPlayerNode.play()

        scheduler.segmentCompleted(session)

        // Wait 1 second, then validate
        executeAfter(1) {
            XCTAssertTrue(self.msgReceived)
        }
    }
    
    func testSegmentCompleted_oldSession() {

        // Start a session, and put the player node in a playing state.
        let session = PlaybackSession.start(track)
        mockPlayerNode.play()

        // Create a new session, thus invalidating the first one.
        _ = PlaybackSession.startNewSessionForPlayingTrack()

        scheduler.segmentCompleted(session)

        // Wait 1 second, then validate
        executeAfter(1) {
            XCTAssertFalse(self.msgReceived)
        }
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        msgReceived = message is PlaybackCompletedAsyncMessage
    }
}
