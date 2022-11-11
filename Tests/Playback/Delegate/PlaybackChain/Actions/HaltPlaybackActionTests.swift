//
//  HaltPlaybackActionTests.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class HaltPlaybackActionTests: AuralTestCase {
    
    var action: HaltPlaybackAction!
    var chain: MockPlaybackChain!
    
    var player: TestablePlayer!
    var mockPlayerGraph: MockPlayerGraph!
    var mockScheduler: MockScheduler!
    var mockPlayerNode: MockPlayerNode!
    
    override func setUp() {
        
        mockPlayerGraph = MockPlayerGraph()
        mockPlayerNode = (mockPlayerGraph.playerNode as! MockPlayerNode)
        mockScheduler = MockScheduler(mockPlayerNode)
        
        player = TestablePlayer(graph: mockPlayerGraph, avfScheduler: mockScheduler, ffmpegScheduler: mockScheduler)
        action = HaltPlaybackAction(player)
        
        chain = MockPlaybackChain()
    }
    
    override func tearDown() {
        player.stopListeningForMessages()
    }

    func testHaltPlaybackAction_noTrack() {
        
        let newTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let context = PlaybackRequestContext(.noTrack, nil, 0, newTrack, PlaybackParams.defaultParams())
        
        doTestHaltPlaybackAction(context, 0)
    }
    
    func testHaltPlaybackAction_playing() {
        
        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let newTrack = createTrack(title: "Sub-Sea Engineering", duration: 360)
        
        let context = PlaybackRequestContext(.playing, currentTrack, currentTrack.duration, newTrack, PlaybackParams.defaultParams())
        
        doTestHaltPlaybackAction(context, 1)
    }
    
    func testHaltPlaybackAction_paused() {

        let currentTrack = createTrack(title: "Hydropoetry Cathedra", duration: 597)
        let newTrack = createTrack(title: "Sub-Sea Engineering", duration: 360)
        
        let context = PlaybackRequestContext(.paused, currentTrack, 101.327623, newTrack, PlaybackParams.defaultParams())
        
        doTestHaltPlaybackAction(context, 1)
    }
    
    private func doTestHaltPlaybackAction(_ context: PlaybackRequestContext, _ expectedPlayerStopCallCount: Int) {
        
        action.execute(context, chain)
        
        XCTAssertEqual(player.stopCallCount,expectedPlayerStopCallCount)
        XCTAssertEqual(player.state, PlaybackState.noTrack)
        
        // Ensure the chain proceeded
        XCTAssertEqual(chain.proceedCount, 1)
        XCTAssertTrue(chain.proceededContext! === context)
        XCTAssertEqual(chain.terminationCount, 0)
    }
}
