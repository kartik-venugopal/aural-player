//
//  GroupingPlaylistTests+AddAndRemoveTracks.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class GroupingPlaylistTests_AddAndRemoveTracks: GroupingPlaylistTestCase {
    
    func testAddTrack_artistsPlaylist() {
        
        let playlist = GroupingPlaylist(.artists)
        XCTAssertEqual(playlist.numberOfGroups, 0)
        
        // Add the first track, which will result in a new group being created.
        
        let track = createTrack(fileName: "Grimes - Visions", artist: "Grimes")
        let theGroup = doTestAddTrack_groupDoesntExist(track: track, playlist: playlist, expectedGroupName: track.artist!)
        
        // Add a second track to the same group.
        
        let track2 = createTrack(fileName: "Grimes - Favriel", artist: "Grimes")
        doTestAddTrack_groupExists(track: track2, group: theGroup, playlist: playlist)

        // Add a third track, resulting in a second group being created.

        let track3 = createTrack(fileName: "Madonna - Fever", artist: "Madonna")
        _ = doTestAddTrack_groupDoesntExist(track: track3, playlist: playlist, expectedGroupName: track3.artist!)
    }
    
    func testAddTrack_artistsPlaylist_noArtistMetadata() {
        
        let playlist = GroupingPlaylist(.artists)
        XCTAssertEqual(playlist.numberOfGroups, 0)
        
        // Add the first track, which will result in a new group being created.
        
        let track = createTrack(fileName: "Grimes - Visions", artist: nil)
        let theGroup = doTestAddTrack_groupDoesntExist(track: track, playlist: playlist, expectedGroupName: "<Unknown>")
        
        // Add a second track to the same group.
        
        let track2 = createTrack(fileName: "Grimes - Favriel", artist: nil)
        doTestAddTrack_groupExists(track: track2, group: theGroup, playlist: playlist)
    }
    
    func testAddTrack_albumsPlaylist() {
        
        let playlist = GroupingPlaylist(.albums)
        XCTAssertEqual(playlist.numberOfGroups, 0)
        
        // Add the first track, which will result in a new group being created.
        
        let track = createTrack(fileName: "Grimes - Visions", artist: "Grimes", album: "Visions")
        let theGroup = doTestAddTrack_groupDoesntExist(track: track, playlist: playlist, expectedGroupName: track.album!)
        
        // Add a second track to the same group.
        
        let track2 = createTrack(fileName: "Grimes - Skin", artist: "Grimes", album: "Visions")
        doTestAddTrack_groupExists(track: track2, group: theGroup, playlist: playlist)

        // Add a third track, resulting in a second group being created.

        let track3 = createTrack(fileName: "Grimes - Favriel", artist: "Grimes", album: "Halfaxa")
        _ = doTestAddTrack_groupDoesntExist(track: track3, playlist: playlist, expectedGroupName: track3.album!)
    }
    
    func testAddTrack_albumsPlaylist_noAlbumMetadata() {
        
        let playlist = GroupingPlaylist(.albums)
        XCTAssertEqual(playlist.numberOfGroups, 0)
        
        // Add the first track, which will result in a new group being created.
        
        let track = createTrack(fileName: "Grimes - Visions", artist: "Grimes", album: nil)
        let theGroup = doTestAddTrack_groupDoesntExist(track: track, playlist: playlist, expectedGroupName: "<Unknown>")
        
        // Add a second track to the same group.
        
        let track2 = createTrack(fileName: "Grimes - Skin", artist: "Grimes", album: nil)
        doTestAddTrack_groupExists(track: track2, group: theGroup, playlist: playlist)
    }
    
    func testAddTrack_genresPlaylist() {
        
        let playlist = GroupingPlaylist(.genres)
        XCTAssertEqual(playlist.numberOfGroups, 0)
        
        // Add the first track, which will result in a new group being created.
        
        let track = createTrack(fileName: "Grimes - Visions", artist: "Grimes", album: "Visions", genre: "Electronica")
        let theGroup = doTestAddTrack_groupDoesntExist(track: track, playlist: playlist, expectedGroupName: track.genre!)
        
        // Add a second track to the same group.
        
        let track2 = createTrack(fileName: "Grimes - Skin", artist: "Grimes", album: "Visions", genre: "Electronica")
        doTestAddTrack_groupExists(track: track2, group: theGroup, playlist: playlist)

        // Add a third track, resulting in a second group being created.

        let track3 = createTrack(fileName: "Madonna - Fever", artist: "Madonna", genre: "Pop")
        _ = doTestAddTrack_groupDoesntExist(track: track3, playlist: playlist, expectedGroupName: track3.genre!)
    }
    
    func testAddTrack_genresPlaylist_noGenreMetadata() {
        
        let playlist = GroupingPlaylist(.genres)
        XCTAssertEqual(playlist.numberOfGroups, 0)
        
        // Add the first track, which will result in a new group being created.
        
        let track = createTrack(fileName: "Grimes - Visions", artist: "Grimes", album: "Visions", genre: nil)
        let theGroup = doTestAddTrack_groupDoesntExist(track: track, playlist: playlist, expectedGroupName: "<Unknown>")
        
        // Add a second track to the same group.
        
        let track2 = createTrack(fileName: "Grimes - Skin", artist: "Grimes", album: "Visions", genre: nil)
        doTestAddTrack_groupExists(track: track2, group: theGroup, playlist: playlist)
    }
    
    private func doTestAddTrack_groupDoesntExist(track: Track, playlist: GroupingPlaylist, expectedGroupName: String) -> Group {
        
        let numberOfGroupsBeforeAdd = playlist.numberOfGroups
        
        let addResult = playlist.addTrack(track)
        
        XCTAssertEqual(playlist.numberOfGroups, numberOfGroupsBeforeAdd + 1)
        
        let theGroup = addResult.track.group
        
        XCTAssertEqual(theGroup.name, expectedGroupName)
        XCTAssertEqual(theGroup.size, 1)
        XCTAssertEqual(theGroup.duration, track.duration, accuracy: 0.001)
        XCTAssertEqual(theGroup.trackAtIndex(0), track)
        
        XCTAssertTrue(addResult.groupCreated)
        XCTAssertEqual(addResult.track.group, theGroup)
        XCTAssertEqual(addResult.track.groupIndex, playlist.groups.lastIndex)
        
        XCTAssertEqual(addResult.track.track, track)
        XCTAssertEqual(addResult.track.trackIndex, 0)
        
        return theGroup
    }
    
    private func doTestAddTrack_groupExists(track: Track, group: Group, playlist: GroupingPlaylist) {
        
        let numberOfGroupsBeforeAdd = playlist.numberOfGroups
        let groupSizeBeforeAdd = group.size
        let groupDurationBeforeAdd = group.duration
        
        let addResult = playlist.addTrack(track)
        
        XCTAssertEqual(playlist.numberOfGroups, numberOfGroupsBeforeAdd)
        
        XCTAssertEqual(group.size, groupSizeBeforeAdd + 1)
        XCTAssertEqual(group.duration, groupDurationBeforeAdd + track.duration, accuracy: 0.001)
        XCTAssertEqual(group.trackAtIndex(groupSizeBeforeAdd), track)
        
        XCTAssertFalse(addResult.groupCreated)
        XCTAssertEqual(addResult.track.group, group)
        XCTAssertEqual(addResult.track.groupIndex, playlist.indexOfGroup(group))
        
        XCTAssertEqual(addResult.track.track, track)
        XCTAssertEqual(addResult.track.trackIndex, groupSizeBeforeAdd)
    }
    
    func testRemoveTracksAndGroups_artistsPlaylist() {
        
        let playlist = GroupingPlaylist(.artists)

        let madonnaTracks = createNTracks(5, artist: "Madonna")
        let grimesTracks = createNTracks(2, artist: "Grimes")
        let biosphereTracks = createNTracks(10, artist: "Biosphere")

        for track in madonnaTracks + grimesTracks + biosphereTracks {
            _ = playlist.addTrack(track)
        }

        XCTAssertEqual(playlist.numberOfGroups, 3)

        let allGroups = playlist.groups
        XCTAssertEqual(allGroups.count, 3)

        let madonnaGroup = allGroups.first(where: {$0.name == "Madonna"})!
        
        let grimesGroup = allGroups.first(where: {$0.name == "Grimes"})!
        let grimesGroupIndex = playlist.indexOfGroup(grimesGroup)!
        
        let biosphereGroup = allGroups.first(where: {$0.name == "Biosphere"})!

        XCTAssertEqual(madonnaGroup.size, 5)
        XCTAssertEqual(grimesGroup.size, 2)
        XCTAssertEqual(biosphereGroup.size, 10)
        
        let madonnaGroupDurationBeforeRemove = madonnaGroup.duration
        let biosphereGroupDurationBeforeRemove = biosphereGroup.duration

        let groupsToRemove = [grimesGroup]
        let tracksToRemove = [madonnaTracks[1], madonnaTracks[3], biosphereTracks[4]]

        let removeResults = playlist.removeTracksAndGroups(tracksToRemove, groupsToRemove)
        
        XCTAssertEqual(playlist.numberOfGroups, 2)
        XCTAssertFalse(playlist.groups.contains(grimesGroup))
        XCTAssertTrue(playlist.groups.contains(madonnaGroup))
        XCTAssertTrue(playlist.groups.contains(biosphereGroup))
        
        XCTAssertEqual(madonnaGroup.size, 3)
        
        XCTAssertEqual(madonnaGroup.duration,
                       madonnaGroupDurationBeforeRemove - (madonnaTracks[1].duration + madonnaTracks[3].duration),
                       accuracy: 0.001)
        
        XCTAssertFalse(madonnaGroup.tracks.contains(madonnaTracks[1]))
        XCTAssertFalse(madonnaGroup.tracks.contains(madonnaTracks[3]))
        
        for index in [0, 2, 4] {
            XCTAssertTrue(madonnaGroup.tracks.contains(madonnaTracks[index]))
        }
        
        XCTAssertEqual(biosphereGroup.size, 9)
        
        XCTAssertEqual(biosphereGroup.duration,
                       biosphereGroupDurationBeforeRemove - biosphereTracks[4].duration,
                       accuracy: 0.001)
        
        XCTAssertFalse(biosphereGroup.tracks.contains(biosphereTracks[4]))
        
        for index in [0, 1, 2, 3, 5, 6, 7, 8, 9] {
            XCTAssertTrue(biosphereGroup.tracks.contains(biosphereTracks[index]))
        }
        
        XCTAssertEqual(removeResults.count, 3)
        
        guard let grimesGroupRemovalResult = removeResults.first(where: {$0.group == grimesGroup}) as? GroupRemovalResult else {
            
            XCTFail("Expected a result for removal of 'Grimes' group.")
            return
        }
        
        XCTAssertEqual(grimesGroupRemovalResult.groupIndex, grimesGroupIndex)
        
        guard let madonnaTracksRemovalResult = removeResults.first(where: {$0.group == madonnaGroup}) as? GroupedTracksRemovalResult else {
            
            XCTFail("Expected a result for removal of tracks from 'Madonna' group.")
            return
        }
        
        XCTAssertEqual(madonnaTracksRemovalResult.groupIndex, playlist.indexOfGroup(madonnaGroup))
        XCTAssertEqual(madonnaTracksRemovalResult.trackIndexesInGroup, IndexSet([1, 3]))
        
        guard let biosphereTracksRemovalResult = removeResults.first(where: {$0.group == biosphereGroup}) as? GroupedTracksRemovalResult else {
            
            XCTFail("Expected a result for removal of tracks from 'Biosphere' group.")
            return
        }
        
        XCTAssertEqual(biosphereTracksRemovalResult.groupIndex, playlist.indexOfGroup(biosphereGroup))
        XCTAssertEqual(biosphereTracksRemovalResult.trackIndexesInGroup, IndexSet([4]))
    }
    
    func testRemoveTracksAndGroups_artistsPlaylist_allTracksFromGroup_groupRemoved() {
        
        let playlist = GroupingPlaylist(.artists)

        let madonnaTracks = createNTracks(5, artist: "Madonna")
        let grimesTracks = createNTracks(2, artist: "Grimes")
        let biosphereTracks = createNTracks(10, artist: "Biosphere")

        for track in madonnaTracks + grimesTracks + biosphereTracks {
            _ = playlist.addTrack(track)
        }

        let allGroups = playlist.groups
        XCTAssertEqual(allGroups.count, 3)

        let madonnaGroup = allGroups.first(where: {$0.name == "Madonna"})!
        
        let grimesGroup = allGroups.first(where: {$0.name == "Grimes"})!
        let grimesGroupIndex = playlist.indexOfGroup(grimesGroup)!
        
        let biosphereGroup = allGroups.first(where: {$0.name == "Biosphere"})!

        // Remove all tracks from the 'Grimes' group.
        let removeResults = playlist.removeTracksAndGroups(grimesGroup.tracks, [])
        
        XCTAssertEqual(playlist.numberOfGroups, 2)
        XCTAssertFalse(playlist.groups.contains(grimesGroup))
        XCTAssertTrue(playlist.groups.contains(madonnaGroup))
        XCTAssertTrue(playlist.groups.contains(biosphereGroup))
        
        XCTAssertEqual(madonnaGroup.size, 5)
        XCTAssertEqual(biosphereGroup.size, 10)
        
        XCTAssertEqual(removeResults.count, 1)
        
        guard let grimesGroupRemovalResult = removeResults.first(where: {$0.group == grimesGroup}) as? GroupRemovalResult else {
            
            XCTFail("Expected a result for removal of 'Grimes' group.")
            return
        }
        
        XCTAssertEqual(grimesGroupRemovalResult.groupIndex, grimesGroupIndex)
    }
    
    func testRemoveTracksAndGroups_artistsPlaylist_tracksFromGroupAndGroup_groupRemoved() {
        
        let playlist = GroupingPlaylist(.artists)

        let madonnaTracks = createNTracks(5, artist: "Madonna")
        let grimesTracks = createNTracks(2, artist: "Grimes")
        let biosphereTracks = createNTracks(10, artist: "Biosphere")

        for track in madonnaTracks + grimesTracks + biosphereTracks {
            _ = playlist.addTrack(track)
        }

        let allGroups = playlist.groups
        XCTAssertEqual(allGroups.count, 3)

        let madonnaGroup = allGroups.first(where: {$0.name == "Madonna"})!
        
        let grimesGroup = allGroups.first(where: {$0.name == "Grimes"})!
        let grimesGroupIndex = playlist.indexOfGroup(grimesGroup)!
        
        let biosphereGroup = allGroups.first(where: {$0.name == "Biosphere"})!

        let removeResults = playlist.removeTracksAndGroups([grimesTracks[0]], [grimesGroup])
        
        XCTAssertEqual(playlist.numberOfGroups, 2)
        XCTAssertFalse(playlist.groups.contains(grimesGroup))
        XCTAssertTrue(playlist.groups.contains(madonnaGroup))
        XCTAssertTrue(playlist.groups.contains(biosphereGroup))
        
        XCTAssertEqual(madonnaGroup.size, 5)
        XCTAssertEqual(biosphereGroup.size, 10)
        
        XCTAssertEqual(removeResults.count, 1)
        
        guard let grimesGroupRemovalResult = removeResults.first(where: {$0.group == grimesGroup}) as? GroupRemovalResult else {
            
            XCTFail("Expected a result for removal of 'Grimes' group.")
            return
        }
        
        XCTAssertEqual(grimesGroupRemovalResult.groupIndex, grimesGroupIndex)
    }
    
    func testRemoveTracksAndGroups_albumsPlaylist() {
        
        let playlist = GroupingPlaylist(.albums)

        let halfaxaTracks = createNTracks(5, artist: "Grimes", album: "Halfaxa")
        let visionsTracks = createNTracks(2, artist: "Grimes", album: "Visions")
        let substrataTracks = createNTracks(10, artist: "Biosphere", album: "Substrata")

        for track in halfaxaTracks + visionsTracks + substrataTracks {
            _ = playlist.addTrack(track)
        }

        XCTAssertEqual(playlist.numberOfGroups, 3)

        let allGroups = playlist.groups
        XCTAssertEqual(allGroups.count, 3)

        let halfaxaGroup = allGroups.first(where: {$0.name == "Halfaxa"})!
        
        let visionsGroup = allGroups.first(where: {$0.name == "Visions"})!
        let visionsGroupIndex = playlist.indexOfGroup(visionsGroup)!
        
        let substrataGroup = allGroups.first(where: {$0.name == "Substrata"})!

        XCTAssertEqual(halfaxaGroup.size, 5)
        XCTAssertEqual(visionsGroup.size, 2)
        XCTAssertEqual(substrataGroup.size, 10)
        
        let halfaxaGroupDurationBeforeRemove = halfaxaGroup.duration
        let substrataGroupDurationBeforeRemove = substrataGroup.duration

        let groupsToRemove = [visionsGroup]
        let tracksToRemove = [halfaxaTracks[1], halfaxaTracks[3], substrataTracks[4]]

        let removeResults = playlist.removeTracksAndGroups(tracksToRemove, groupsToRemove)
        
        XCTAssertEqual(playlist.numberOfGroups, 2)
        XCTAssertFalse(playlist.groups.contains(visionsGroup))
        XCTAssertTrue(playlist.groups.contains(halfaxaGroup))
        XCTAssertTrue(playlist.groups.contains(substrataGroup))
        
        XCTAssertEqual(halfaxaGroup.size, 3)
        
        XCTAssertEqual(halfaxaGroup.duration,
                       halfaxaGroupDurationBeforeRemove - (halfaxaTracks[1].duration + halfaxaTracks[3].duration),
                       accuracy: 0.001)
        
        XCTAssertFalse(halfaxaGroup.tracks.contains(halfaxaTracks[1]))
        XCTAssertFalse(halfaxaGroup.tracks.contains(halfaxaTracks[3]))
        
        for index in [0, 2, 4] {
            XCTAssertTrue(halfaxaGroup.tracks.contains(halfaxaTracks[index]))
        }
        
        XCTAssertEqual(substrataGroup.size, 9)
        
        XCTAssertEqual(substrataGroup.duration,
                       substrataGroupDurationBeforeRemove - substrataTracks[4].duration,
                       accuracy: 0.001)
        
        XCTAssertFalse(substrataGroup.tracks.contains(substrataTracks[4]))
        
        for index in [0, 1, 2, 3, 5, 6, 7, 8, 9] {
            XCTAssertTrue(substrataGroup.tracks.contains(substrataTracks[index]))
        }
        
        XCTAssertEqual(removeResults.count, 3)
        
        guard let visionsGroupRemovalResult = removeResults.first(where: {$0.group == visionsGroup}) as? GroupRemovalResult else {
            
            XCTFail("Expected a result for removal of 'Visions' group.")
            return
        }
        
        XCTAssertEqual(visionsGroupRemovalResult.groupIndex, visionsGroupIndex)
        
        guard let halfaxaTracksRemovalResult = removeResults.first(where: {$0.group == halfaxaGroup}) as? GroupedTracksRemovalResult else {
            
            XCTFail("Expected a result for removal of tracks from 'Halfaxa' group.")
            return
        }
        
        XCTAssertEqual(halfaxaTracksRemovalResult.groupIndex, playlist.indexOfGroup(halfaxaGroup))
        XCTAssertEqual(halfaxaTracksRemovalResult.trackIndexesInGroup, IndexSet([1, 3]))
        
        guard let substrataTracksRemovalResult = removeResults.first(where: {$0.group == substrataGroup}) as? GroupedTracksRemovalResult else {
            
            XCTFail("Expected a result for removal of tracks from 'Substrata' group.")
            return
        }
        
        XCTAssertEqual(substrataTracksRemovalResult.groupIndex, playlist.indexOfGroup(substrataGroup))
        XCTAssertEqual(substrataTracksRemovalResult.trackIndexesInGroup, IndexSet([4]))
    }
    
    func testRemoveTracksAndGroups_albumsPlaylist_allTracksFromGroup_groupRemoved() {
        
        let playlist = GroupingPlaylist(.albums)

        let halfaxaTracks = createNTracks(5, artist: "Grimes", album: "Halfaxa")
        let visionsTracks = createNTracks(2, artist: "Grimes", album: "Visions")
        let substrataTracks = createNTracks(10, artist: "Biosphere", album: "Substrata")

        for track in halfaxaTracks + visionsTracks + substrataTracks {
            _ = playlist.addTrack(track)
        }

        XCTAssertEqual(playlist.numberOfGroups, 3)

        let allGroups = playlist.groups
        XCTAssertEqual(allGroups.count, 3)

        let halfaxaGroup = allGroups.first(where: {$0.name == "Halfaxa"})!
        
        let visionsGroup = allGroups.first(where: {$0.name == "Visions"})!
        let visionsGroupIndex = playlist.indexOfGroup(visionsGroup)!
        
        let substrataGroup = allGroups.first(where: {$0.name == "Substrata"})!

        XCTAssertEqual(halfaxaGroup.size, 5)
        XCTAssertEqual(visionsGroup.size, 2)
        XCTAssertEqual(substrataGroup.size, 10)

        let removeResults = playlist.removeTracksAndGroups(visionsGroup.tracks, [])
        
        XCTAssertEqual(playlist.numberOfGroups, 2)
        XCTAssertFalse(playlist.groups.contains(visionsGroup))
        XCTAssertTrue(playlist.groups.contains(halfaxaGroup))
        XCTAssertTrue(playlist.groups.contains(substrataGroup))
        
        XCTAssertEqual(halfaxaGroup.size, 5)
        XCTAssertEqual(substrataGroup.size, 10)
        
        XCTAssertEqual(removeResults.count, 1)
        
        guard let visionsGroupRemovalResult = removeResults.first(where: {$0.group == visionsGroup}) as? GroupRemovalResult else {
            
            XCTFail("Expected a result for removal of 'Visions' group.")
            return
        }
        
        XCTAssertEqual(visionsGroupRemovalResult.groupIndex, visionsGroupIndex)
    }
    
    func testRemoveTracksAndGroups_albumsPlaylist_tracksFromGroupAndGroup_groupRemoved() {
        
        let playlist = GroupingPlaylist(.albums)

        let halfaxaTracks = createNTracks(5, artist: "Grimes", album: "Halfaxa")
        let visionsTracks = createNTracks(2, artist: "Grimes", album: "Visions")
        let substrataTracks = createNTracks(10, artist: "Biosphere", album: "Substrata")

        for track in halfaxaTracks + visionsTracks + substrataTracks {
            _ = playlist.addTrack(track)
        }

        XCTAssertEqual(playlist.numberOfGroups, 3)

        let allGroups = playlist.groups
        XCTAssertEqual(allGroups.count, 3)

        let halfaxaGroup = allGroups.first(where: {$0.name == "Halfaxa"})!
        
        let visionsGroup = allGroups.first(where: {$0.name == "Visions"})!
        let visionsGroupIndex = playlist.indexOfGroup(visionsGroup)!
        
        let substrataGroup = allGroups.first(where: {$0.name == "Substrata"})!

        XCTAssertEqual(halfaxaGroup.size, 5)
        XCTAssertEqual(visionsGroup.size, 2)
        XCTAssertEqual(substrataGroup.size, 10)

        let removeResults = playlist.removeTracksAndGroups([visionsTracks[0]], [visionsGroup])
        
        XCTAssertEqual(playlist.numberOfGroups, 2)
        XCTAssertFalse(playlist.groups.contains(visionsGroup))
        XCTAssertTrue(playlist.groups.contains(halfaxaGroup))
        XCTAssertTrue(playlist.groups.contains(substrataGroup))
        
        XCTAssertEqual(halfaxaGroup.size, 5)
        XCTAssertEqual(substrataGroup.size, 10)
        
        XCTAssertEqual(removeResults.count, 1)
        
        guard let visionsGroupRemovalResult = removeResults.first(where: {$0.group == visionsGroup}) as? GroupRemovalResult else {
            
            XCTFail("Expected a result for removal of 'Visions' group.")
            return
        }
        
        XCTAssertEqual(visionsGroupRemovalResult.groupIndex, visionsGroupIndex)
    }
    
    func testRemoveTracksAndGroups_genresPlaylist() {
        
        let playlist = GroupingPlaylist(.genres)

        let popTracks = createNTracks(5, artist: "Madonna", genre: "Pop")
        let electronicaTracks = createNTracks(2, artist: "Grimes", genre: "Electronica")
        let ambientTracks = createNTracks(10, artist: "Biosphere", genre: "Ambient")

        for track in popTracks + electronicaTracks + ambientTracks {
            _ = playlist.addTrack(track)
        }

        XCTAssertEqual(playlist.numberOfGroups, 3)

        let allGroups = playlist.groups
        XCTAssertEqual(allGroups.count, 3)

        let popGroup = allGroups.first(where: {$0.name == "Pop"})!
        
        let electronicaGroup = allGroups.first(where: {$0.name == "Electronica"})!
        let electronicaGroupIndex = playlist.indexOfGroup(electronicaGroup)!
        
        let ambientGroup = allGroups.first(where: {$0.name == "Ambient"})!

        XCTAssertEqual(popGroup.size, 5)
        XCTAssertEqual(electronicaGroup.size, 2)
        XCTAssertEqual(ambientGroup.size, 10)
        
        let popGroupDurationBeforeRemove = popGroup.duration
        let ambientGroupDurationBeforeRemove = ambientGroup.duration

        let groupsToRemove = [electronicaGroup]
        let tracksToRemove = [popTracks[1], popTracks[3], ambientTracks[4]]

        let removeResults = playlist.removeTracksAndGroups(tracksToRemove, groupsToRemove)
        
        XCTAssertEqual(playlist.numberOfGroups, 2)
        XCTAssertFalse(playlist.groups.contains(electronicaGroup))
        XCTAssertTrue(playlist.groups.contains(popGroup))
        XCTAssertTrue(playlist.groups.contains(ambientGroup))
        
        XCTAssertEqual(popGroup.size, 3)
        
        XCTAssertEqual(popGroup.duration,
                       popGroupDurationBeforeRemove - (popTracks[1].duration + popTracks[3].duration),
                       accuracy: 0.001)
        
        XCTAssertFalse(popGroup.tracks.contains(popTracks[1]))
        XCTAssertFalse(popGroup.tracks.contains(popTracks[3]))
        
        for index in [0, 2, 4] {
            XCTAssertTrue(popGroup.tracks.contains(popTracks[index]))
        }
        
        XCTAssertEqual(ambientGroup.size, 9)
        
        XCTAssertEqual(ambientGroup.duration,
                       ambientGroupDurationBeforeRemove - ambientTracks[4].duration,
                       accuracy: 0.001)
        
        XCTAssertFalse(ambientGroup.tracks.contains(ambientTracks[4]))
        
        for index in [0, 1, 2, 3, 5, 6, 7, 8, 9] {
            XCTAssertTrue(ambientGroup.tracks.contains(ambientTracks[index]))
        }
        
        XCTAssertEqual(removeResults.count, 3)
        
        guard let electronicaGroupRemovalResult = removeResults.first(where: {$0.group == electronicaGroup}) as? GroupRemovalResult else {
            
            XCTFail("Expected a result for removal of 'Electronica' group.")
            return
        }
        
        XCTAssertEqual(electronicaGroupRemovalResult.groupIndex, electronicaGroupIndex)
        
        guard let popTracksRemovalResult = removeResults.first(where: {$0.group == popGroup}) as? GroupedTracksRemovalResult else {
            
            XCTFail("Expected a result for removal of tracks from 'Pop' group.")
            return
        }
        
        XCTAssertEqual(popTracksRemovalResult.groupIndex, playlist.indexOfGroup(popGroup))
        XCTAssertEqual(popTracksRemovalResult.trackIndexesInGroup, IndexSet([1, 3]))
        
        guard let ambientTracksRemovalResult = removeResults.first(where: {$0.group == ambientGroup}) as? GroupedTracksRemovalResult else {
            
            XCTFail("Expected a result for removal of tracks from 'Ambient' group.")
            return
        }
        
        XCTAssertEqual(ambientTracksRemovalResult.groupIndex, playlist.indexOfGroup(ambientGroup))
        XCTAssertEqual(ambientTracksRemovalResult.trackIndexesInGroup, IndexSet([4]))
    }
    
    func testRemoveTracksAndGroups_genresPlaylist_allTracksFromGroup_groupRemoved() {
        
        let playlist = GroupingPlaylist(.genres)

        let popTracks = createNTracks(5, artist: "Madonna", genre: "Pop")
        let electronicaTracks = createNTracks(2, artist: "Grimes", genre: "Electronica")
        let ambientTracks = createNTracks(10, artist: "Biosphere", genre: "Ambient")

        for track in popTracks + electronicaTracks + ambientTracks {
            _ = playlist.addTrack(track)
        }

        XCTAssertEqual(playlist.numberOfGroups, 3)

        let allGroups = playlist.groups
        XCTAssertEqual(allGroups.count, 3)

        let popGroup = allGroups.first(where: {$0.name == "Pop"})!
        
        let electronicaGroup = allGroups.first(where: {$0.name == "Electronica"})!
        let electronicaGroupIndex = playlist.indexOfGroup(electronicaGroup)!
        
        let ambientGroup = allGroups.first(where: {$0.name == "Ambient"})!

        XCTAssertEqual(popGroup.size, 5)
        XCTAssertEqual(electronicaGroup.size, 2)
        XCTAssertEqual(ambientGroup.size, 10)

        let removeResults = playlist.removeTracksAndGroups(electronicaGroup.tracks, [])
        
        XCTAssertEqual(playlist.numberOfGroups, 2)
        XCTAssertFalse(playlist.groups.contains(electronicaGroup))
        XCTAssertTrue(playlist.groups.contains(popGroup))
        XCTAssertTrue(playlist.groups.contains(ambientGroup))
        
        XCTAssertEqual(popGroup.size, 5)
        XCTAssertEqual(ambientGroup.size, 10)
        
        XCTAssertEqual(removeResults.count, 1)
        
        guard let electronicaGroupRemovalResult = removeResults.first(where: {$0.group == electronicaGroup}) as? GroupRemovalResult else {
            
            XCTFail("Expected a result for removal of 'Electronica' group.")
            return
        }
        
        XCTAssertEqual(electronicaGroupRemovalResult.groupIndex, electronicaGroupIndex)
    }
    
    func testRemoveTracksAndGroups_genresPlaylist_tracksFromGroupAndGroup_groupRemoved() {
        
        let playlist = GroupingPlaylist(.genres)

        let popTracks = createNTracks(5, artist: "Madonna", genre: "Pop")
        let electronicaTracks = createNTracks(2, artist: "Grimes", genre: "Electronica")
        let ambientTracks = createNTracks(10, artist: "Biosphere", genre: "Ambient")

        for track in popTracks + electronicaTracks + ambientTracks {
            _ = playlist.addTrack(track)
        }

        XCTAssertEqual(playlist.numberOfGroups, 3)

        let allGroups = playlist.groups
        XCTAssertEqual(allGroups.count, 3)

        let popGroup = allGroups.first(where: {$0.name == "Pop"})!
        
        let electronicaGroup = allGroups.first(where: {$0.name == "Electronica"})!
        let electronicaGroupIndex = playlist.indexOfGroup(electronicaGroup)!
        
        let ambientGroup = allGroups.first(where: {$0.name == "Ambient"})!

        XCTAssertEqual(popGroup.size, 5)
        XCTAssertEqual(electronicaGroup.size, 2)
        XCTAssertEqual(ambientGroup.size, 10)

        let removeResults = playlist.removeTracksAndGroups([electronicaTracks[0]], [electronicaGroup])
        
        XCTAssertEqual(playlist.numberOfGroups, 2)
        XCTAssertFalse(playlist.groups.contains(electronicaGroup))
        XCTAssertTrue(playlist.groups.contains(popGroup))
        XCTAssertTrue(playlist.groups.contains(ambientGroup))
        
        XCTAssertEqual(popGroup.size, 5)
        XCTAssertEqual(ambientGroup.size, 10)
        
        XCTAssertEqual(removeResults.count, 1)
        
        guard let electronicaGroupRemovalResult = removeResults.first(where: {$0.group == electronicaGroup}) as? GroupRemovalResult else {
            
            XCTFail("Expected a result for removal of 'Electronica' group.")
            return
        }
        
        XCTAssertEqual(electronicaGroupRemovalResult.groupIndex, electronicaGroupIndex)
    }
}
