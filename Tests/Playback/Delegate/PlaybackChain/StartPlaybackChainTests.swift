//
//  StartPlaybackChainTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class StartPlaybackChainTests: AuralTestCase {
    
    var chain: TestableStartPlaybackChain!
    
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
    
    var trackChangeMsgCount: Int = 0
    var trackChangeMsg_currentTrack: Track?
    var trackChangeMsg_currentState: PlaybackState?
    var trackChangeMsg_newTrack: Track?
    
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
        
        trackReader = MockTrackReader()
        
        preferences = PlaybackPreferences([:])
        profiles = PlaybackProfiles([])
        
        let flatPlaylist = FlatPlaylist()
        let artistsPlaylist = GroupingPlaylist(.artists)
        let albumsPlaylist = GroupingPlaylist(.albums)
        let genresPlaylist = GroupingPlaylist(.genres)
        
        playlist = Playlist(flatPlaylist, [artistsPlaylist, albumsPlaylist, genresPlaylist])
        
        chain = TestableStartPlaybackChain(player, sequencer, playlist, trackReader: trackReader, profiles, preferences)
        
        messenger.subscribe(to: .player_preTrackPlayback, handler: preTrackPlayback(_:))
        messenger.subscribe(to: .player_trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribe(to: .player_trackNotPlayed, handler: trackNotPlayed(_:))
    }
    
    override func tearDown() {
        
        messenger.unsubscribeFromAll()
        chain.stopListeningForMessages()
        player.stopListeningForMessages()
    }
    
    private let lock = ExclusiveAccessSemaphore()
    
    func trackTransitioned(_ notif: TrackTransitionNotification) {
        
        lock.executeAfterWait {
            trackChanged(notif)
        }
    }
    
    func preTrackPlayback(_ notif: PreTrackPlaybackNotification) {
        
        preTrackPlaybackMsgCount.increment()
        
        preTrackPlaybackMsg_currentTrack = notif.oldTrack
        preTrackPlaybackMsg_currentState = notif.oldState
        preTrackPlaybackMsg_newTrack = notif.newTrack
    }
    
    func trackChanged(_ notif: TrackTransitionNotification) {
        
        trackChangeMsgCount.increment()
        
        trackChangeMsg_currentTrack = notif.beginTrack
        trackChangeMsg_newTrack = notif.endTrack
        trackChangeMsg_currentState = notif.beginState
    }
    
    func trackNotPlayed(_ notif: TrackNotPlayedNotification) {
        
        trackNotPlayedMsgCount.increment()
        trackNotPlayedMsg_oldTrack = notif.oldTrack
        trackNotPlayedMsg_error = notif.error
    }
    
    func testStartPlayback_noRequestedTrack() {
        
        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, nil, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        XCTAssertEqual(player.state, .noTrack)
        XCTAssertEqual(preTrackPlaybackMsgCount, 0)
        XCTAssertEqual(trackChangeMsgCount, 0)
        
        XCTAssertEqual(trackNotPlayedMsgCount, 0)
        XCTAssertNil(trackNotPlayedMsg_error)
    }
    
    func testStartPlayback_requestedTrackInvalid() {
        
        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let requestedTrack = createTrack(title: "Silene", duration: 420)
        
        trackReader.preparationError = NoAudioTracksError(requestedTrack.file)
        
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        XCTAssertNil(requestedTrack.playbackContext)
        
        assertTrackNotPlayed(currentTrack, error: trackReader.preparationError!)
    }
    
    func testStartPlayback() {
        
        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let requestedTrack = createTrack(title: "Silene", duration: 420)
        
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        assertTrackPlayback(currentTrack, .playing, requestedTrack, 1)
    }

    func testStartPlayback_currentTrackhasPlaybackProfile_profileSaved() {
        
        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let requestedTrack = createTrack(title: "Silene", duration: 420)
        
        let oldProfile = PlaybackProfile(currentTrack, 125.324235346746)
        profiles[currentTrack] = oldProfile
        XCTAssertNotNil(profiles[currentTrack])
        
        preferences.rememberLastPositionOption = .individualTracks
        
        let context = PlaybackRequestContext(.playing, currentTrack, 52.98743578, requestedTrack, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        // Ensure profile was updated
        let newProfile = profiles[currentTrack]!
        XCTAssertEqual(newProfile.lastPosition, context.currentSeekPosition)
        
        assertTrackPlayback(currentTrack, .playing, requestedTrack, 1)
    }
    
    func testStartPlayback_currentTrackHasPlaybackProfile_profilePositionResetTo0() {
        
        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let requestedTrack = createTrack(title: "Silene", duration: 420)
        
        let oldProfile = PlaybackProfile(currentTrack, 125.324235346746)
        profiles[currentTrack] = oldProfile
        XCTAssertNotNil(profiles[currentTrack])
        
        preferences.rememberLastPositionOption = .individualTracks
        
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, requestedTrack, PlaybackParams.defaultParams())
        
        chain.execute(context)
        
        // Ensure profile was reset to 0
        let newProfile = profiles[currentTrack]!
        XCTAssertEqual(newProfile.lastPosition, 0)
        
        assertTrackPlayback(currentTrack, .playing, requestedTrack, 1)
    }

    private func assertTrackNotPlayed(_ oldTrack: Track, error: DisplayableError) {

        XCTAssertEqual(player.state, .noTrack)
        XCTAssertEqual(preTrackPlaybackMsgCount, 0)
        
        XCTAssertEqual(trackChangeMsgCount, 0)
        
        XCTAssertEqual(trackNotPlayedMsgCount, 1)
        XCTAssertEqual(trackNotPlayedMsg_oldTrack, oldTrack)
        XCTAssertTrue(trackNotPlayedMsg_error === error)
    }
    
    private func assertTrackPlayback(_ currentTrack: Track?, _ currentState: PlaybackState, _ newTrack: Track, _ expectedTransitionCount: Int) {
        
        let trackChanged = currentTrack != newTrack
        
        XCTAssertEqual(preTrackPlaybackMsgCount, trackChanged ? 1 : 0)
        
        if trackChanged {
            
            XCTAssertEqual(preTrackPlaybackMsg_currentTrack, currentTrack)
            XCTAssertEqual(preTrackPlaybackMsg_currentState, currentState)
            XCTAssertEqual(preTrackPlaybackMsg_newTrack!, newTrack)
        }
        
        XCTAssertEqual(player.state, .playing)
        
        XCTAssertEqual(trackChangeMsgCount, expectedTransitionCount)
        XCTAssertEqual(trackChangeMsg_currentTrack, currentTrack)
        XCTAssertEqual(trackChangeMsg_currentState, currentState)
        XCTAssertEqual(trackChangeMsg_newTrack, newTrack)
    }
}
