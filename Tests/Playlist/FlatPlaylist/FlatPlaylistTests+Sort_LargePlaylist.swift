//
//  FlatPlaylistTests+Sort_LargePlaylist.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class FlatPlaylistTests_Sort_LargePlaylist: FlatPlaylistTestCase {
    
    private var playlistSizes: [Int] {
        
        (1...1000).map {_ in Int.random(in: 2...100)} +
            (1...10).map {_ in Int.random(in: 101...1000)} +
            (1...3).map {_ in Int.random(in: 1001...10000)}
    }
    
    func test_byName() {
        doTest(fields: .name, verificationFunction: isPlaylistSortedByName(ascending:))
    }
    
    func test_byDuration() {
        doTest(fields: .duration, verificationFunction: isPlaylistSortedByDuration(ascending:))
    }
    
    func test_byArtistAndName() {
        doTest(fields: .artist, .name, verificationFunction: isPlaylistSortedByArtistAndName(ascending:))
    }
    
    private func doTest(fields: SortField..., verificationFunction: @escaping (Bool) -> Bool) {
        
        for (playlistSize, ascending) in permute(playlistSizes, [true, false]) {
            
            playlist.clear()
            assertEmptyPlaylist()
            
            let tracks = createNRandomTracks(count: playlistSize).shuffled()
            tracks.forEach {_ = self.playlist.addTrack($0)}
            
            let tracksSort = TracksSort().withFields(fields).withOrder(ascending ? .ascending : .descending)
            let sort = Sort().withTracksSort(tracksSort)
            
            playlist.sort(sort)
            
            XCTAssertTrue(verificationFunction(ascending))
        }
    }
    
    private func isPlaylistSortedByName(ascending: Bool) -> Bool {
        
        let actualTracks = playlist.tracks
        
        let sortedTracks = ascending ?
            actualTracks.sorted(by: {$0.displayName < $1.displayName}) :
            actualTracks.sorted(by: {$0.displayName > $1.displayName})
        
        return actualTracks.elementsEqual(sortedTracks)
    }
    
    private func isPlaylistSortedByDuration(ascending: Bool) -> Bool {
        
        let actualTracks = playlist.tracks
        
        let sortedTracks = ascending ?
            actualTracks.sorted(by: {$0.duration < $1.duration}) :
            actualTracks.sorted(by: {$0.duration > $1.duration})
        
        return actualTracks.elementsEqual(sortedTracks)
    }
    
    private func isPlaylistSortedByArtistAndName(ascending: Bool) -> Bool {
        
        let actualTracks = playlist.tracks
        
        let sortedTracks = ascending ?
            
            actualTracks.sorted(by: {
                
                if ($0.artist ?? "") < ($1.artist ?? "") {
                    return true
                }
                
                if ($0.artist ?? "") > ($1.artist ?? "") {
                    return false
                }
                
                return $0.displayName < $1.displayName
                
            }) :
            
            actualTracks.sorted(by: {
                
                if ($0.artist ?? "") > ($1.artist ?? "") {
                    return true
                }
                
                if ($0.artist ?? "") < ($1.artist ?? "") {
                    return false
                }
                
                return $0.displayName > $1.displayName
                
            })
        
        return actualTracks.elementsEqual(sortedTracks)
    }
}
