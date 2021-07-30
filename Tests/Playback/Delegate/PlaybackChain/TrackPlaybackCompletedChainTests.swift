//
//  TrackPlaybackCompletedChainTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class TrackPlaybackCompletedChainTests: AuralTestCase {
    
    var startPlaybackChain: TestableStartPlaybackChain!
    var stopPlaybackChain: TestableStopPlaybackChain!
    
    var chain: TrackPlaybackCompletedChain!
    
    var player: TestablePlayer!
    var mockPlayerGraph: MockPlayerGraph!
    var mockScheduler: MockScheduler!
    var mockPlayerNode: MockPlayerNode!
    
    var trackReader: MockTrackReader!
    
    var playlist: Playlist!
    
    var sequencer: MockSequencer!
    var preferences: PlaybackPreferences!
    var profiles: PlaybackProfiles!
    
    var preTrackPlaybackMsgCount: Int = 0
    var preTrackPlaybackMsg_currentTrack: Track?
    var preTrackPlaybackMsg_currentState: PlaybackState?
    var preTrackPlaybackMsg_newTrack: Track?
    
    var trackTransitionMsgCount: Int = 0
    var trackTransitionMsg_currentTrack: Track?
    var trackTransitionMsg_currentState: PlaybackState?
    var trackTransitionMsg_newTrack: Track?
    
    var trackNotPlayedMsgCount: Int = 0
    var trackNotPlayedMsg_oldTrack: Track?
    var trackNotPlayedMsg_error: DisplayableError?
    
    private lazy var messenger = Messenger(for: self)

    override func setUp() {
        
        mockPlayerGraph = MockPlayerGraph()
        mockPlayerNode = (mockPlayerGraph.playerNode as! MockPlayerNode)
        mockScheduler = MockScheduler(mockPlayerNode)
        
        player = TestablePlayer(graph: mockPlayerGraph, avfScheduler: mockScheduler, ffmpegScheduler: mockScheduler)
        sequencer = MockSequencer()
        
        preferences = PlaybackPreferences([:])
        profiles = PlaybackProfiles([])
        
        let flatPlaylist = FlatPlaylist()
        let artistsPlaylist = GroupingPlaylist(.artists)
        let albumsPlaylist = GroupingPlaylist(.albums)
        let genresPlaylist = GroupingPlaylist(.genres)
        
        playlist = Playlist(flatPlaylist, [artistsPlaylist, albumsPlaylist, genresPlaylist])
        
        trackReader = MockTrackReader()
        
        startPlaybackChain = TestableStartPlaybackChain(player, sequencer, playlist, trackReader: trackReader, profiles, preferences)
        stopPlaybackChain = TestableStopPlaybackChain(player, playlist, sequencer, profiles, preferences)
        
        chain = TrackPlaybackCompletedChain(startPlaybackChain, stopPlaybackChain, sequencer)
        
        messenger.subscribe(to: .player_preTrackPlayback, handler: preTrackPlayback(_:))
        messenger.subscribe(to: .player_trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribe(to: .player_trackNotPlayed, handler: trackNotPlayed(_:))
    }
    
    override func tearDown() {
        
        messenger.unsubscribeFromAll()
        player.stopListeningForMessages()
        startPlaybackChain.stopListeningForMessages()
    }
    
    func trackTransitioned(_ notif: TrackTransitionNotification) {
        
        trackTransitionMsgCount.increment()
        
        trackTransitionMsg_currentTrack = notif.beginTrack
        trackTransitionMsg_currentState = notif.beginState
        trackTransitionMsg_newTrack = notif.endTrack
    }
    
    func preTrackPlayback(_ notif: PreTrackPlaybackNotification) {
        
        preTrackPlaybackMsgCount.increment()
        
        preTrackPlaybackMsg_currentTrack = notif.oldTrack
        preTrackPlaybackMsg_currentState = notif.oldState
        preTrackPlaybackMsg_newTrack = notif.newTrack
    }
    
    func trackNotPlayed(_ notif: TrackNotPlayedNotification) {
        
        trackNotPlayedMsgCount.increment()
        trackNotPlayedMsg_oldTrack = notif.oldTrack
        trackNotPlayedMsg_error = notif.error
    }
    
    func testTrackPlaybackCompleted_noSubsequentTrack() {
        
        let completedTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        sequencer.subsequentTrack = nil
        
        let oldProfile = PlaybackProfile(completedTrack, 125.324235346746)
        profiles[completedTrack] = oldProfile
        XCTAssertNotNil(profiles[completedTrack])
        
        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        preferences.rememberLastPositionOption = .individualTracks
        
        chain.execute(context)
        
        // Ensure profile was reset to 0
        let newProfile = profiles[completedTrack]!
        XCTAssertEqual(newProfile.lastPosition, 0)
        
        assertTrackPlayback(completedTrack, .playing, nil)
    }
    
    func testTrackPlaybackCompleted_subsequentTrackInvalid() {
        
        let completedTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let subsequentTrack = createTrack(title: "Silene", duration: 420)
        
        trackReader.preparationError = NoAudioTracksError(subsequentTrack.file)
        
        sequencer.subsequentTrack = subsequentTrack
        
        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        XCTAssertEqual(context.requestedTrack!, subsequentTrack)
        
        assertTrackNotPlayed(completedTrack, subsequentTrack, error: trackReader.preparationError!)
    }
    
    func testTrackPlaybackCompleted_hasSubsequentTrack() {
        
        let completedTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let subsequentTrack = createTrack(title: "Silene", duration: 420)
        sequencer.subsequentTrack = subsequentTrack
        
        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        XCTAssertEqual(context.requestedTrack!, subsequentTrack)
        
        assertTrackPlayback(completedTrack, .playing, subsequentTrack)
    }
    
    func testTrackPlaybackCompleted_hasSubsequentTrack_completedTrackHasPlaybackProfile_resetTo0() {
        
        let completedTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let subsequentTrack = createTrack(title: "Silene", duration: 420)
        sequencer.subsequentTrack = subsequentTrack
        
        let oldProfile = PlaybackProfile(completedTrack, 125.324235346746)
        profiles[completedTrack] = oldProfile
        XCTAssertNotNil(profiles[completedTrack])
        
        preferences.rememberLastPositionOption = .individualTracks
        
        let context = PlaybackRequestContext(.playing, completedTrack, completedTrack.duration, nil, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        XCTAssertEqual(context.requestedTrack!, subsequentTrack)
        
        // Ensure profile was reset to 0
        let newProfile = profiles[completedTrack]!
        XCTAssertEqual(newProfile.lastPosition, 0)
        
        assertTrackPlayback(completedTrack, .playing, subsequentTrack)
    }
   
    private func assertTrackNotPlayed(_ oldTrack: Track, _ newTrack: Track, error: DisplayableError) {

        XCTAssertEqual(player.state, .noTrack)
        XCTAssertEqual(preTrackPlaybackMsgCount, 0)
        
        XCTAssertEqual(trackTransitionMsgCount, 0)
        
        XCTAssertEqual(trackNotPlayedMsgCount, 1)
        XCTAssertEqual(trackNotPlayedMsg_oldTrack, oldTrack)
        XCTAssertTrue(trackNotPlayedMsg_error === error)
    }
    
    private func assertTrackPlayback(_ currentTrack: Track?, _ currentState: PlaybackState, _ newTrack: Track?) {
        
        let trackChanged = currentTrack != newTrack
        
        XCTAssertEqual(preTrackPlaybackMsgCount, trackChanged ? 1 : 0)
        
        if trackChanged {
            
            XCTAssertEqual(preTrackPlaybackMsg_currentTrack, currentTrack)
            XCTAssertEqual(preTrackPlaybackMsg_currentState, currentState)
            XCTAssertEqual(preTrackPlaybackMsg_newTrack, newTrack)
        }
        
        XCTAssertEqual(player.state, newTrack == nil ? .noTrack : .playing)
        
        XCTAssertEqual(startPlaybackChain.executionCount, newTrack == nil ? 0 : 1)
        XCTAssertEqual(stopPlaybackChain.executionCount, newTrack == nil ? 1 : 0)
        
        XCTAssertEqual(trackTransitionMsgCount, 1)
        XCTAssertEqual(trackTransitionMsg_currentTrack, currentTrack)
        XCTAssertEqual(trackTransitionMsg_currentState, currentState)
        XCTAssertEqual(trackTransitionMsg_newTrack, newTrack)
    }
}
