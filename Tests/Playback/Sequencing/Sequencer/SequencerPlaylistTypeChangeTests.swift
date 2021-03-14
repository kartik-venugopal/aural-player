import XCTest

class SequencerPlaylistTypeChangeTests: SequencerTests {

    func testPlaylistTypeChange() {
        
        for playlistType in PlaylistType.allCases {
            
            sequencer.playlistTypeChanged(playlistType)
            XCTAssertEqual(sequencer.playlistType, playlistType)
        }
    }
}
