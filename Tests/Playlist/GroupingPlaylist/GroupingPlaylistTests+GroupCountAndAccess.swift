//
//  GroupingPlaylistTests+GroupCountAndAccess.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class GroupingPlaylistTests_GroupCountAndAccess: GroupingPlaylistTestCase {
    
    func test_artistsPlaylist() {
        
        let playlist = GroupingPlaylist(.artists)
        XCTAssertEqual(playlist.numberOfGroups, 0)
        
        for numGroups in 1...1000 {
            
            let tracks = createNTracks(.random(in: 1...15), artist: uniqueGroupName())
            doAddTracks(tracks, to: playlist, expectedGroupCount: numGroups)
        }
        
        removeAllGroups(from: playlist)
    }
    
    func test_albumsPlaylist() {
        
        let playlist = GroupingPlaylist(.albums)
        XCTAssertEqual(playlist.numberOfGroups, 0)
        
        for numGroups in 1...1000 {
            
            let tracks = createNTracks(.random(in: 1...15), album: uniqueGroupName())
            doAddTracks(tracks, to: playlist, expectedGroupCount: numGroups)
        }
        
        removeAllGroups(from: playlist)
    }
    
    func test_genresPlaylist() {
        
        let playlist = GroupingPlaylist(.genres)
        XCTAssertEqual(playlist.numberOfGroups, 0)
        
        for numGroups in 1...1000 {
            
            let tracks = createNTracks(.random(in: 1...15), genre: uniqueGroupName())
            doAddTracks(tracks, to: playlist, expectedGroupCount: numGroups)
        }
        
        removeAllGroups(from: playlist)
    }
    
    private func doAddTracks(_ tracks: [Track], to playlist: GroupingPlaylist, expectedGroupCount: Int) {
        
        var addResult: GroupedTrackAddResult
        
        for track in tracks {
            
            addResult = playlist.addTrack(track)
            
            let group = addResult.track.group
            let groupIndex = addResult.track.groupIndex
            
            XCTAssertEqual(playlist.groupAtIndex(groupIndex), group)
            XCTAssertEqual(playlist.indexOfGroup(group), groupIndex)
            XCTAssertEqual(playlist.numberOfGroups, expectedGroupCount)
        }
    }
    
    private func removeAllGroups(from playlist: GroupingPlaylist) {
        
        let totalGroups = playlist.numberOfGroups
        
        for numGroups in (0..<totalGroups).reversed() {

            let randomIndex: Int = .random(in: playlist.groups.indices)
            let groupToRemove: Group = playlist.groupAtIndex(randomIndex)!
            
            _ = playlist.removeTracksAndGroups([], [groupToRemove])
            
            XCTAssertEqual(playlist.numberOfGroups, numGroups)
            XCTAssertNil(playlist.indexOfGroup(groupToRemove))
            XCTAssertNotEqual(playlist.groupAtIndex(randomIndex), groupToRemove)
        }
    }
    
    private var usedGroupNames: Set<String> = Set()
    
    private func uniqueGroupName() -> String {
        
        var name = randomString(length: 15)
        
        while usedGroupNames.contains(name) {
            name = randomString(length: 15)
        }
        
        return name
    }
}
