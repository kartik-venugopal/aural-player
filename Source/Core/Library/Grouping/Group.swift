//
//  Group.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import OrderedCollections

class ArtistsRootGroup: Group {
    
    init(name: String, depth: Int, tracks: [Track] = []) {
        super.init(type: .root, name: name, depth: depth, tracks: tracks)
    }
    
    override func doCreateSubGroup(named groupName: String) -> Group {
        ArtistGroup(name: groupName, depth: self.depth + 1)
    }
}

class AlbumsRootGroup: Group {
    
    init(name: String, depth: Int, tracks: [Track] = []) {
        super.init(type: .root, name: name, depth: depth, tracks: tracks)
    }
    
    override func doCreateSubGroup(named groupName: String) -> Group {
        AlbumGroup(name: groupName, depth: self.depth + 1)
    }
}

class GenresRootGroup: Group {
    
    init(name: String, depth: Int, tracks: [Track] = []) {
        super.init(type: .root, name: name, depth: depth, tracks: tracks)
    }
    
    override func doCreateSubGroup(named groupName: String) -> Group {
        GenreGroup(name: groupName, depth: self.depth + 1)
    }
}

class DecadesRootGroup: Group {
    
    init(name: String, depth: Int, tracks: [Track] = []) {
        super.init(type: .root, name: name, depth: depth, tracks: tracks)
    }
    
    override func doCreateSubGroup(named groupName: String) -> Group {
        DecadeGroup(name: groupName, depth: self.depth + 1)
    }
}

class ArtistGroup: Group {
    
    init(name: String, depth: Int, tracks: [Track] = []) {
        super.init(type: .artist, name: name, depth: depth, tracks: tracks)
    }
    
    override var displayName: String {
        "artist '\(name)'"
    }
    
    override func doCreateSubGroup(named groupName: String) -> Group {
        AlbumGroup(name: groupName, depth: self.depth + 1)
    }
}

class GenreGroup: Group {
    
    init(name: String, depth: Int, tracks: [Track] = []) {
        super.init(type: .genre, name: name, depth: depth, tracks: tracks)
    }
    
    override var displayName: String {
        "genre '\(name)'"
    }
    
    override func doCreateSubGroup(named groupName: String) -> Group {
        ArtistGroup(name: groupName, depth: self.depth + 1)
    }
}

class DecadeGroup: Group {
    
    init(name: String, depth: Int, tracks: [Track] = []) {
        super.init(type: .decade, name: name, depth: depth, tracks: tracks)
    }
    
    override var displayName: String {
        "decade '\(name)'"
    }
    
    override func doCreateSubGroup(named groupName: String) -> Group {
        ArtistGroup(name: groupName, depth: self.depth + 1)
    }
}

enum GroupType: String, CaseIterable, Codable {
    
    // Special group type
    case root
    
    case artist
    case album
    case genre
    case decade
    
    case albumDisc
}

class Group: PlayableItem {
    
    let name: String
    let depth: Int
    let type: GroupType
    
    var displayName: String {
        "group '\(name)'"
    }
    
    var duration: Double {
        
        hasTracks ?
        _tracks.values.reduce(0.0, {(totalSoFar: Double, track: Track) -> Double in totalSoFar + track.duration}) :
        subGroups.values.reduce(0.0, {(totalSoFar: Double, subGroup: Group) -> Double in totalSoFar + subGroup.duration})
    }
    
    var _tracks: OrderedDictionary<URL, Track> = OrderedDictionary()
    
    var tracks: [Track] {
        hasTracks ? _tracks.elements.map {$0.value} : subGroups.values.flatMap {$0.tracks}
    }
    
    var numberOfTracks: Int {
        hasTracks ? _tracks.count : subGroups.values.reduce(0, {(totalSoFar: Int, subGroup: Group) -> Int in totalSoFar + subGroup.numberOfTracks})
    }
    
    var hasTracks: Bool {!_tracks.isEmpty}
    
    func hasTrack(forFile file: URL) -> Bool {
        _tracks[file] != nil
    }
    
    /// Safe array access.
    subscript(index: Int) -> Track {
        _tracks.elements[index].value
    }
    
    func subGroup(at index: Int) -> Group {
        subGroups.elements[index].value
    }
    
    unowned var parentGroup: Group?
    var isRootLevelGroup: Bool {parentGroup == nil}
    
    var subGroups: OrderedDictionary<String, Group> = OrderedDictionary()
    var numberOfSubGroups: Int {subGroups.count}
    var hasSubGroups: Bool {!subGroups.isEmpty}
    
    init(type: GroupType, name: String, depth: Int, tracks: [Track] = []) {
        
        self.type = type
        self.name = name
        self.depth = depth
        
        for track in tracks {
            self._tracks[track.file] = track
        }
    }
    
//    init(name: String, depth: Int, parentGroup: Group? = nil, subGroups: [Group]) {
//
//        self.name = name
//        self.depth = depth
//        self.parentGroup = parentGroup
//
//        for group in
//    }
    
    func doCreateSubGroup(named groupName: String) -> Group {
        Group(type: .artist, name: groupName, depth: self.depth + 1)
    }
    
    func findSubGroup(named groupName: String) -> Group? {
        subGroups[groupName]
    }
    
    func findOrCreateSubGroup(named groupName: String) -> Group {
        
        if let subGroup = subGroups[groupName] {
            return subGroup
        }
        
        let newGroup = doCreateSubGroup(named: groupName)
        newGroup.parentGroup = self
        subGroups[groupName] = newGroup
        
        return newGroup
    }
    
    func addSubGroup(_ subGroup: Group) {
        
        if subGroups[subGroup.name] == nil {
            
            subGroups[subGroup.name] = subGroup
            subGroup.parentGroup = self
        }
    }
    
    func removeSubGroup(_ subGroup: Group) {
        
        subGroups.removeValue(forKey: subGroup.name)
        
        if subGroups.isEmpty {
            removeFromParent()
        }
    }
    
    func removeAllSubGroups() {
        subGroups.removeAll()
    }
    
    func removeFromParent() {
        parentGroup?.removeSubGroup(self)
    }
    
    func addTracks(_ newTracks: [Track]) {
        
        for track in newTracks {
            _tracks[track.file] = track
        }
    }
    
    func sortTracks(by comparator: @escaping TrackComparator) {
        
        _tracks.sort(by: {kvPair1, kvPair2 in
            comparator(kvPair1.value, kvPair2.value)
        })
    }
    
    func sortSubGroups(by comparator: @escaping GroupComparator) {
        
        subGroups.sort(by: {kvPair1, kvPair2 in
            comparator(kvPair1.value, kvPair2.value)
        })
    }
    
    func removeTracks(_ tracksToRemove: [Track]) {
        
        for track in tracksToRemove {
            _tracks.removeValue(forKey: track.file)
        }
        
        if !hasTracks {
            removeFromParent()
        }
    }
    
    func removeAllTracks() {
        _tracks.removeAll()
    }
}
    
extension Group: Hashable {
    
    // Equatable conformance.
    static func == (lhs: Group, rhs: Group) -> Bool {
        lhs.name == rhs.name
    }
    
    // Hashable conformance.
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
