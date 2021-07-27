//
//  PlaybackRequestContextTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

//class PlaybackRequestContextTests: PlaybackDelegateTests {
//    
//    func testBegun() {
//        
//        let track1 = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let context1 = PlaybackRequestContext(.noTrack, nil, 0, track1, PlaybackParams.defaultParams())
//        
//        let track2 = createTrack(title: "Sub-Sea Engineering", duration: 360)
//        let context2 = PlaybackRequestContext(.playing, track1, 283.34686234, track2, PlaybackParams.defaultParams().withDelay(5))
//        
//        let track3 = createTrack(title: "LSD", duration: 250)
//        let context3 = PlaybackRequestContext(.paused, track2, 101.182829828, track3, PlaybackParams.defaultParams().withAllowDelay(false).withInterruptPlayback(false))
//        
//        PlaybackRequestContext.begun(context1)
//        
//        assertCurrentContext(context1)
//        assertNotCurrentContext(context2)
//        assertNotCurrentContext(context3)
//        
//        PlaybackRequestContext.begun(context2)
//        
//        assertCurrentContext(context2)
//        assertNotCurrentContext(context1)
//        assertNotCurrentContext(context3)
//        
//        PlaybackRequestContext.begun(context3)
//        
//        assertCurrentContext(context3)
//        assertNotCurrentContext(context1)
//        assertNotCurrentContext(context2)
//    }
//    
//    private func assertCurrentContext(_ context: PlaybackRequestContext) {
//        
//        XCTAssertTrue(PlaybackRequestContext.currentContext! === context)
//        XCTAssertTrue(PlaybackRequestContext.isCurrent(context))
//    }
//    
//    private func assertNotCurrentContext(_ context: PlaybackRequestContext) {
//        
//        XCTAssertFalse(PlaybackRequestContext.currentContext === context)
//        XCTAssertFalse(PlaybackRequestContext.isCurrent(context))
//    }
//    
//    func testCompleted() {
//        
//        let track1 = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let context1 = PlaybackRequestContext(.noTrack, nil, 0, track1, PlaybackParams.defaultParams())
//        
//        let track2 = createTrack(title: "Sub-Sea Engineering", duration: 360)
//        let context2 = PlaybackRequestContext(.playing, track1, 283.34686234, track2, PlaybackParams.defaultParams().withDelay(5))
//        
//        let track3 = createTrack(title: "LSD", duration: 250)
//        let context3 = PlaybackRequestContext(.paused, track2, 101.182829828, track3, PlaybackParams.defaultParams().withAllowDelay(false).withInterruptPlayback(false))
//        
//        // ------------------------
//        
//        PlaybackRequestContext.begun(context1)
//        assertCurrentContext(context1)
//        
//        PlaybackRequestContext.completed(context1)
//        assertNotCurrentContext(context1)
//        XCTAssertNil(PlaybackRequestContext.currentContext)
//        
//        // ------------------------
//        
//        PlaybackRequestContext.begun(context2)
//        assertCurrentContext(context2)
//        
//        PlaybackRequestContext.completed(context2)
//        assertNotCurrentContext(context2)
//        XCTAssertNil(PlaybackRequestContext.currentContext)
//        
//        // ------------------------
//        
//        PlaybackRequestContext.begun(context3)
//        assertCurrentContext(context3)
//        
//        PlaybackRequestContext.completed(context3)
//        assertNotCurrentContext(context3)
//        XCTAssertNil(PlaybackRequestContext.currentContext)
//    }
//    
//    func testCompleted_nonCurrentContextCompleted() {
//        
//        let track1 = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let context1 = PlaybackRequestContext(.noTrack, nil, 0, track1, PlaybackParams.defaultParams())
//        
//        let track2 = createTrack(title: "Sub-Sea Engineering", duration: 360)
//        let context2 = PlaybackRequestContext(.playing, track1, 283.34686234, track2, PlaybackParams.defaultParams().withDelay(5))
//        
//        let track3 = createTrack(title: "LSD", duration: 250)
//        let context3 = PlaybackRequestContext(.paused, track2, 101.182829828, track3, PlaybackParams.defaultParams().withAllowDelay(false).withInterruptPlayback(false))
//        
//        // ------------------------
//        
//        // Make context1 the current context
//        PlaybackRequestContext.begun(context1)
//        assertCurrentContext(context1)
//        
//        // Try to complete context2
//        PlaybackRequestContext.completed(context2)
//        
//        // context1 should still be the current context
//        assertCurrentContext(context1)
//        
//        // Complete context1
//        PlaybackRequestContext.completed(context1)
//        assertNotCurrentContext(context1)
//        XCTAssertNil(PlaybackRequestContext.currentContext)
//        
//        // ------------------------
//        
//        // Make context2 the current context
//        PlaybackRequestContext.begun(context2)
//        assertCurrentContext(context2)
//        
//        // Try to complete context3
//        PlaybackRequestContext.completed(context3)
//        
//        // context2 should still be the current context
//        assertCurrentContext(context2)
//        
//        // Complete context2
//        PlaybackRequestContext.completed(context2)
//        assertNotCurrentContext(context2)
//        XCTAssertNil(PlaybackRequestContext.currentContext)
//        
//        // ------------------------
//        
//        // Make context3 the current context
//        PlaybackRequestContext.begun(context3)
//        assertCurrentContext(context3)
//        
//        // Try to complete context2
//        PlaybackRequestContext.completed(context2)
//        
//        // context3 should still be the current context
//        assertCurrentContext(context3)
//        
//        // Complete context3
//        PlaybackRequestContext.completed(context3)
//        assertNotCurrentContext(context3)
//        XCTAssertNil(PlaybackRequestContext.currentContext)
//    }
//    
//    func testGapsAndDelay_nonImplicitGaps() {
//        
//        let nonImplicitGap1: PlaybackGap = PlaybackGap(5, .afterTrack)
//        let nonImplicitGap2: PlaybackGap = PlaybackGap(3, .beforeTrack)
//        
//        let implicitGap: PlaybackGap = PlaybackGap(10, .afterTrack, .implicit)
//        
//        let track1 = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let track2 = createTrack(title: "Sub-Sea Engineering", duration: 360)
//        
//        let context = PlaybackRequestContext(.playing, track1, 283.34686234, track2, PlaybackParams.defaultParams())
//        
//        context.addGap(nonImplicitGap1)
//        XCTAssertEqual(context.delay!, nonImplicitGap1.duration, accuracy: 0.001)
//        
//        // The implicit gap should be ignored because there is already a non-implicit gap defined.
//        context.addGap(implicitGap)
//        XCTAssertEqual(context.delay!, nonImplicitGap1.duration, accuracy: 0.001)
//        
//        context.addGap(nonImplicitGap2)
//        XCTAssertEqual(context.delay!, nonImplicitGap1.duration + nonImplicitGap2.duration, accuracy: 0.001)
//    }
//    
//    func testGapsAndDelay_implicitGap() {
//        
//        let implicitGap: PlaybackGap = PlaybackGap(10, .afterTrack, .implicit)
//        
//        let track1 = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let track2 = createTrack(title: "Sub-Sea Engineering", duration: 360)
//        
//        let context = PlaybackRequestContext(.playing, track1, 283.34686234, track2, PlaybackParams.defaultParams())
//        
//        // The implicit gap should be added because there are no non-implicit gaps defined.
//        context.addGap(implicitGap)
//        XCTAssertEqual(context.delay!, implicitGap.duration, accuracy: 0.001)
//    }
//    
//    func testRemoveAllGaps_noGapsDefined() {
//        
//        let track1 = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let track2 = createTrack(title: "Sub-Sea Engineering", duration: 360)
//        
//        let context = PlaybackRequestContext(.playing, track1, 283.34686234, track2, PlaybackParams.defaultParams())
//        
//        XCTAssertNil(context.delay)
//        
//        context.removeAllGaps()
//        XCTAssertNil(context.delay)
//    }
//    
//    func testRemoveAllGaps_nonImplicitGaps() {
//        
//        let nonImplicitGap1: PlaybackGap = PlaybackGap(5, .afterTrack)
//        let nonImplicitGap2: PlaybackGap = PlaybackGap(3, .beforeTrack)
//        
//        let track1 = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let track2 = createTrack(title: "Sub-Sea Engineering", duration: 360)
//        
//        let context = PlaybackRequestContext(.playing, track1, 283.34686234, track2, PlaybackParams.defaultParams())
//        
//        context.addGap(nonImplicitGap1)
//        XCTAssertEqual(context.delay!, nonImplicitGap1.duration, accuracy: 0.001)
//        
//        context.addGap(nonImplicitGap2)
//        XCTAssertEqual(context.delay!, nonImplicitGap1.duration + nonImplicitGap2.duration, accuracy: 0.001)
//        
//        context.removeAllGaps()
//        XCTAssertNil(context.delay)
//    }
//    
//    func testRemoveAllGaps_implicitGap() {
//        
//        let implicitGap: PlaybackGap = PlaybackGap(10, .afterTrack, .implicit)
//        
//        let track1 = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let track2 = createTrack(title: "Sub-Sea Engineering", duration: 360)
//        
//        let context = PlaybackRequestContext(.playing, track1, 283.34686234, track2, PlaybackParams.defaultParams())
//        
//        context.addGap(implicitGap)
//        XCTAssertEqual(context.delay!, implicitGap.duration, accuracy: 0.001)
//        
//        context.removeAllGaps()
//        XCTAssertNil(context.delay)
//    }
//    
//    func testClearContext_noCurrentContext() {
//        
//        XCTAssertNil(PlaybackRequestContext.currentContext)
//        
//        PlaybackRequestContext.clearCurrentContext()
//        XCTAssertNil(PlaybackRequestContext.currentContext)
//    }
//    
//    func testClearContext_hasCurrentContext() {
//        
//        let track = createTrack(title: "Hydropoetry Cathedra", duration: 597)
//        let context = PlaybackRequestContext(.noTrack, nil, 0, track, PlaybackParams.defaultParams())
//        
//        PlaybackRequestContext.begun(context)
//        assertCurrentContext(context)
//        
//        PlaybackRequestContext.clearCurrentContext()
//        assertNotCurrentContext(context)
//        XCTAssertNil(PlaybackRequestContext.currentContext)
//    }
//}
