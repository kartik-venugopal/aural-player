//
//  StopPlaybackChainTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest
import AVFoundation

class StopPlaybackChainTests: AuralTestCase {

    var chain: TestableStopPlaybackChain!

    var player: TestablePlayer!
    var mockPlayerGraph: MockPlayerGraph!
    var mockScheduler: MockScheduler!
    var mockPlayerNode: MockPlayerNode!
    
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
    
    private lazy var messenger = Messenger(for: self)

    override func setUp() {

        mockPlayerGraph = MockPlayerGraph()
        mockPlayerNode = (mockPlayerGraph.playerNode as! MockPlayerNode)
        mockScheduler = MockScheduler(mockPlayerNode)

        player = TestablePlayer(graph: mockPlayerGraph, avfScheduler: mockScheduler, ffmpegScheduler: mockScheduler)
        sequencer = MockSequencer()
        
        let flatPlaylist = FlatPlaylist()
        let artistsPlaylist = GroupingPlaylist(.artists)
        let albumsPlaylist = GroupingPlaylist(.albums)
        let genresPlaylist = GroupingPlaylist(.genres)
        
        playlist = Playlist(flatPlaylist, [artistsPlaylist, albumsPlaylist, genresPlaylist])

        preferences = PlaybackPreferences([:])
        profiles = PlaybackProfiles([])

        chain = TestableStopPlaybackChain(player, playlist, sequencer, profiles, preferences)

        messenger.subscribe(to: .player_preTrackPlayback, handler: preTrackPlayback(_:))
        messenger.subscribe(to: .player_trackTransitioned, handler: trackTransitioned(_:))
    }

    override func tearDown() {
        
        player.stopListeningForMessages()
        messenger.unsubscribeFromAll()
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
    
    func testActions() {
        
        XCTAssertTrue(chain.actions[0] is SavePlaybackProfileAction)
        XCTAssertTrue(chain.actions[1] is HaltPlaybackAction)
        XCTAssertTrue(chain.actions[2] is EndPlaybackSequenceAction)
        XCTAssertTrue(chain.actions[3] is CloseFileHandlesAction)
    }

    func testStop_noPlayingTrack() {

        let context = PlaybackRequestContext(.noTrack, nil, 0, nil, PlaybackParams.defaultParams())
        chain.execute(context)

        XCTAssertEqual(player.state, PlaybackState.noTrack)
        XCTAssertEqual(sequencer.endCallCount, 1)
        XCTAssertEqual(player.stopCallCount, 0)

        assertTrackPlayback(nil, .noTrack)
    }

    func testStop_trackPlaying() {

        let playingTrack = createTrack(title: "Silene", duration: 420)
        playingTrack.playbackContext = MockAVFPlaybackContext(file: playingTrack.file, duration: playingTrack.duration,
                                                       audioFormat: AVAudioFormat(standardFormatWithSampleRate: 44100,
                                                                                  channels: 2)!)
        
        player.play(playingTrack, 0, nil)
        XCTAssertEqual(player.state, PlaybackState.playing)

        preferences.rememberLastPositionOption = .individualTracks

        profiles[playingTrack] = PlaybackProfile(playingTrack, 105.3242323)

        let context = PlaybackRequestContext(.playing, playingTrack, 203.34242434, nil, PlaybackParams.defaultParams())
        chain.execute(context)

        XCTAssertEqual(player.state, PlaybackState.noTrack)
        XCTAssertEqual(sequencer.endCallCount, 1)
        XCTAssertEqual(player.stopCallCount, 1)
        assertTrackPlayback(playingTrack, .playing)

        XCTAssertEqual(profiles[playingTrack]!.lastPosition, context.currentSeekPosition)
    }

    func testStop_trackPaused() {

        let playingTrack = createTrack(title: "Silene", duration: 420)
        playingTrack.playbackContext = MockAVFPlaybackContext(file: playingTrack.file, duration: playingTrack.duration,
                                                       audioFormat: AVAudioFormat(standardFormatWithSampleRate: 44100,
                                                                                  channels: 2)!)

        player.play(playingTrack, 0, nil)
        player.pause()
        XCTAssertEqual(player.state, PlaybackState.paused)

        preferences.rememberLastPositionOption = .individualTracks

        profiles[playingTrack] = PlaybackProfile(playingTrack, 105.3242323)

        let context = PlaybackRequestContext(.paused, playingTrack, 203.34242434, nil, PlaybackParams.defaultParams())
        chain.execute(context)

        XCTAssertEqual(player.state, PlaybackState.noTrack)
        XCTAssertEqual(sequencer.endCallCount, 1)
        XCTAssertEqual(player.stopCallCount, 1)
        assertTrackPlayback(playingTrack, .paused)

        XCTAssertEqual(profiles[playingTrack]!.lastPosition, context.currentSeekPosition)
    }

    private func assertTrackPlayback(_ currentTrack: Track?, _ currentState: PlaybackState) {

        XCTAssertEqual(preTrackPlaybackMsgCount, 1)
        XCTAssertEqual(preTrackPlaybackMsg_currentTrack, currentTrack)
        XCTAssertEqual(preTrackPlaybackMsg_currentState, currentState)
        XCTAssertEqual(preTrackPlaybackMsg_newTrack, nil)

        XCTAssertEqual(trackTransitionMsgCount, 1)
        XCTAssertEqual(trackTransitionMsg_currentTrack, currentTrack)
        XCTAssertEqual(trackTransitionMsg_currentState, currentState)
        XCTAssertEqual(trackTransitionMsg_newTrack, nil)
    }
}
