//
//  GroupingPlaylistTests+TrackInfo.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class GroupingPlaylistTests_TrackInfo: GroupingPlaylistTestCase {
    
    func test_artistsPlaylist_tracksHaveTitle() {
        
        let playlist = GroupingPlaylist(.artists)
        XCTAssertEqual(playlist.numberOfGroups, 0)
        
        // Add the first track, which will result in a new group being created.
        
        let track1 = createTrack(title: "Favriel", artist: "Grimes")
        doTest(for: track1, in: playlist, expectedDisplayName: track1.title!, expectedGroupIndex: 0, expectedTrackIndex: 0)
        
        // Add a second track to the same group.
        
        let track2 = createTrack(title: "Skin", artist: "Grimes")
        doTest(for: track2, in: playlist, expectedDisplayName: track2.title!, expectedGroupIndex: 0, expectedTrackIndex: 1)

        // Add a third track, resulting in a second group being created.

        let track3 = createTrack(title: "Fever", artist: "Madonna")
        doTest(for: track3, in: playlist, expectedDisplayName: track3.title!, expectedGroupIndex: 1, expectedTrackIndex: 0)
    }
    
    func test_artistsPlaylist_tracksDontHaveTitle() {
        
        let playlist = GroupingPlaylist(.artists)
        XCTAssertEqual(playlist.numberOfGroups, 0)
        
        // Add the first track, which will result in a new group being created.
        
        let track1 = createTrack(fileName: "Grimes - Favriel", artist: "Grimes")
        doTest(for: track1, in: playlist, expectedDisplayName: track1.defaultDisplayName, expectedGroupIndex: 0, expectedTrackIndex: 0)
        
        // Add a second track to the same group.
        
        let track2 = createTrack(fileName: "Grimes - Skin", artist: "Grimes")
        doTest(for: track2, in: playlist, expectedDisplayName: track2.defaultDisplayName, expectedGroupIndex: 0, expectedTrackIndex: 1)

        // Add a third track, resulting in a second group being created.

        let track3 = createTrack(fileName: "Madonna - Fever", artist: "Madonna")
        doTest(for: track3, in: playlist, expectedDisplayName: track3.defaultDisplayName, expectedGroupIndex: 1, expectedTrackIndex: 0)
    }
    
    func test_albumsPlaylist_tracksHaveTitle() {
        
        let playlist = GroupingPlaylist(.albums)
        XCTAssertEqual(playlist.numberOfGroups, 0)
        
        // Add the first track, which will result in a new group being created.
        
        let track1 = createTrack(title: "Favriel", artist: "Grimes", album: "Halfaxa")
        doTest(for: track1, in: playlist, expectedDisplayName: track1.title!, expectedGroupIndex: 0, expectedTrackIndex: 0)
        
        // Add a second track to the same group.
        
        let track2 = createTrack(title: "Dream Fortress", artist: "Grimes", album: "Halfaxa")
        doTest(for: track2, in: playlist, expectedDisplayName: track2.title!, expectedGroupIndex: 0, expectedTrackIndex: 1)

        // Add a third track, resulting in a second group being created.

        let track3 = createTrack(title: "Fever", artist: "Madonna", album: "Madonna's Greatest Hits")
        doTest(for: track3, in: playlist, expectedDisplayName: track3.title!, expectedGroupIndex: 1, expectedTrackIndex: 0)
    }
    
    func test_albumsPlaylist_tracksDontHaveTitle() {
        
        let playlist = GroupingPlaylist(.albums)
        XCTAssertEqual(playlist.numberOfGroups, 0)
        
        // Add the first track, which will result in a new group being created.
        
        let track1 = createTrack(fileName: "Grimes - Favriel", artist: "Grimes", album: "Halfaxa")
        doTest(for: track1, in: playlist, expectedDisplayName: track1.defaultDisplayName, expectedGroupIndex: 0, expectedTrackIndex: 0)
        
        // Add a second track to the same group.
        
        let track2 = createTrack(fileName: "Grimes - Dream Fortress", artist: "Grimes", album: "Halfaxa")
        doTest(for: track2, in: playlist, expectedDisplayName: track2.defaultDisplayName, expectedGroupIndex: 0, expectedTrackIndex: 1)

        // Add a third track, resulting in a second group being created.

        let track3 = createTrack(fileName: "Madonna - Fever", artist: "Madonna", album: "Madonna's Greatest Hits")
        doTest(for: track3, in: playlist, expectedDisplayName: track3.defaultDisplayName, expectedGroupIndex: 1, expectedTrackIndex: 0)
    }
    
    func test_genresPlaylist_artistMetadataOnly() {
        
        let playlist = GroupingPlaylist(.genres)
        XCTAssertEqual(playlist.numberOfGroups, 0)
        
        // Add the first track, which will result in a new group being created.
        
        let track1 = createTrack(fileName: "Grimes - Favriel", artist: "Grimes", genre: "Electronica")
        doTest(for: track1, in: playlist, expectedDisplayName: track1.defaultDisplayName, expectedGroupIndex: 0, expectedTrackIndex: 0)
        
        // Add a second track to the same group.
        
        let track2 = createTrack(fileName: "Grimes - Dream Fortress", artist: "Grimes", genre: "Electronica")
        doTest(for: track2, in: playlist, expectedDisplayName: track2.defaultDisplayName, expectedGroupIndex: 0, expectedTrackIndex: 1)

        // Add a third track, resulting in a second group being created.

        let track3 = createTrack(fileName: "Madonna - Fever", artist: "Madonna", genre: "Pop")
        doTest(for: track3, in: playlist, expectedDisplayName: track3.defaultDisplayName, expectedGroupIndex: 1, expectedTrackIndex: 0)
    }
    
    func test_genresPlaylist_titleMetadataOnly() {
        
        let playlist = GroupingPlaylist(.genres)
        XCTAssertEqual(playlist.numberOfGroups, 0)
        
        // Add the first track, which will result in a new group being created.
        
        let track1 = createTrack(title: "Favriel", genre: "Electronica")
        doTest(for: track1, in: playlist, expectedDisplayName: track1.title!, expectedGroupIndex: 0, expectedTrackIndex: 0)
        
        // Add a second track to the same group.
        
        let track2 = createTrack(title: "Dream Fortress", genre: "Electronica")
        doTest(for: track2, in: playlist, expectedDisplayName: track2.title!, expectedGroupIndex: 0, expectedTrackIndex: 1)

        // Add a third track, resulting in a second group being created.

        let track3 = createTrack(title: "Fever", genre: "Pop")
        doTest(for: track3, in: playlist, expectedDisplayName: track3.title!, expectedGroupIndex: 1, expectedTrackIndex: 0)
    }
    
    func test_genresPlaylist_artistAndTitleMetadata() {
        
        let playlist = GroupingPlaylist(.genres)
        XCTAssertEqual(playlist.numberOfGroups, 0)
        
        // Add the first track, which will result in a new group being created.
        
        let track1 = createTrack(title: "Favriel", artist: "Grimes", genre: "Electronica")
        doTest(for: track1, in: playlist, expectedDisplayName: track1.artistTitleString!, expectedGroupIndex: 0, expectedTrackIndex: 0)
        
        // Add a second track to the same group.
        
        let track2 = createTrack(title: "Dream Fortress", artist: "Grimes", genre: "Electronica")
        doTest(for: track2, in: playlist, expectedDisplayName: track2.artistTitleString!, expectedGroupIndex: 0, expectedTrackIndex: 1)

        // Add a third track, resulting in a second group being created.

        let track3 = createTrack(title: "Fever", artist: "Madonna", genre: "Pop")
        doTest(for: track3, in: playlist, expectedDisplayName: track3.artistTitleString!, expectedGroupIndex: 1, expectedTrackIndex: 0)
    }
    
    func test_genresPlaylist_noArtistOrTitleMetadata() {
        
        let playlist = GroupingPlaylist(.genres)
        XCTAssertEqual(playlist.numberOfGroups, 0)
        
        // Add the first track, which will result in a new group being created.
        
        let track1 = createTrack(fileName: "Grimes - Favriel", genre: "Electronica")
        doTest(for: track1, in: playlist, expectedDisplayName: track1.defaultDisplayName, expectedGroupIndex: 0, expectedTrackIndex: 0)
        
        // Add a second track to the same group.
        
        let track2 = createTrack(fileName: "Grimes - Dream Fortress", genre: "Electronica")
        doTest(for: track2, in: playlist, expectedDisplayName: track2.defaultDisplayName, expectedGroupIndex: 0, expectedTrackIndex: 1)

        // Add a third track, resulting in a second group being created.

        let track3 = createTrack(fileName: "Madonna - Fever", genre: "Pop")
        doTest(for: track3, in: playlist, expectedDisplayName: track3.defaultDisplayName, expectedGroupIndex: 1, expectedTrackIndex: 0)
    }
    
    private func doTest(for track: Track, in playlist: GroupingPlaylist,
                        expectedDisplayName: String,
                        expectedGroupIndex: Int,
                        expectedTrackIndex: Int) {
        
        let addResult = playlist.addTrack(track)
        let theGroup = addResult.track.group
        
        XCTAssertEqual(playlist.displayNameForTrack(track), expectedDisplayName)
        
        guard let groupingInfo = playlist.groupingInfoForTrack(track) else {
            
            XCTFail("No grouping info found for track.")
            return
        }
        
        XCTAssertEqual(groupingInfo.track, track)
        XCTAssertEqual(groupingInfo.group, theGroup)

        XCTAssertEqual(groupingInfo.groupIndex, expectedGroupIndex)
        XCTAssertEqual(groupingInfo.trackIndex, expectedTrackIndex)
    }
}
