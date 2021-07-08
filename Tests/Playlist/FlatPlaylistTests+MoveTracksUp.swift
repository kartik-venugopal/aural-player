//
//  FlatPlaylist+MoveTracksUp.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class FlatPlaylistTests_MoveTracksUp: FlatPlaylistTestCase {
    
    func test_emptyPlaylist() {
        
        assertEmptyPlaylist()
        
        var result = playlist.moveTracksUp(IndexSet([0, 1]))
        XCTAssertTrue(result.playlistType == .tracks)
        XCTAssertTrue(result.results.isEmpty)
        
        result = playlist.moveTracksUp(IndexSet([]))
        XCTAssertTrue(result.playlistType == .tracks)
        XCTAssertTrue(result.results.isEmpty)
    }
    
    func test_noIndices() {
        
        let emptySet = Set<Int>()
        
        for _ in 1...10 {
            doTest_noneCanMove(playlistSize: randomPlaylistSize(), movedTrackIndices: emptySet)
        }
    }
    
    // MARK: Tests with a single index ------------------------------
    
    func test_singleIndex() {
        
        for _ in 1...10 {
            
            let playlistSize = randomPlaylistSize()
            doTest_allCanMove(playlistSize: playlistSize,
                                          movedTrackIndices: Set([.random(in: 1..<playlistSize)]))
        }
    }
    
    func test_singleIndexAtTop_cannotMove() {
        
        let zeroIndexSet = Set([0])
        
        for _ in 1...10 {
            doTest_noneCanMove(playlistSize: randomPlaylistSize(), movedTrackIndices: zeroIndexSet)
        }
    }
    
    // MARK: Tests with multiple arbitrary indices ------------------------------
    
    func test_arbitraryIndices() {
        
        for _ in 1...10 {
            
            let playlistSize = randomPlaylistSize()
            
            doTest_someCanMove(playlistSize: playlistSize,
                                          movedTrackIndices: Set(randomIndices(playlistSize: playlistSize)))
        }
    }
    
    func test_arbitraryIndices_singleTrackAtTopCannotMove() {
        
        for _ in 1...10 {
            
            let playlistSize = randomPlaylistSize()
            let indices = Set([0] + randomIndices_allMovable(playlistSize: playlistSize))
            doTest_someCanMove(playlistSize: playlistSize, movedTrackIndices: indices)
        }
    }
    
    func test_arbitraryIndices_contiguousBlockAtTopCannotMove() {
        
        for _ in 1...10 {
            
            let playlistSize = randomPlaylistSize()
            
            let lastBlockIndex = Int.random(in: 1..<playlistSize)
            let indices = Set(Array(0...lastBlockIndex) + randomIndices_allMovable(playlistSize: playlistSize))
            doTest_someCanMove(playlistSize: playlistSize, movedTrackIndices: indices)
        }
    }
    
    func test_arbitraryIndices_allMovable() {
        
        for _ in 1...10 {
            
            let playlistSize = randomPlaylistSize()
            doTest_allCanMove(playlistSize: playlistSize,
                                          movedTrackIndices: Set(randomIndices_allMovable(playlistSize: playlistSize)))
        }
    }
    
    // MARK: Tests with multiple indices (contiguous or non-contiguous) ------------------------------
    
    func test_nonContiguousIndices_allMovable() {
        
        for _ in 1...10 {
            
            let playlistSize = randomPlaylistSize()
            
            doTest_allCanMove(playlistSize: playlistSize,
                                          movedTrackIndices: Set(randomNonContiguousIndices_allMovable(playlistSize: playlistSize)))
        }
    }
    
    func test_contiguousIndices_allMovable() {
        
        for _ in 1...10 {
            
            let playlistSize = randomPlaylistSize()
            
            doTest_allCanMove(playlistSize: playlistSize,
                                          movedTrackIndices: Set(randomContiguousIndices_movable(playlistSize: playlistSize)))
        }
    }
    
    func test_contiguousIndicesAtTop_cannotMove() {
        
        for _ in 1...10 {
            
            let playlistSize = randomPlaylistSize()
            let lastIndex = Int.random(in: 1..<playlistSize)
            doTest_noneCanMove(playlistSize: playlistSize, movedTrackIndices: Set(0...lastIndex))
        }
    }
    
    func test_allIndices_cannotMove() {
        
        for _ in 1...10 {
            
            let playlistSize = randomPlaylistSize()
            doTest_noneCanMove(playlistSize: playlistSize, movedTrackIndices: Set(0..<playlistSize))
        }
    }
    
    // MARK: Helper functions ------------------------------
    
    private func doTest_allCanMove(playlistSize: Int, movedTrackIndices: Set<Int>, actualMovedIndices: Set<Int>? = nil) {
        
        playlist.clear()
        assertEmptyPlaylist()
        
        addNTracks(playlistSize)
        
        // Create a copy of the original playlist tracks for later comparison.
        var originalPlaylistTracks: [Track] = Array(playlist.tracks)
        
        // Store values to be used to perform verifications later.
        var sourceDestinationMap: [Int: Int] = [:]
        var destinationTrackMap: [Int: Track] = [:]
        
        for index in actualMovedIndices ?? movedTrackIndices {
            
            let destinationIndex = index - 1
            
            sourceDestinationMap[index] = destinationIndex
            destinationTrackMap[destinationIndex] = playlist.tracks[index]
        }
        
        let results = playlist.moveTracksUp(IndexSet(movedTrackIndices))
        let playlistTracksAfterMove: [Track] = Array(playlist.tracks)
        
        // Verify the results of the move operation.
        XCTAssertTrue(results.playlistType == .tracks)
        XCTAssertEqual(results.results.count, actualMovedIndices?.count ?? movedTrackIndices.count)
        
        // Perform the move operations, one by one, on the original playlist tracks array,
        // to mimic the move operation on the playlist, as dictated by the results.
        
        // Sort the results in ascending order by source index.
        let sortedResults = results.results.sorted(by: {$0.sourceIndex < $1.sourceIndex})
        for result in sortedResults {
            
            // Verify that the actual destination index matches the expected one.
            XCTAssertEqual(result.destinationIndex, sourceDestinationMap[result.sourceIndex])
            
            let removedTrack = originalPlaylistTracks.remove(at: result.sourceIndex)
            originalPlaylistTracks.insert(removedTrack, at: result.destinationIndex)
        }

        // Now, compare the 2 arrays and verify that their tracks order is exactly equal.
        XCTAssertEqual(playlistTracksAfterMove, originalPlaylistTracks)
    }
    
    private func doTest_someCanMove(playlistSize: Int, movedTrackIndices: Set<Int>) {

        let firstMovableIndex = (0..<playlistSize).first(where: {!movedTrackIndices.contains($0)}) ?? 0
        let actualMovedIndices = movedTrackIndices.filter {$0 >= firstMovableIndex}
        
        doTest_allCanMove(playlistSize: playlistSize, movedTrackIndices: movedTrackIndices, actualMovedIndices: actualMovedIndices)
    }
    
    private func doTest_noneCanMove(playlistSize: Int, movedTrackIndices: Set<Int>) {
        
        playlist.clear()
        assertEmptyPlaylist()
        
        addNTracks(playlistSize)
        
        // Create a copy of the original playlist tracks for later comparison.
        let originalPlaylistTracks: [Track] = Array(playlist.tracks)
        
        let results = playlist.moveTracksUp(IndexSet(movedTrackIndices))
        
        // Verify the results of the move operation.
        XCTAssertTrue(results.playlistType == .tracks)
        XCTAssertTrue(results.results.isEmpty)
        
        // Now, compare the 2 arrays and verify that their tracks order is exactly equal.
        XCTAssertEqual(playlist.tracks, originalPlaylistTracks)
    }
    
    private func randomIndices(playlistSize: Int) -> [Int] {
        
        let numIndices = Int.random(in: 1...playlistSize)
        return (1...numIndices).map {_ in Int.random(in: 0..<playlistSize)}
    }
    
    private func randomIndices_allMovable(playlistSize: Int) -> [Int] {
        
        let lastIndex = Int.random(in: 2..<playlistSize)
        let firstIndex = Int.random(in: 1..<lastIndex)

        let numIndices = Int.random(in: 1...(lastIndex - firstIndex))
        
        return (1...numIndices).map {_ in Int.random(in: firstIndex...lastIndex)}
    }
    
    private func randomNonContiguousIndices_allMovable(playlistSize: Int) -> [Int] {
        
        let lastIndex = Int.random(in: 2..<playlistSize)
        let firstIndex = Int.random(in: 1..<lastIndex)
        
        var curIndex: Int = lastIndex
        var indices: [Int] = []
        
        while curIndex > firstIndex {
            
            indices.append(curIndex)
            
            // Skip some indices so that the indices are non-contiguous.
            curIndex -= Int.random(in: 2...max(2, ((lastIndex - firstIndex) / 10)))
        }
        
        return indices
    }
    
    private func randomContiguousIndices_movable(playlistSize: Int) -> [Int] {
        
        let lastIndex = Int.random(in: 2..<playlistSize)
        let firstIndex = Int.random(in: 1..<lastIndex)
        
        return Array(firstIndex...lastIndex)
    }
    
    private func randomPlaylistSize() -> Int {
        .random(in: 10...10000)
    }
}
