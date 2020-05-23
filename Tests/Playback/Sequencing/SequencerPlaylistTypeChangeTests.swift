import XCTest

class SequencerPlaylistTypeChangeTests: PlaybackSequencerTests {

    func testPlaylistTypeChange() {
        
        for playlistType in PlaylistType.allCases {
            
            sequencer.consumeNotification(PlaylistTypeChangedNotification(newPlaylistType: playlistType))
            XCTAssertEqual(sequencer.playlistType, playlistType)
        }
    }
}
