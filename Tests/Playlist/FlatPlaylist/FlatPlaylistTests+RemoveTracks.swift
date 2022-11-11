//
//  FlatPlaylistTests+RemoveTracks.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class FlatPlaylistTests_RemoveTracks: FlatPlaylistTestCase {
    
    // MARK: Remove tracks by index --------------------------------
    
    func testRemoveTracksByIndex_emptyPlaylist() {
        
        assertEmptyPlaylist()
        
        let removedTracks = playlist.removeTracks(IndexSet([0, 1]))
        XCTAssertTrue(removedTracks.isEmpty)
    }
    
    func testRemoveTracksByIndex_noIndices() {
        
        assertEmptyPlaylist()
        
        addNTracks(10)
        
        let removedTracks = playlist.removeTracks(IndexSet())
        XCTAssertTrue(removedTracks.isEmpty)
    }
    
    func testRemoveTracksByIndex_fixedSizeAndIndices() {
        
        assertEmptyPlaylist()
        
        addNTracks(5)
        let playlistDurationBeforeRemove: Double = playlist.duration
        
        let trackAt0: Track = playlist.tracks[0]
        let trackAt1: Track = playlist.tracks[1]
        let trackAt2: Track = playlist.tracks[2]
        let trackAt3: Track = playlist.tracks[3]
        let trackAt4: Track = playlist.tracks[4]
        
        let removedTrackIndices = IndexSet([1, 3])
        let removedTracks = Set(playlist.removeTracks(removedTrackIndices))
        let playlistDurationAfterRemove: Double = playlist.duration
        
        // Verify the removed tracks collection.
        XCTAssertEqual(removedTracks.count, removedTrackIndices.count)
        XCTAssertEqual(removedTracks, Set(removedTracks))
        
        // The removed tracks should no longer be in the playlist.
        XCTAssertNil(playlist.indexOfTrack(trackAt1))
        XCTAssertNil(playlist.indexOfTrack(trackAt3))
        
        // Verify the updated playlist size and duration.
        XCTAssertEqual(playlist.size, 3)
        XCTAssertEqual(playlistDurationBeforeRemove - playlistDurationAfterRemove,
                       trackAt1.duration + trackAt3.duration, accuracy: 0.001)
        
        // Verify the order of tracks after the remove() operation.
        
        XCTAssertEqual(playlist.tracks[0], trackAt0)    // Track at 0 didn't move.
        XCTAssertEqual(playlist.tracks[1], trackAt2)    // Track at 2 moved -> to 1
        XCTAssertEqual(playlist.tracks[2], trackAt4)    // Track at 4 moved -> to 2
    }
    
    func testRemoveTracksByIndex_arbitrarySizeAndIndices() {
        doTestRemoveTracksByIndex_arbitrarySizeAndIndices(repeatCount: 10)
    }
    
    func testRemoveTracksByIndex_arbitrarySizeAndIndices_longRunning() {
        doTestRemoveTracksByIndex_arbitrarySizeAndIndices(repeatCount: 100)
    }
    
    private func doTestRemoveTracksByIndex_arbitrarySizeAndIndices(repeatCount: Int = 1) {
        
        for _ in 0..<repeatCount {
            
            assertEmptyPlaylist()
            
            let originalPlaylistSize: Int = Int.random(in: 3...10000)
            
            addNTracks(originalPlaylistSize)
            
            // Create a copy of the original playlist tracks for later comparison.
            let originalPlaylistTracks: [Track] = Array(playlist.tracks)
            let playlistDurationBeforeRemove: Double = playlist.duration
            
            // The tracks to be removed (don't remove all of them).
            let numberOfTracksToRemove: Int = Int.random(in: 1..<originalPlaylistSize)
            let removedTrackIndices = Set((1...numberOfTracksToRemove).map {_ in Int.random(in: 0..<originalPlaylistSize)})
            let removedTracks: Set<Track> = Set(removedTrackIndices.map {playlist.tracks[$0]})
            let removedTracksDurationSum: Double = (removedTracks.map {$0.duration}).sum()
            
            let removedTracksResult = Set(playlist.removeTracks(IndexSet(removedTrackIndices)))
            let playlistDurationAfterRemove: Double = playlist.duration
            
            // Verify the removed tracks collection.
            XCTAssertEqual(removedTracksResult, removedTracks)
            
            for track in removedTracks {
                
                // The removed tracks should no longer be in the playlist.
                XCTAssertNil(playlist.indexOfTrack(track))
            }
            
            // Verify the updated playlist size and duration.
            XCTAssertEqual(playlist.size, originalPlaylistSize - removedTracks.count)
            
            XCTAssertEqual(playlistDurationBeforeRemove - playlistDurationAfterRemove,
                           removedTracksDurationSum, accuracy: 0.001)
            
            // Verify the new order of tracks.
            var newIndexInPlaylist: Int = 0
            for index in 0..<originalPlaylistSize {
                
                if !removedTrackIndices.contains(index) {
                    
                    // For all tracks that were not removed, verify their
                    // new location in the playlist.
                    XCTAssertEqual(originalPlaylistTracks[index], playlist.tracks[newIndexInPlaylist])
                    newIndexInPlaylist.increment()
                }
            }
            
            playlist.clear()
        }
    }
    
    func testRemoveTracksByIndex_firstNIndices() {
        doTestRemoveTracksByIndex_firstNIndices(repeatCount: 10)
    }
    
    private func doTestRemoveTracksByIndex_firstNIndices(repeatCount: Int = 1) {
        
        for _ in 0..<repeatCount {
            
            assertEmptyPlaylist()
            
            let originalPlaylistSize: Int = Int.random(in: 10...10000)
            
            addNTracks(originalPlaylistSize)
            
            // Create a copy of the original playlist tracks for later comparison.
            let originalPlaylistTracks: [Track] = Array(playlist.tracks)
            let playlistDurationBeforeRemove: Double = playlist.duration
            
            // The tracks to be removed (don't remove all of them).
            let numberOfTracksToRemove: Int = Int.random(in: 2..<(originalPlaylistSize / 2))
            let removedTrackIndices = IndexSet(0..<numberOfTracksToRemove)
            let removedTracks: Set<Track> = Set(removedTrackIndices.map {playlist.tracks[$0]})
            let removedTracksDurationSum: Double = (removedTracks.map {$0.duration}).sum()
            
            let removedTracksResult = Set(playlist.removeTracks(IndexSet(removedTrackIndices)))
            let playlistDurationAfterRemove: Double = playlist.duration
            
            // Verify the removed tracks collection.
            XCTAssertEqual(removedTracksResult, removedTracks)
            
            for track in removedTracks {
                
                // The removed tracks should no longer be in the playlist.
                XCTAssertNil(playlist.indexOfTrack(track))
            }
            
            // Verify the updated playlist size and duration.
            XCTAssertEqual(playlist.size, originalPlaylistSize - removedTracks.count)
            
            XCTAssertEqual(playlistDurationBeforeRemove - playlistDurationAfterRemove,
                           removedTracksDurationSum, accuracy: 0.001)
            
            // Verify the new order of tracks.
            for index in numberOfTracksToRemove..<originalPlaylistSize {
                
                let newIndexInPlaylist = index - numberOfTracksToRemove
                
                // For all tracks that were not removed, verify their
                // new location in the playlist.
                XCTAssertEqual(originalPlaylistTracks[index], playlist.tracks[newIndexInPlaylist])
            }
            
            playlist.clear()
        }
    }
    
    func testRemoveTracksByIndex_lastNIndices() {
        doTestRemoveTracksByIndex_lastNIndices(repeatCount: 10)
    }
    
    private func doTestRemoveTracksByIndex_lastNIndices(repeatCount: Int = 1) {
        
        for _ in 0..<repeatCount {
            
            assertEmptyPlaylist()
            
            let originalPlaylistSize: Int = Int.random(in: 10...10000)
            
            addNTracks(originalPlaylistSize)
            
            // Create a copy of the original playlist tracks for later comparison.
            let originalPlaylistTracks: [Track] = Array(playlist.tracks)
            let playlistDurationBeforeRemove: Double = playlist.duration
            
            // The tracks to be removed (don't remove all of them).
            let numberOfTracksToRemove: Int = Int.random(in: 2..<(originalPlaylistSize / 2))
            let firstRemovedTrackIndex: Int = originalPlaylistSize - numberOfTracksToRemove
            
            let removedTrackIndices = IndexSet(firstRemovedTrackIndex..<originalPlaylistSize)
            let removedTracks: Set<Track> = Set(removedTrackIndices.map {playlist.tracks[$0]})
            let removedTracksDurationSum: Double = (removedTracks.map {$0.duration}).sum()
            
            let removedTracksResult = Set(playlist.removeTracks(IndexSet(removedTrackIndices)))
            let playlistDurationAfterRemove: Double = playlist.duration
            
            // Verify the removed tracks collection.
            XCTAssertEqual(removedTracksResult, removedTracks)
            
            for track in removedTracks {
                
                // The removed tracks should no longer be in the playlist.
                XCTAssertNil(playlist.indexOfTrack(track))
            }
            
            // Verify the updated playlist size and duration.
            XCTAssertEqual(playlist.size, originalPlaylistSize - removedTracks.count)
            
            XCTAssertEqual(playlistDurationBeforeRemove - playlistDurationAfterRemove,
                           removedTracksDurationSum, accuracy: 0.001)
            
            // Verify the new order of tracks.
            for index in 0..<firstRemovedTrackIndex {
                
                // For all tracks that were not removed, verify their
                // new location in the playlist (same location).
                XCTAssertEqual(originalPlaylistTracks[index], playlist.tracks[index])
            }
            
            playlist.clear()
        }
    }
    
    func testRemoveTracksByIndex_allTracks() {
        
        assertEmptyPlaylist()
        
        let originalPlaylistSize: Int = Int.random(in: 3...10000)
        addNTracks(originalPlaylistSize)
        
        // The tracks to be removed (don't remove all of them).
        let removedTracks: [Track] = Array(playlist.tracks)
        let removedTracksResult = playlist.removeTracks(IndexSet(playlist.tracks.indices))
        
        // Verify the removed tracks collection.
        XCTAssertEqual(Set(removedTracksResult), Set(removedTracks))
        
        for track in removedTracks {
            
            // The removed tracks should no longer be in the playlist.
            XCTAssertNil(playlist.indexOfTrack(track))
        }
        
        // Verify the updated playlist size and duration.
        assertEmptyPlaylist()
    }
    
    // MARK: Remove tracks by Track --------------------------------
    
    func testRemoveTracksByTrack_emptyPlaylist() {
        
        assertEmptyPlaylist()
        
        let randomTracks = createNRandomTracks(count: 2)
        
        let removedTracks = playlist.removeTracks(randomTracks)
        XCTAssertTrue(removedTracks.isEmpty)
    }
    
    func testRemoveTracksByTrack_noTracks() {
        
        assertEmptyPlaylist()
        
        addNTracks(10)
        
        let removedTracks = playlist.removeTracks([Track]())
        XCTAssertTrue(removedTracks.isEmpty)
    }
    
    func testRemoveTracksByTrack_fixedTracksCount() {
        
        assertEmptyPlaylist()
        
        addNTracks(5)
        let playlistDurationBeforeRemove: Double = playlist.duration
        
        let trackAt0: Track = playlist.tracks[0]
        let trackAt1: Track = playlist.tracks[1]
        let trackAt2: Track = playlist.tracks[2]
        let trackAt3: Track = playlist.tracks[3]
        let trackAt4: Track = playlist.tracks[4]
        
        let removedTracks = [trackAt1, trackAt3]
        let removedTracksResult = playlist.removeTracks(removedTracks)
        let playlistDurationAfterRemove: Double = playlist.duration
        
        // Verify the removed tracks collection.
        XCTAssertEqual(removedTracksResult.count, removedTracks.count)
        XCTAssertEqual(Set(removedTracksResult), Set([1, 3]))
        
        // The removed tracks should no longer be in the playlist.
        XCTAssertNil(playlist.indexOfTrack(trackAt1))
        XCTAssertNil(playlist.indexOfTrack(trackAt3))
        
        // Verify the updated playlist size and duration.
        XCTAssertEqual(playlist.size, 3)
        XCTAssertEqual(playlistDurationBeforeRemove - playlistDurationAfterRemove,
                       trackAt1.duration + trackAt3.duration, accuracy: 0.001)
        
        // Verify the order of tracks after the remove() operation.
        
        XCTAssertEqual(playlist.tracks[0], trackAt0)    // Track at 0 didn't move.
        XCTAssertEqual(playlist.tracks[1], trackAt2)    // Track at 2 moved -> to 1
        XCTAssertEqual(playlist.tracks[2], trackAt4)    // Track at 4 moved -> to 2
    }
    
    func testRemoveTracksByTrack_arbitrarySizeAndIndices() {
        doTestRemoveTracksByTrack_arbitrarySizeAndIndices(repeatCount: 10)
    }
    
    func testRemoveTracksByTrack_arbitrarySizeAndIndices_longRunning() {
        doTestRemoveTracksByTrack_arbitrarySizeAndIndices(repeatCount: 100)
    }
    
    private func doTestRemoveTracksByTrack_arbitrarySizeAndIndices(repeatCount: Int = 1) {
        
        for _ in 0..<repeatCount {
            
            assertEmptyPlaylist()
            
            let originalPlaylistSize: Int = Int.random(in: 3...10000)
            
            addNTracks(originalPlaylistSize)
            
            // Create a copy of the original playlist tracks for later comparison.
            let originalPlaylistTracks: [Track] = Array(playlist.tracks)
            let playlistDurationBeforeRemove: Double = playlist.duration
            
            // The tracks to be removed (don't remove all of them).
            let numberOfTracksToRemove: Int = Int.random(in: 1..<originalPlaylistSize)
            let removedTrackIndices = Set((1...numberOfTracksToRemove).map {_ in Int.random(in: 0..<originalPlaylistSize)})
            let removedTracks: [Track] = removedTrackIndices.map {playlist.tracks[$0]}
            let removedTracksDurationSum: Double = (removedTracks.map {$0.duration}).sum()
            
            let removedTracksResult = Set(playlist.removeTracks(removedTracks))
            let playlistDurationAfterRemove: Double = playlist.duration
            
            // Verify the removed tracks collection.
            XCTAssertEqual(removedTracksResult.count, removedTracks.count)
            
            for index in removedTrackIndices {
                
                // The removed tracks should no longer be in the playlist.
                XCTAssertTrue(removedTracksResult.contains(index))
                XCTAssertNil(playlist.indexOfTrack(originalPlaylistTracks[index]))
            }
            
            // Verify the updated playlist size and duration.
            XCTAssertEqual(playlist.size, originalPlaylistSize - removedTracks.count)
            
            XCTAssertEqual(playlistDurationBeforeRemove - playlistDurationAfterRemove,
                           removedTracksDurationSum, accuracy: 0.001)
            
            // Verify the new order of tracks.
            var newIndexInPlaylist: Int = 0
            for index in 0..<originalPlaylistSize {
                
                if !removedTrackIndices.contains(index) {
                    
                    // For all tracks that were not removed, verify their
                    // new location in the playlist.
                    XCTAssertEqual(originalPlaylistTracks[index], playlist.tracks[newIndexInPlaylist])
                    newIndexInPlaylist.increment()
                }
            }
            
            playlist.clear()
        }
    }
    
    func testRemoveTracksByTrack_firstNIndices() {
        doTestRemoveTracksByIndex_firstNIndices(repeatCount: 10)
    }
    
    private func doTestRemoveTracksByTrack_firstNIndices(repeatCount: Int = 1) {
        
        for _ in 0..<repeatCount {
            
            assertEmptyPlaylist()
            
            let originalPlaylistSize: Int = Int.random(in: 10...10000)
            
            addNTracks(originalPlaylistSize)
            
            // Create a copy of the original playlist tracks for later comparison.
            let originalPlaylistTracks: [Track] = Array(playlist.tracks)
            let playlistDurationBeforeRemove: Double = playlist.duration
            
            // The tracks to be removed (don't remove all of them).
            let numberOfTracksToRemove: Int = Int.random(in: 2..<(originalPlaylistSize / 2))
            let removedTrackIndices = Set(IndexSet(0..<numberOfTracksToRemove))
            let removedTracks: [Track] = removedTrackIndices.map {playlist.tracks[$0]}
            let removedTracksDurationSum: Double = (removedTracks.map {$0.duration}).sum()
            
            let removedTracksResult = Set(playlist.removeTracks(removedTracks))
            let playlistDurationAfterRemove: Double = playlist.duration
            
            // Verify the removed tracks collection.
            XCTAssertEqual(removedTracksResult, removedTrackIndices)
            
            for track in removedTracks {
                
                // The removed tracks should no longer be in the playlist.
                XCTAssertNil(playlist.indexOfTrack(track))
            }
            
            // Verify the updated playlist size and duration.
            XCTAssertEqual(playlist.size, originalPlaylistSize - removedTracks.count)
            
            XCTAssertEqual(playlistDurationBeforeRemove - playlistDurationAfterRemove,
                           removedTracksDurationSum, accuracy: 0.001)
            
            // Verify the new order of tracks.
            for index in numberOfTracksToRemove..<originalPlaylistSize {
                
                let newIndexInPlaylist = index - numberOfTracksToRemove
                
                // For all tracks that were not removed, verify their
                // new location in the playlist.
                XCTAssertEqual(originalPlaylistTracks[index], playlist.tracks[newIndexInPlaylist])
            }
            
            playlist.clear()
        }
    }
    
    func testRemoveTracksByTrack_lastNIndices() {
        doTestRemoveTracksByTrack_lastNIndices(repeatCount: 10)
    }
    
    private func doTestRemoveTracksByTrack_lastNIndices(repeatCount: Int = 1) {
        
        for _ in 0..<repeatCount {
            
            assertEmptyPlaylist()
            
            let originalPlaylistSize: Int = Int.random(in: 10...10000)
            
            addNTracks(originalPlaylistSize)
            
            // Create a copy of the original playlist tracks for later comparison.
            let originalPlaylistTracks: [Track] = Array(playlist.tracks)
            let playlistDurationBeforeRemove: Double = playlist.duration
            
            // The tracks to be removed (don't remove all of them).
            let numberOfTracksToRemove: Int = Int.random(in: 2..<(originalPlaylistSize / 2))
            let firstRemovedTrackIndex: Int = originalPlaylistSize - numberOfTracksToRemove
            
            let removedTrackIndices = IndexSet(firstRemovedTrackIndex..<originalPlaylistSize)
            let removedTracks: [Track] = removedTrackIndices.map {playlist.tracks[$0]}
            let removedTracksDurationSum: Double = (removedTracks.map {$0.duration}).sum()
            
            let removedTracksResult = playlist.removeTracks(removedTracks)
            let playlistDurationAfterRemove: Double = playlist.duration
            
            // Verify the removed tracks collection.
            XCTAssertEqual(removedTracksResult, removedTrackIndices)
            
            for track in removedTracks {
                
                // The removed tracks should no longer be in the playlist.
                XCTAssertNil(playlist.indexOfTrack(track))
            }
            
            // Verify the updated playlist size and duration.
            XCTAssertEqual(playlist.size, originalPlaylistSize - removedTracks.count)
            
            XCTAssertEqual(playlistDurationBeforeRemove - playlistDurationAfterRemove,
                           removedTracksDurationSum, accuracy: 0.001)
            
            // Verify the new order of tracks.
            for index in 0..<firstRemovedTrackIndex {
                
                // For all tracks that were not removed, verify their
                // new location in the playlist (same location).
                XCTAssertEqual(originalPlaylistTracks[index], playlist.tracks[index])
            }
            
            playlist.clear()
        }
    }
    
    func testRemoveTracksByTrack_allTracks() {
        
        assertEmptyPlaylist()
        
        let originalPlaylistSize: Int = Int.random(in: 3...10000)
        addNTracks(originalPlaylistSize)
        
        // The tracks to be removed (don't remove all of them).
        let removedTracks: [Track] = Array(playlist.tracks)
        let removedTracksResult = playlist.removeTracks(IndexSet(playlist.tracks.indices))
        
        // Verify the removed tracks collection.
        XCTAssertEqual(Set(removedTracksResult), Set(removedTracks))
        
        for track in removedTracks {
            
            // The removed tracks should no longer be in the playlist.
            XCTAssertNil(playlist.indexOfTrack(track))
        }
        
        // Verify the updated playlist size and duration.
        assertEmptyPlaylist()
    }
}
