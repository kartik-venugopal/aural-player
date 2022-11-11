//
//  GroupingPlaylistTests+SortGenresPlaylist.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class GroupingPlaylistTests_SortGenresPlaylist: GroupingPlaylistTestCase {
    
    let playlist = GroupingPlaylist(.genres)
    
    lazy var tracks = [createTrack(fileName: "track09", duration: 255.456456),
                       createTrack(fileName: "track11", duration: 187.24342),
                       createTrack(fileName: "04 - Endless Dream", duration: 139.835345),
                       
                       createTrack(title: "Have a Cigar", duration: 303.11246, artist: "Pink Floyd", album: "Wish You Were Here",
                                   genre: "Rock", discNum: 1, trackNum: 4),
                       
                       createTrack(title: "Welcome to the Machine", duration: 135.9696, artist: "Pink Floyd", album: "Wish You Were Here",
                                   genre: "Rock", discNum: 1, trackNum: 12),
                       
                       createTrack(title: "Money", duration: 403.93346, artist: "Pink Floyd", album: "Dark Side of the Moon",
                                   genre: "Rock", discNum: 1, trackNum: 6),
                       
                       createTrack(title: "Breathe", duration: 135.9696, artist: "Pink Floyd", album: "Dark Side of the Moon",
                                   genre: "Rock", discNum: 1, trackNum: 2),
                       
                       createTrack(title: "Time", duration: 593.23563, artist: "Pink Floyd", album: "Dark Side of the Moon",
                                   genre: "Rock", discNum: 1, trackNum: 4),
                       
                       createTrack(title: "Money for Nothing", duration: 403.93346, artist: "Dire Straits", album: "Brothers in Arms",
                                   genre: "Rock", discNum: 1, trackNum: 6),
                       
                       createTrack(title: "Sultans of Swing", duration: 135.9696, artist: "Dire Straits", album: "Dark Side of the Moon",
                                   genre: "Rock", discNum: 1, trackNum: 2),
                       
                       createTrack(title: "Private Investigations", duration: 593.23563, artist: "Dire Straits", album: "Dark Side of the Moon",
                                   genre: "Rock", discNum: 1, trackNum: 4),
                       
                       createTrack(title: "Dream Fortress", duration: 360.73346, artist: "Grimes", album: "Halfaxa",
                                   genre: "Electronica", discNum: 1, trackNum: 8),
                       
                       createTrack(title: "Be a Body", duration: 256.58756, artist: "Grimes", album: "Visions",
                                   genre: "Electronica", discNum: 1, trackNum: 8),
                       
                       createTrack(title: "Skin", duration: 426.9756, artist: "Grimes", album: "Visions",
                                   genre: "Electronica", discNum: 1, trackNum: 12),
                       
                       createTrack(title: "Lunaria", duration: 124.5345, artist: "The Sushi Club", album: "Lunarium",
                                   genre: "Dance & Dj", discNum: 1, trackNum: 13),
                       
                       createTrack(title: "Dopia", duration: 254.6432, artist: "The Sushi Club", album: "Lunarium",
                                   genre: "Dance & Dj", discNum: 1, trackNum: 2),
                       
                       createTrack(title: "Piota", duration: 314.9878, artist: "The Sushi Club", album: "Lunarium",
                                   genre: "Dance & Dj", discNum: 1, trackNum: 6),
                       
                       createTrack(title: "Atropia", duration: 532.9807, artist: "The Sushi Club", album: "Lunarium",
                                   genre: "Dance & Dj", discNum: 2, trackNum: 10),
                       
                       createTrack(title: "Mycel", duration: 92.1824, artist: "The Sushi Club", album: "Lunarium",
                                   genre: "Dance & Dj", discNum: 2, trackNum: 3)]
    
    lazy var unknownGenreGroup = playlist.groups.first(where: {$0.name == "<Unknown>"})!
    lazy var rockGroup = playlist.groups.first(where: {$0.name == "Rock"})!
    lazy var electronicaGroup = playlist.groups.first(where: {$0.name == "Electronica"})!
    lazy var danceAndDJGroup = playlist.groups.first(where: {$0.name == "Dance & Dj"})!
    
//    override func setUp() {
//
//        super.setUp()
//
//        for track in tracks.shuffled() {
//            _ = playlist.addTrack(track)
//        }
//
//        XCTAssertEqual(playlist.numberOfGroups, 4)
//
//        let sg = playlist.groups.sorted(by: {$0.duration < $1.duration})
//        print(sg.map {$0.name})
//    }
//
//    func test_sortGroupsByName() {
//
//        // Ascending ------------------------------------------------------------
//
//        var sort = Sort().withGroupsSort(GroupsSort().withFields(.name).withOrder(.ascending))
//        let expectedGroupsOrder = ["<Unknown>", "Dance & Dj", "Electronica", "Rock"]
//
//        playlist.sort(sort)
//
//        var groupsAfterSort = playlist.groups
//        XCTAssertEqual(groupsAfterSort.map {$0.name}, expectedGroupsOrder)
//
//        // Descending ------------------------------------------------------------
//
//        sort = Sort().withGroupsSort(GroupsSort().withFields(.name).withOrder(.descending))
//
//        playlist.sort(sort)
//
//        groupsAfterSort = playlist.groups
//        XCTAssertEqual(groupsAfterSort.map {$0.name}, expectedGroupsOrder.reversed())
//    }
//
//    func test_sortGroupsByName_sortTracksByArtistAlbumDiscNumberAndTrackNumber() {
//
//        let sort = Sort().withGroupsSort(GroupsSort().withFields(.name).withOrder(.ascending))
//            .withTracksSort(TracksSort().withFields(.artist, .album, .discNumberAndTrackNumber).withOrder(.ascending))
//
//        let expectedGroupsOrder = ["<Unknown>", "Dance & Dj", "Electronica", "Rock"]
//
//        playlist.sort(sort)
//
//        let groupsAfterSort = playlist.groups
//        XCTAssertEqual(groupsAfterSort.map {$0.name}, expectedGroupsOrder)
//
//        let unknownGenreTracksOrder = [2, 0, 1]
//        XCTAssertEqual(unknownGenreGroup.tracks, unknownGenreTracksOrder.map {tracks[$0]})
//
//        let rockTracksOrder = [6, 7, 5, 3, 4]
//        XCTAssertEqual(rockGroup.tracks, rockTracksOrder.map {tracks[$0]})
//    }
//
//    func test_sortGroupsByDuration() {
//
//        // Ascending ------------------------------------------------------------
//
//        var sort = Sort().withGroupsSort(GroupsSort().withFields(.duration).withOrder(.ascending))
//        let expectedGroupsOrder = ["<Unknown>", "Electronica", "Dance & Dj", "Rock"]
//
//        playlist.sort(sort)
//
//        var groupsAfterSort = playlist.groups
//        XCTAssertEqual(groupsAfterSort.map {$0.name}, expectedGroupsOrder)
//
//        // Descending ------------------------------------------------------------
//
//        sort = Sort().withGroupsSort(GroupsSort().withFields(.duration).withOrder(.descending))
//
//        playlist.sort(sort)
//
//        groupsAfterSort = playlist.groups
//        XCTAssertEqual(groupsAfterSort.map {$0.name}, expectedGroupsOrder.reversed())
//    }
//
//    func test_sortTracksByName() {
//
//        // Ascending ------------------------------------------------------------
//
//        var sort = Sort().withTracksSort(TracksSort().withFields(.name).withOrder(.ascending))
//
//        playlist.sort(sort)
//
//        let unknownAlbumTracksOrder = [2, 0, 1]
//        XCTAssertEqual(unknownGenreGroup.tracks, unknownAlbumTracksOrder.map {tracks[$0]})
//
//        let rockTracksOrder = [6, 3, 5, 7, 4]
//        XCTAssertEqual(rockGroup.tracks, rockTracksOrder.map {tracks[$0]})
//
//        let electronicaTracksOrder = [9, 8, 10]
//        XCTAssertEqual(electronicaGroup.tracks, electronicaTracksOrder.map {tracks[$0]})
//
//        let danceAndDJTracksOrder = [14, 12, 11, 15, 13]
//        XCTAssertEqual(danceAndDJGroup.tracks, danceAndDJTracksOrder.map {tracks[$0]})
//
//        // Descending ------------------------------------------------------------
//
//        sort = Sort().withTracksSort(TracksSort().withFields(.name).withOrder(.descending))
//
//        playlist.sort(sort)
//
//        XCTAssertEqual(unknownGenreGroup.tracks, unknownAlbumTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(rockGroup.tracks, rockTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(electronicaGroup.tracks, electronicaTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(danceAndDJGroup.tracks, danceAndDJTracksOrder.reversed().map {tracks[$0]})
//    }
//
//    func test_sortTracksByArtistAlbumDiscNumberAndTrackNumber() {
//
//        // Ascending ------------------------------------------------------------
//
//        var sort = Sort().withTracksSort(TracksSort().withFields(.artist, .album, .discNumberAndTrackNumber).withOrder(.ascending))
//
//        playlist.sort(sort)
//
//        let unknownAlbumTracksOrder = [2, 0, 1]
//        XCTAssertEqual(unknownGenreGroup.tracks, unknownAlbumTracksOrder.map {tracks[$0]})
//
//        let rockTracksOrder = [6, 3, 5, 7, 4]
//        XCTAssertEqual(rockGroup.tracks, rockTracksOrder.map {tracks[$0]})
//
//        let electronicaTracksOrder = [8, 9, 10]
//        XCTAssertEqual(electronicaGroup.tracks, electronicaTracksOrder.map {tracks[$0]})
//
//        let danceAndDJTracksOrder = [12, 13, 11, 15, 14]
//        XCTAssertEqual(danceAndDJGroup.tracks, danceAndDJTracksOrder.map {tracks[$0]})
//
//        // Descending ------------------------------------------------------------
//
//        sort = Sort().withTracksSort(TracksSort().withFields(.artist, .album, .discNumberAndTrackNumber).withOrder(.descending))
//
//        playlist.sort(sort)
//
//        XCTAssertEqual(unknownGenreGroup.tracks, unknownAlbumTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(rockGroup.tracks, rockTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(electronicaGroup.tracks, electronicaTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(danceAndDJGroup.tracks, danceAndDJTracksOrder.reversed().map {tracks[$0]})
//    }
//
//    func test_sortTracksByArtistAlbumAndName() {
//
//        // Ascending ------------------------------------------------------------
//
//        var sort = Sort().withTracksSort(TracksSort().withFields(.artist, .album, .name).withOrder(.ascending))
//
//        playlist.sort(sort)
//
//        let unknownAlbumTracksOrder = [2, 0, 1]
//        XCTAssertEqual(unknownGenreGroup.tracks, unknownAlbumTracksOrder.map {tracks[$0]})
//
//        let rockTracksOrder = [6, 5, 7, 3, 4]
//        XCTAssertEqual(rockGroup.tracks, rockTracksOrder.map {tracks[$0]})
//
//        let electronicaTracksOrder = [8, 9, 10]
//        XCTAssertEqual(electronicaGroup.tracks, electronicaTracksOrder.map {tracks[$0]})
//
//        let danceAndDJTracksOrder = [14, 12, 11, 15, 13]
//        XCTAssertEqual(danceAndDJGroup.tracks, danceAndDJTracksOrder.map {tracks[$0]})
//
//        // Descending ------------------------------------------------------------
//
//        sort = Sort().withTracksSort(TracksSort().withFields(.artist, .album, .name).withOrder(.descending))
//
//        playlist.sort(sort)
//
//        XCTAssertEqual(unknownGenreGroup.tracks, unknownAlbumTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(rockGroup.tracks, rockTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(electronicaGroup.tracks, electronicaTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(danceAndDJGroup.tracks, danceAndDJTracksOrder.reversed().map {tracks[$0]})
//    }
//
//    func test_sortTracksByArtistAndName() {
//
//        // Ascending ------------------------------------------------------------
//
//        var sort = Sort().withTracksSort(TracksSort().withFields(.artist, .name).withOrder(.ascending))
//
//        playlist.sort(sort)
//
//        let unknownAlbumTracksOrder = [2, 0, 1]
//        XCTAssertEqual(unknownGenreGroup.tracks, unknownAlbumTracksOrder.map {tracks[$0]})
//
//        let rockTracksOrder = [6, 3, 5, 7, 4]
//        XCTAssertEqual(rockGroup.tracks, rockTracksOrder.map {tracks[$0]})
//
//        let electronicaTracksOrder = [9, 8, 10]
//        XCTAssertEqual(electronicaGroup.tracks, electronicaTracksOrder.map {tracks[$0]})
//
//        let danceAndDJTracksOrder = [14, 12, 11, 15, 13]
//        XCTAssertEqual(danceAndDJGroup.tracks, danceAndDJTracksOrder.map {tracks[$0]})
//
//        // Descending ------------------------------------------------------------
//
//        sort = Sort().withTracksSort(TracksSort().withFields(.artist, .name).withOrder(.descending))
//
//        playlist.sort(sort)
//
//        XCTAssertEqual(unknownGenreGroup.tracks, unknownAlbumTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(rockGroup.tracks, rockTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(electronicaGroup.tracks, electronicaTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(danceAndDJGroup.tracks, danceAndDJTracksOrder.reversed().map {tracks[$0]})
//    }
//
//    func test_sortTracksByAlbumDiscNumberAndTrackNumber() {
//
//        // Ascending ------------------------------------------------------------
//
//        var sort = Sort().withTracksSort(TracksSort().withFields(.artist, .album, .discNumberAndTrackNumber).withOrder(.ascending))
//
//        playlist.sort(sort)
//
//        let unknownAlbumTracksOrder = [2, 0, 1]
//        XCTAssertEqual(unknownGenreGroup.tracks, unknownAlbumTracksOrder.map {tracks[$0]})
//
//        let rockTracksOrder = [6, 3, 5, 7, 4]
//        XCTAssertEqual(rockGroup.tracks, rockTracksOrder.map {tracks[$0]})
//
//        let electronicaTracksOrder = [8, 9, 10]
//        XCTAssertEqual(electronicaGroup.tracks, electronicaTracksOrder.map {tracks[$0]})
//
//        let danceAndDJTracksOrder = [12, 13, 11, 15, 14]
//        XCTAssertEqual(danceAndDJGroup.tracks, danceAndDJTracksOrder.map {tracks[$0]})
//
//        // Descending ------------------------------------------------------------
//
//        sort = Sort().withTracksSort(TracksSort().withFields(.artist, .album, .discNumberAndTrackNumber).withOrder(.descending))
//
//        playlist.sort(sort)
//
//        XCTAssertEqual(unknownGenreGroup.tracks, unknownAlbumTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(rockGroup.tracks, rockTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(electronicaGroup.tracks, electronicaTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(danceAndDJGroup.tracks, danceAndDJTracksOrder.reversed().map {tracks[$0]})
//    }
//
//    func test_sortTracksByAlbumAndName() {
//
//        // Ascending ------------------------------------------------------------
//
//        var sort = Sort().withTracksSort(TracksSort().withFields(.artist, .album, .name).withOrder(.ascending))
//
//        playlist.sort(sort)
//
//        let unknownAlbumTracksOrder = [2, 0, 1]
//        XCTAssertEqual(unknownGenreGroup.tracks, unknownAlbumTracksOrder.map {tracks[$0]})
//
//        let rockTracksOrder = [6, 5, 7, 3, 4]
//        XCTAssertEqual(rockGroup.tracks, rockTracksOrder.map {tracks[$0]})
//
//        let electronicaTracksOrder = [8, 9, 10]
//        XCTAssertEqual(electronicaGroup.tracks, electronicaTracksOrder.map {tracks[$0]})
//
//        let danceAndDJTracksOrder = [14, 12, 11, 15, 13]
//        XCTAssertEqual(danceAndDJGroup.tracks, danceAndDJTracksOrder.map {tracks[$0]})
//
//        // Descending ------------------------------------------------------------
//
//        sort = Sort().withTracksSort(TracksSort().withFields(.artist, .album, .name).withOrder(.descending))
//
//        playlist.sort(sort)
//
//        XCTAssertEqual(unknownGenreGroup.tracks, unknownAlbumTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(rockGroup.tracks, rockTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(electronicaGroup.tracks, electronicaTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(danceAndDJGroup.tracks, danceAndDJTracksOrder.reversed().map {tracks[$0]})
//    }
//
//    func test_sortTracksByDuration() {
//
//        // Ascending ------------------------------------------------------------
//
//        var sort = Sort().withTracksSort(TracksSort().withFields(.duration).withOrder(.ascending))
//
//        playlist.sort(sort)
//
//        let unknownAlbumTracksOrder = [2, 1, 0]
//        XCTAssertEqual(unknownGenreGroup.tracks, unknownAlbumTracksOrder.map {tracks[$0]})
//
//        let halfaxaTracksOrder = [8]
//        XCTAssertEqual(halfaxaGroup.tracks, halfaxaTracksOrder.map {tracks[$0]})
//
//        let visionsTracksOrder = [9, 10]
//        XCTAssertEqual(visionsGroup.tracks, visionsTracksOrder.map {tracks[$0]})
//
//        let wishYouWereHereTracksOrder = [4, 3]
//        XCTAssertEqual(wishYouWereHereGroup.tracks, wishYouWereHereTracksOrder.map {tracks[$0]})
//
//        let darkSideOfTheMoonTracksOrder = [6, 5, 7]
//        XCTAssertEqual(darkSideOfTheMoonGroup.tracks, darkSideOfTheMoonTracksOrder.map {tracks[$0]})
//
//        let lunariumTracksOrder = [15, 11, 12, 13, 14]
//        XCTAssertEqual(lunariumGroup.tracks, lunariumTracksOrder.map {tracks[$0]})
//
//        // Descending ------------------------------------------------------------
//
//        sort = Sort().withTracksSort(TracksSort().withFields(.duration).withOrder(.descending))
//
//        playlist.sort(sort)
//
//        XCTAssertEqual(unknownGenreGroup.tracks, unknownAlbumTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(halfaxaGroup.tracks, halfaxaTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(visionsGroup.tracks, visionsTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(wishYouWereHereGroup.tracks, wishYouWereHereTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(darkSideOfTheMoonGroup.tracks, darkSideOfTheMoonTracksOrder.reversed().map {tracks[$0]})
//        XCTAssertEqual(lunariumGroup.tracks, lunariumTracksOrder.reversed().map {tracks[$0]})
//    }
}
