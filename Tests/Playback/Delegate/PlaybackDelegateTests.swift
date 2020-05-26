import XCTest

class PlaybackDelegateTests: AuralTestCase, AsyncMessageSubscriber {
    
    var delegate: PlaybackDelegate!
    
    var player: PlayerProtocol!
    var mockPlayerGraph: MockPlayerGraph!
    var mockScheduler: MockScheduler!
    var mockPlayerNode: MockPlayerNode!
    
    var sequencer: MockSequencer!
    var playlist: Playlist!
    var transcoder: MockTranscoder!
    var preferences: PlaybackPreferences!
    var profiles: PlaybackProfiles!
    
    var startPlaybackChain: TestableStartPlaybackChain!
    var stopPlaybackChain: TestableStopPlaybackChain!
    var trackPlaybackCompletedChain: TestableTrackPlaybackCompletedChain!
    
    var trackChangeMessages: [TrackChangedAsyncMessage] = []
    var gapStartedMessages: [PlaybackGapStartedAsyncMessage] = []
    
    override func setUp() {
        
        if delegate == nil {
            
            mockPlayerGraph = MockPlayerGraph()
            mockPlayerNode = (mockPlayerGraph.playerNode as! MockPlayerNode)
            mockScheduler = MockScheduler(mockPlayerNode)
            
            player = Player(mockPlayerGraph, mockScheduler)
            
            let flatPlaylist = FlatPlaylist()
            let artistsPlaylist = GroupingPlaylist(.artists, .artist)
            let albumsPlaylist = GroupingPlaylist(.albums, .album)
            let genresPlaylist = GroupingPlaylist(.genres, .genre)
            
            playlist = Playlist(flatPlaylist, [artistsPlaylist, albumsPlaylist, genresPlaylist])
            sequencer = MockSequencer()
            
            transcoder = MockTranscoder()
            preferences = PlaybackPreferences([:])
            profiles = PlaybackProfiles()
            
            delegate = PlaybackDelegate([], player, sequencer, playlist, transcoder, preferences)
            
            startPlaybackChain = TestableStartPlaybackChain(player, sequencer, playlist, transcoder, profiles, preferences)
            stopPlaybackChain = TestableStopPlaybackChain(player, sequencer, transcoder, profiles, preferences)
            trackPlaybackCompletedChain = TestableTrackPlaybackCompletedChain(startPlaybackChain, stopPlaybackChain, sequencer, playlist, profiles, preferences)
            
            delegate.startPlaybackChain = startPlaybackChain
            delegate.stopPlaybackChain = stopPlaybackChain
            delegate.trackPlaybackCompletedChain = trackPlaybackCompletedChain
        }
        
        sequencer.reset()
        delegate.stop()
        stopPlaybackChain.executionCount = 0
        
        XCTAssertNil(delegate.playingTrack)
        XCTAssertEqual(delegate.state, PlaybackState.noTrack)
        XCTAssertEqual(startPlaybackChain.executionCount, 0)
        XCTAssertEqual(stopPlaybackChain.executionCount, 0)
        XCTAssertEqual(trackPlaybackCompletedChain.executionCount, 0)
        
        trackChangeMessages.removeAll()
        gapStartedMessages.removeAll()
        
        AsyncMessenger.subscribe([.trackChanged, .gapStarted], subscriber: self, dispatchQueue: DispatchQueue.global(qos: .userInteractive))
    }
    
    override func tearDown() {
        
        // Prevent test case objects from receiving each other's messages.
        AsyncMessenger.unsubscribe([.trackChanged, .gapStarted], subscriber: self)
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if let trackChangeMsg = message as? TrackChangedAsyncMessage {
            
            trackChangeMessages.append(trackChangeMsg)
            return
            
        } else if let gapStartedMsg = message as? PlaybackGapStartedAsyncMessage {
            
            gapStartedMessages.append(gapStartedMsg)
            return
        }
    }
    
    func setup_emptyPlaylist_noPlayingTrack() {
        
        playlist.clear()
        
        XCTAssertEqual(delegate.state, PlaybackState.noTrack)
        XCTAssertNil(delegate.playingTrack)
        XCTAssertNil(delegate.waitingTrack)
    }
    
    let artists: [String] = ["Conjure One", "Grimes", "Madonna", "Pink Floyd", "Dire Straits", "Ace of Base", "Delerium", "Blue Stone", "Jaia", "Paul Van Dyk"]
    
    let albums: [String] = ["Exilarch", "Halfaxa", "Vogue", "The Wall", "Brothers in Arms", "The Sign", "Music Box Opera", "Messages", "Mai Mai", "Reflections"]
    
    let genres: [String] = ["Electronica", "Pop", "Rock", "Dance", "International", "Jazz", "Ambient", "House", "Trance", "Techno", "Psybient", "PsyTrance", "Classical", "Opera"]
    
    func randomArtist() -> String {
        return artists[Int.random(in: 0..<artists.count)]
    }
    
    func randomAlbum() -> String {
        return albums[Int.random(in: 0..<albums.count)]
    }
    
    func randomGenre() -> String {
        return genres[Int.random(in: 0..<genres.count)]
    }
    
//    var testPlaylistSizes: [Int] {
//
//        var sizes: [Int] = [1, 2, 3, 5, 10, 50, 100, 500, 1000]
//
//        if runLongRunningTests {sizes.append(10000)}
//
//        let numRandomSizes = runLongRunningTests ? 100 : 10
//        let maxSize = runLongRunningTests ? 10000 : 1000
//
//        for _ in 1...numRandomSizes {
//            sizes.append(Int.random(in: 5...maxSize))
//        }
//
//        return sizes
//    }
//
//    var repeatOneIdempotence_count: Int {
//        return runLongRunningTests ? 10000 : 100
//    }
//
//    var sequenceRestart_count: Int {
//        return runLongRunningTests ? 10 : 3
//    }
//
//    let repeatShufflePermutations: [(repeatMode: RepeatMode, shuffleMode: ShuffleMode)] = {
//
//        var array: [(repeatMode: RepeatMode, shuffleMode: ShuffleMode)] = []
//
//        for repeatMode in RepeatMode.allCases {
//
//            for shuffleMode in ShuffleMode.allCases {
//
//                // Repeat One / Shuffle On is not a valid permutation
//                if (repeatMode, shuffleMode) != (.one, .on) {
//                    array.append((repeatMode, shuffleMode))
//                }
//            }
//        }
//
//        return array
//
//    }()
//
//    func preTest(_ playlistType: PlaylistType, _ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) {
//
//        sequencer.consumeNotification(PlaylistTypeChangedNotification(newPlaylistType: playlistType))
//        XCTAssertEqual(sequencer.playlistType, playlistType)
//
//        _ = sequencer.setRepeatMode(repeatMode)
//        let modes = sequencer.setShuffleMode(shuffleMode)
//
//        XCTAssertEqual(modes.repeatMode, repeatMode)
//        XCTAssertEqual(modes.shuffleMode, shuffleMode)
//    }
//
    func createTrack(_ title: String, _ duration: Double, _ artist: String? = nil, _ album: String? = nil, _ genre: String? = nil) -> Track {
        return createTrack(title, "mp3", duration, artist, album, genre)
    }
    
    func createTrack(_ title: String, _ fileExtension: String, _ duration: Double,
                     _ artist: String? = nil, _ album: String? = nil, _ genre: String? = nil) -> Track {
        
        let track = MockTrack(URL(fileURLWithPath: String(format: "/Dummy/%@.%@", title, fileExtension)))
        track.setPrimaryMetadata(artist, title, album, genre, duration)
        
        return track
    }
    
//    func createTracks(_ numTracks: Int, _ artist: String? = nil, _ album: String? = nil, _ genre: String? = nil) {
//
//        let sizeBeforeAdd = playlist.size
//        var tracks: [TrackAddResult] = []
//
//        for counter in 1...numTracks {
//
//            let title = "Track-" + String(sizeBeforeAdd + counter)
//            let theArtist = artist ?? randomArtist()
//            let theAlbum = album ?? randomAlbum()
//            let theGenre = genre ?? randomGenre()
//
//            let track = MockTrack(URL(fileURLWithPath: String(format: "/Dummy/%@.mp3", title)))
//            track.setPrimaryMetadata(theArtist, title, theAlbum, theGenre, Double.random(in: 60...600))
//
//            tracks.append(playlist.addTrack(track)!)
//        }
//
//        XCTAssertEqual(playlist.size, sizeBeforeAdd + numTracks)
//        sequencer.tracksAdded(tracks)
//
//        if sequencer.currentTrack != nil {
//            XCTAssertEqual(sequencer.sequence.size, playlist.size)
//        }
//    }
}
