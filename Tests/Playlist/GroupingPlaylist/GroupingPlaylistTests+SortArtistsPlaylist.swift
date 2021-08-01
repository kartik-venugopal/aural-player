//
//  GroupingPlaylistTests+SortArtistsPlaylist.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class GroupingPlaylistTests_SortArtistsPlaylist: GroupingPlaylistTestCase {
    
    let playlist = GroupingPlaylist(.artists)
    
    lazy var madonnaTracks = createNTracks(5, artist: "Madonna")
    lazy var grimesTracks = createNTracks(2, artist: "Grimes")
    lazy var biosphereTracks = createNTracks(10, artist: "Biosphere")
    
    lazy var pinkTracks = createNTracks(5, artist: "Pink")
    lazy var pinkFloydTracks = createNTracks(10, artist: "Pink Floyd")
    
    lazy var tracks = [createTrack(fileName: "track09", duration: 255.456456),
                       createTrack(fileName: "track11", duration: 187.24342),
                       createTrack(fileName: "04 - Endless Dream", duration: 139.835345),
                       
                       createTrack(title: "Get the Party Started", duration: 303.11246, artist: "Pink", album: "Missundaztood", discNum: 1, trackNum: 4),
                       createTrack(title: "Numb", duration: 135.9696, artist: "Pink", album: "Missundaztood", discNum: 1, trackNum: 12),
                       
                       createTrack(title: "Money", duration: 403.93346, artist: "Pink Floyd", album: "Dark Side of the Moon", discNum: 1, trackNum: 6),
                       createTrack(title: "Breathe", duration: 135.9696, artist: "Pink Floyd", album: "Dark Side of the Moon", discNum: 1, trackNum: 2),
                       createTrack(title: "Time", duration: 593.23563, artist: "Pink Floyd", album: "Dark Side of the Moon", discNum: 1, trackNum: 4),
                       
                       createTrack(title: "Dream Fortress", duration: 360.73346, artist: "Grimes", album: "Halfaxa", discNum: 1, trackNum: 8),
                       createTrack(title: "Be a Body", duration: 256.58756, artist: "Grimes", album: "Visions", discNum: 1, trackNum: 8),
                       createTrack(title: "Skin", duration: 426.9756, artist: "Grimes", album: "Visions", discNum: 1, trackNum: 12),
                       
                       createTrack(title: "Lunaria", duration: 124.5345, artist: "The Sushi Club", album: "Lunarium", discNum: 1, trackNum: 13),
                       createTrack(title: "Dopia", duration: 254.6432, artist: "The Sushi Club", album: "Lunarium", discNum: 1, trackNum: 2),
                       createTrack(title: "Piota", duration: 314.9878, artist: "The Sushi Club", album: "Lunarium", discNum: 1, trackNum: 6),
                       
                       createTrack(title: "Atropia", duration: 532.9807, artist: "The Sushi Club", album: "Lunarium", discNum: 2, trackNum: 10),
                       createTrack(title: "Mycel", duration: 92.1824, artist: "The Sushi Club", album: "Lunarium", discNum: 2, trackNum: 3)]
    
    lazy var unknownArtistGroup = playlist.groups.first(where: {$0.name == "<Unknown>"})!
    lazy var grimesGroup = playlist.groups.first(where: {$0.name == "Grimes"})!
    lazy var pinkGroup = playlist.groups.first(where: {$0.name == "Pink"})!
    lazy var pinkFloydGroup = playlist.groups.first(where: {$0.name == "Pink Floyd"})!
    lazy var theSushiClubGroup = playlist.groups.first(where: {$0.name == "The Sushi Club"})!
    
    override func setUp() {
        
        super.setUp()
        
        for track in tracks.shuffled() {
            _ = playlist.addTrack(track)
        }
        
        XCTAssertEqual(playlist.numberOfGroups, 5)
    }
    
    func test_sortGroupsByName() {
        
        // Ascending ------------------------------------------------------------
        
        var sort = Sort().withGroupsSort(GroupsSort().withFields(.name).withOrder(.ascending))
        let expectedGroupsOrder = ["<Unknown>", "Grimes", "Pink", "Pink Floyd", "The Sushi Club"]
        
        playlist.sort(sort)
        
        var groupsAfterSort = playlist.groups
        XCTAssertEqual(groupsAfterSort.map {$0.name}, expectedGroupsOrder)
        
        // Descending ------------------------------------------------------------
        
        sort = Sort().withGroupsSort(GroupsSort().withFields(.name).withOrder(.descending))
        
        playlist.sort(sort)
        
        groupsAfterSort = playlist.groups
        XCTAssertEqual(groupsAfterSort.map {$0.name}, expectedGroupsOrder.reversed())
    }
    
    func test_sortGroupsByName_sortTracksByAlbumDiscNumberAndTrackNumber() {
        
        let sort = Sort().withGroupsSort(GroupsSort().withFields(.name).withOrder(.ascending))
            .withTracksSort(TracksSort().withFields(.album, .discNumberAndTrackNumber).withOrder(.ascending))
        
        let expectedGroupsOrder = ["<Unknown>", "Grimes", "Pink", "Pink Floyd", "The Sushi Club"]
        
        playlist.sort(sort)
        
        let groupsAfterSort = playlist.groups
        XCTAssertEqual(groupsAfterSort.map {$0.name}, expectedGroupsOrder)
        
        let unknownArtistTracksOrder = [2, 0, 1]
        XCTAssertEqual(unknownArtistGroup.tracks, unknownArtistTracksOrder.map {tracks[$0]})

        let grimesTracksOrder = [8, 9, 10]
        XCTAssertEqual(grimesGroup.tracks, grimesTracksOrder.map {tracks[$0]})

        let pinkTracksOrder = [3, 4]
        XCTAssertEqual(pinkGroup.tracks, pinkTracksOrder.map {tracks[$0]})
        
        let pinkFloydTracksOrder = [6, 7, 5]
        XCTAssertEqual(pinkFloydGroup.tracks, pinkFloydTracksOrder.map {tracks[$0]})
        
        let theSushiClubTracksOrder = [12, 13, 11, 15, 14]
        XCTAssertEqual(theSushiClubGroup.tracks, theSushiClubTracksOrder.map {tracks[$0]})
    }
    
    func test_sortGroupsByDuration() {
        
        // Ascending ------------------------------------------------------------
        
        var sort = Sort().withGroupsSort(GroupsSort().withFields(.duration).withOrder(.ascending))
        let expectedGroupsOrder = ["Pink", "<Unknown>", "Grimes", "Pink Floyd", "The Sushi Club"]
        
        playlist.sort(sort)
        
        var groupsAfterSort = playlist.groups
        XCTAssertEqual(groupsAfterSort.map {$0.name}, expectedGroupsOrder)
        
        // Descending ------------------------------------------------------------
        
        sort = Sort().withGroupsSort(GroupsSort().withFields(.duration).withOrder(.descending))
        
        playlist.sort(sort)
        
        groupsAfterSort = playlist.groups
        XCTAssertEqual(groupsAfterSort.map {$0.name}, expectedGroupsOrder.reversed())
    }
    
    func test_sortTracksByName() {
        
        // Ascending ------------------------------------------------------------
        
        var sort = Sort().withTracksSort(TracksSort().withFields(.name).withOrder(.ascending))
        
        playlist.sort(sort)
        
        let unknownArtistTracksOrder = [2, 0, 1]
        XCTAssertEqual(unknownArtistGroup.tracks, unknownArtistTracksOrder.map {tracks[$0]})
        
        let grimesTracksOrder = [9, 8, 10]
        XCTAssertEqual(grimesGroup.tracks, grimesTracksOrder.map {tracks[$0]})
        
        let pinkTracksOrder = [3, 4]
        XCTAssertEqual(pinkGroup.tracks, pinkTracksOrder.map {tracks[$0]})
        
        let pinkFloydTracksOrder = [6, 5, 7]
        XCTAssertEqual(pinkFloydGroup.tracks, pinkFloydTracksOrder.map {tracks[$0]})
        
        let theSushiClubTracksOrder = [14, 12, 11, 15, 13]
        XCTAssertEqual(theSushiClubGroup.tracks, theSushiClubTracksOrder.map {tracks[$0]})
        
        // Descending ------------------------------------------------------------
        
        sort = Sort().withTracksSort(TracksSort().withFields(.name).withOrder(.descending))
        
        playlist.sort(sort)
        
        XCTAssertEqual(unknownArtistGroup.tracks, unknownArtistTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(grimesGroup.tracks, grimesTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(pinkGroup.tracks, pinkTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(pinkFloydGroup.tracks, pinkFloydTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(theSushiClubGroup.tracks, theSushiClubTracksOrder.reversed().map {tracks[$0]})
    }
    
    func test_sortTracksByAlbumDiscNumberAndTrackNumber() {
        
        // Ascending ------------------------------------------------------------
        
        var sort = Sort().withTracksSort(TracksSort().withFields(.album, .discNumberAndTrackNumber).withOrder(.ascending))
        
        playlist.sort(sort)
        
        let unknownArtistTracksOrder = [2, 0, 1]
        XCTAssertEqual(unknownArtistGroup.tracks, unknownArtistTracksOrder.map {tracks[$0]})

        let grimesTracksOrder = [8, 9, 10]
        XCTAssertEqual(grimesGroup.tracks, grimesTracksOrder.map {tracks[$0]})

        let pinkTracksOrder = [3, 4]
        XCTAssertEqual(pinkGroup.tracks, pinkTracksOrder.map {tracks[$0]})
        
        let pinkFloydTracksOrder = [6, 7, 5]
        XCTAssertEqual(pinkFloydGroup.tracks, pinkFloydTracksOrder.map {tracks[$0]})
        
        let theSushiClubTracksOrder = [12, 13, 11, 15, 14]
        XCTAssertEqual(theSushiClubGroup.tracks, theSushiClubTracksOrder.map {tracks[$0]})
        
        // Descending ------------------------------------------------------------
        
        sort = Sort().withTracksSort(TracksSort().withFields(.album, .discNumberAndTrackNumber).withOrder(.descending))

        playlist.sort(sort)

        XCTAssertEqual(unknownArtistGroup.tracks, unknownArtistTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(grimesGroup.tracks, grimesTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(pinkGroup.tracks, pinkTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(pinkFloydGroup.tracks, pinkFloydTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(theSushiClubGroup.tracks, theSushiClubTracksOrder.reversed().map {tracks[$0]})
    }
    
    func test_sortTracksByAlbumAndName() {
        
        // Ascending ------------------------------------------------------------
        
        var sort = Sort().withTracksSort(TracksSort().withFields(.album, .name).withOrder(.ascending))
        
        playlist.sort(sort)
        
        let unknownArtistTracksOrder = [2, 0, 1]
        XCTAssertEqual(unknownArtistGroup.tracks, unknownArtistTracksOrder.map {tracks[$0]})
        
        let grimesTracksOrder = [8, 9, 10]
        XCTAssertEqual(grimesGroup.tracks, grimesTracksOrder.map {tracks[$0]})
        
        let pinkTracksOrder = [3, 4]
        XCTAssertEqual(pinkGroup.tracks, pinkTracksOrder.map {tracks[$0]})
        
        let pinkFloydTracksOrder = [6, 5, 7]
        XCTAssertEqual(pinkFloydGroup.tracks, pinkFloydTracksOrder.map {tracks[$0]})
        
        let theSushiClubTracksOrder = [14, 12, 11, 15, 13]
        XCTAssertEqual(theSushiClubGroup.tracks, theSushiClubTracksOrder.map {tracks[$0]})
        
        // Descending ------------------------------------------------------------
        
        sort = Sort().withTracksSort(TracksSort().withFields(.album, .name).withOrder(.descending))
        
        playlist.sort(sort)
        
        XCTAssertEqual(unknownArtistGroup.tracks, unknownArtistTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(grimesGroup.tracks, grimesTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(pinkGroup.tracks, pinkTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(pinkFloydGroup.tracks, pinkFloydTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(theSushiClubGroup.tracks, theSushiClubTracksOrder.reversed().map {tracks[$0]})
    }
    
    func test_sortTracksByDuration() {
        
        // Ascending ------------------------------------------------------------
        
        var sort = Sort().withTracksSort(TracksSort().withFields(.duration).withOrder(.ascending))
        
        playlist.sort(sort)
        
        let unknownArtistTracksOrder = [2, 1, 0]
        XCTAssertEqual(unknownArtistGroup.tracks, unknownArtistTracksOrder.map {tracks[$0]})
        
        let grimesTracksOrder = [9, 8, 10]
        XCTAssertEqual(grimesGroup.tracks, grimesTracksOrder.map {tracks[$0]})
        
        let pinkTracksOrder = [4, 3]
        XCTAssertEqual(pinkGroup.tracks, pinkTracksOrder.map {tracks[$0]})
        
        let pinkFloydTracksOrder = [6, 5, 7]
        XCTAssertEqual(pinkFloydGroup.tracks, pinkFloydTracksOrder.map {tracks[$0]})
        
        let theSushiClubTracksOrder = [15, 11, 12, 13, 14]
        XCTAssertEqual(theSushiClubGroup.tracks, theSushiClubTracksOrder.map {tracks[$0]})
        
        // Descending ------------------------------------------------------------
        
        sort = Sort().withTracksSort(TracksSort().withFields(.duration).withOrder(.descending))
        
        playlist.sort(sort)
        
        XCTAssertEqual(unknownArtistGroup.tracks, unknownArtistTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(grimesGroup.tracks, grimesTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(pinkGroup.tracks, pinkTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(pinkFloydGroup.tracks, pinkFloydTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(theSushiClubGroup.tracks, theSushiClubTracksOrder.reversed().map {tracks[$0]})
    }
}
