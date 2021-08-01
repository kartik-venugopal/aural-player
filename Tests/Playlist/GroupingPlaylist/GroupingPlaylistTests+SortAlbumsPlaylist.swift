//
//  GroupingPlaylistTests+SortAlbumsPlaylist.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class GroupingPlaylistTests_SortAlbumsPlaylist: GroupingPlaylistTestCase {
    
    let playlist = GroupingPlaylist(.albums)
    
    lazy var tracks = [createTrack(fileName: "track09", duration: 255.456456),
                       createTrack(fileName: "track11", duration: 187.24342),
                       createTrack(fileName: "04 - Endless Dream", duration: 139.835345),
                       
                       createTrack(title: "Have a Cigar", duration: 303.11246, artist: "Pink Floyd", album: "Wish You Were Here",
                                   discNum: 1, trackNum: 4),
                       
                       createTrack(title: "Welcome to the Machine", duration: 135.9696, artist: "Pink Floyd", album: "Wish You Were Here",
                                   discNum: 1, trackNum: 12),
                       
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
    
    lazy var unknownAlbumGroup = playlist.groups.first(where: {$0.name == "<Unknown>"})!
    lazy var halfaxaGroup = playlist.groups.first(where: {$0.name == "Halfaxa"})!
    lazy var visionsGroup = playlist.groups.first(where: {$0.name == "Visions"})!
    lazy var wishYouWereHereGroup = playlist.groups.first(where: {$0.name == "Wish You Were Here"})!
    lazy var darkSideOfTheMoonGroup = playlist.groups.first(where: {$0.name == "Dark Side of the Moon"})!
    lazy var lunariumGroup = playlist.groups.first(where: {$0.name == "Lunarium"})!
    
    override func setUp() {
        
        super.setUp()
        
        for track in tracks.shuffled() {
            _ = playlist.addTrack(track)
        }
        
        XCTAssertEqual(playlist.numberOfGroups, 6)
    }
    
    func test_sortGroupsByName() {
        
        // Ascending ------------------------------------------------------------
        
        var sort = Sort().withGroupsSort(GroupsSort().withFields(.name).withOrder(.ascending))
        let expectedGroupsOrder = ["<Unknown>", "Dark Side of the Moon", "Halfaxa", "Lunarium", "Visions", "Wish You Were Here"]
        
        playlist.sort(sort)
        
        var groupsAfterSort = playlist.groups
        XCTAssertEqual(groupsAfterSort.map {$0.name}, expectedGroupsOrder)
        
        // Descending ------------------------------------------------------------
        
        sort = Sort().withGroupsSort(GroupsSort().withFields(.name).withOrder(.descending))
        
        playlist.sort(sort)
        
        groupsAfterSort = playlist.groups
        XCTAssertEqual(groupsAfterSort.map {$0.name}, expectedGroupsOrder.reversed())
    }
    
    func test_sortGroupsByName_sortTracksByDiscNumberAndTrackNumber() {
        
        let sort = Sort().withGroupsSort(GroupsSort().withFields(.name).withOrder(.ascending))
            .withTracksSort(TracksSort().withFields(.discNumberAndTrackNumber).withOrder(.ascending))
        
        let expectedGroupsOrder = ["<Unknown>", "Dark Side of the Moon", "Halfaxa", "Lunarium", "Visions", "Wish You Were Here"]
        
        playlist.sort(sort)
        
        let groupsAfterSort = playlist.groups
        XCTAssertEqual(groupsAfterSort.map {$0.name}, expectedGroupsOrder)
        
        let unknownAlbumTracksOrder = [2, 0, 1]
        XCTAssertEqual(unknownAlbumGroup.tracks, unknownAlbumTracksOrder.map {tracks[$0]})

        let halfaxaTracksOrder = [8]
        XCTAssertEqual(halfaxaGroup.tracks, halfaxaTracksOrder.map {tracks[$0]})
        
        let visionsTracksOrder = [9, 10]
        XCTAssertEqual(visionsGroup.tracks, visionsTracksOrder.map {tracks[$0]})

        let wishYouWereHereTracksOrder = [3, 4]
        XCTAssertEqual(wishYouWereHereGroup.tracks, wishYouWereHereTracksOrder.map {tracks[$0]})
        
        let darkSideOfTheMoonTracksOrder = [6, 7, 5]
        XCTAssertEqual(darkSideOfTheMoonGroup.tracks, darkSideOfTheMoonTracksOrder.map {tracks[$0]})
        
        let lunariumTracksOrder = [12, 13, 11, 15, 14]
        XCTAssertEqual(lunariumGroup.tracks, lunariumTracksOrder.map {tracks[$0]})
    }
    
    func test_sortGroupsByDuration() {
        
        // Ascending ------------------------------------------------------------
        
        var sort = Sort().withGroupsSort(GroupsSort().withFields(.duration).withOrder(.ascending))
        let expectedGroupsOrder = ["Halfaxa", "Wish You Were Here", "<Unknown>", "Visions", "Dark Side of the Moon", "Lunarium"]
        
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
        
        let unknownAlbumTracksOrder = [2, 0, 1]
        XCTAssertEqual(unknownAlbumGroup.tracks, unknownAlbumTracksOrder.map {tracks[$0]})

        let halfaxaTracksOrder = [8]
        XCTAssertEqual(halfaxaGroup.tracks, halfaxaTracksOrder.map {tracks[$0]})
        
        let visionsTracksOrder = [9, 10]
        XCTAssertEqual(visionsGroup.tracks, visionsTracksOrder.map {tracks[$0]})

        let wishYouWereHereTracksOrder = [3, 4]
        XCTAssertEqual(wishYouWereHereGroup.tracks, wishYouWereHereTracksOrder.map {tracks[$0]})
        
        let darkSideOfTheMoonTracksOrder = [6, 5, 7]
        XCTAssertEqual(darkSideOfTheMoonGroup.tracks, darkSideOfTheMoonTracksOrder.map {tracks[$0]})
        
        let lunariumTracksOrder = [14, 12, 11, 15, 13]
        XCTAssertEqual(lunariumGroup.tracks, lunariumTracksOrder.map {tracks[$0]})
        
        // Descending ------------------------------------------------------------
        
        sort = Sort().withTracksSort(TracksSort().withFields(.name).withOrder(.descending))
        
        playlist.sort(sort)
        
        XCTAssertEqual(unknownAlbumGroup.tracks, unknownAlbumTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(halfaxaGroup.tracks, halfaxaTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(visionsGroup.tracks, visionsTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(wishYouWereHereGroup.tracks, wishYouWereHereTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(darkSideOfTheMoonGroup.tracks, darkSideOfTheMoonTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(lunariumGroup.tracks, lunariumTracksOrder.reversed().map {tracks[$0]})
    }
    
    func test_sortTracksByDiscNumberAndTrackNumber() {
        
        // Ascending ------------------------------------------------------------
        
        var sort = Sort().withTracksSort(TracksSort().withFields(.discNumberAndTrackNumber).withOrder(.ascending))
        
        playlist.sort(sort)
        
        let unknownAlbumTracksOrder = [2, 0, 1]
        XCTAssertEqual(unknownAlbumGroup.tracks, unknownAlbumTracksOrder.map {tracks[$0]})

        let halfaxaTracksOrder = [8]
        XCTAssertEqual(halfaxaGroup.tracks, halfaxaTracksOrder.map {tracks[$0]})
        
        let visionsTracksOrder = [9, 10]
        XCTAssertEqual(visionsGroup.tracks, visionsTracksOrder.map {tracks[$0]})

        let wishYouWereHereTracksOrder = [3, 4]
        XCTAssertEqual(wishYouWereHereGroup.tracks, wishYouWereHereTracksOrder.map {tracks[$0]})
        
        let darkSideOfTheMoonTracksOrder = [6, 7, 5]
        XCTAssertEqual(darkSideOfTheMoonGroup.tracks, darkSideOfTheMoonTracksOrder.map {tracks[$0]})
        
        let lunariumTracksOrder = [12, 13, 11, 15, 14]
        XCTAssertEqual(lunariumGroup.tracks, lunariumTracksOrder.map {tracks[$0]})
        
        // Descending ------------------------------------------------------------
        
        sort = Sort().withTracksSort(TracksSort().withFields(.discNumberAndTrackNumber).withOrder(.descending))

        playlist.sort(sort)

        XCTAssertEqual(unknownAlbumGroup.tracks, unknownAlbumTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(halfaxaGroup.tracks, halfaxaTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(visionsGroup.tracks, visionsTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(wishYouWereHereGroup.tracks, wishYouWereHereTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(darkSideOfTheMoonGroup.tracks, darkSideOfTheMoonTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(lunariumGroup.tracks, lunariumTracksOrder.reversed().map {tracks[$0]})
    }
    
    func test_sortTracksByDuration() {
        
        // Ascending ------------------------------------------------------------
        
        var sort = Sort().withTracksSort(TracksSort().withFields(.duration).withOrder(.ascending))
        
        playlist.sort(sort)
        
        let unknownAlbumTracksOrder = [2, 1, 0]
        XCTAssertEqual(unknownAlbumGroup.tracks, unknownAlbumTracksOrder.map {tracks[$0]})

        let halfaxaTracksOrder = [8]
        XCTAssertEqual(halfaxaGroup.tracks, halfaxaTracksOrder.map {tracks[$0]})
        
        let visionsTracksOrder = [9, 10]
        XCTAssertEqual(visionsGroup.tracks, visionsTracksOrder.map {tracks[$0]})

        let wishYouWereHereTracksOrder = [4, 3]
        XCTAssertEqual(wishYouWereHereGroup.tracks, wishYouWereHereTracksOrder.map {tracks[$0]})
        
        let darkSideOfTheMoonTracksOrder = [6, 5, 7]
        XCTAssertEqual(darkSideOfTheMoonGroup.tracks, darkSideOfTheMoonTracksOrder.map {tracks[$0]})
        
        let lunariumTracksOrder = [15, 11, 12, 13, 14]
        XCTAssertEqual(lunariumGroup.tracks, lunariumTracksOrder.map {tracks[$0]})
        
        // Descending ------------------------------------------------------------
        
        sort = Sort().withTracksSort(TracksSort().withFields(.duration).withOrder(.descending))

        playlist.sort(sort)

        XCTAssertEqual(unknownAlbumGroup.tracks, unknownAlbumTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(halfaxaGroup.tracks, halfaxaTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(visionsGroup.tracks, visionsTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(wishYouWereHereGroup.tracks, wishYouWereHereTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(darkSideOfTheMoonGroup.tracks, darkSideOfTheMoonTracksOrder.reversed().map {tracks[$0]})
        XCTAssertEqual(lunariumGroup.tracks, lunariumTracksOrder.reversed().map {tracks[$0]})
    }
}
