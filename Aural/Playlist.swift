/*
    Encapsulates all CRUD logic for a playlist
 */
import Foundation
import AVFoundation

class Playlist: PlaylistCRUDProtocol {
    
    private var flatPlaylist: FlatPlaylistCRUDProtocol
    private var groupingPlaylists: [GroupType: GroupingPlaylistCRUDProtocol] = [GroupType: GroupingPlaylist]()
    
    // A map to quickly look up tracks by (absolute) file path (used when adding tracks, to avoid duplicates)
    private var tracksByFilePath: [String: Track] = [String: Track]()
    
    init(_ flatPlaylist: FlatPlaylistCRUDProtocol, _ groupingPlaylists: [GroupingPlaylistCRUDProtocol]) {
        
        self.flatPlaylist = flatPlaylist
        groupingPlaylists.forEach({self.groupingPlaylists[$0.getGroupType()] = $0})
    }
    
    func getTracks() -> [Track] {
        return flatPlaylist.getTracks()
    }
    
    func size() -> Int {
        return flatPlaylist.getTracks().count
    }
    
    func totalDuration() -> Double {
        
        let tracks = flatPlaylist.getTracks()
        var totalDuration: Double = 0
        
        tracks.forEach({totalDuration += $0.duration})
        
        return totalDuration
    }
    
    func summary() -> (size: Int, totalDuration: Double) {
        return (size(), totalDuration())
    }
    
    func addTrack(_ track: Track) -> TrackAddResult? {
        
        if (!trackExists(track)) {
            
            let index = flatPlaylist.addTrackForIndex(track)!
            var groupingResults = [GroupedTrackAddResult]()
            groupingPlaylists.values.forEach({groupingResults.append($0.addTrackForGroupInfo(track))})
            
            return TrackAddResult(index: index, groupInfo: groupingResults)
        }
        
        return nil
    }
    
    // Checks whether or not a track with the given absolute file path already exists.
    private func trackExists(_ track: Track) -> Bool {
        return tracksByFilePath[track.file.path] != nil
    }
    
    func clear() {
        flatPlaylist.clear()
        groupingPlaylists.values.forEach({$0.clear()})
        tracksByFilePath.removeAll()
    }
    
    func search(_ searchQuery: SearchQuery) -> SearchResults {
        // Smart search. Depending on query options, search either flat playlist or one of the grouped playlists. For ex, if searching by artist, it makes sense to search "Artists" playlist. Also, can split up the search into multiple parts, send them to different playlists, and put results together
        
        return flatPlaylist.search(searchQuery)
    }
    
    func sort(_ sort: Sort) {
        flatPlaylist.sort(sort)
        groupingPlaylists.values.forEach({$0.sort(sort)})
    }
    
    // Returns all state for this playlist that needs to be persisted to disk
    func persistentState() -> PlaylistState {
        
        let state = PlaylistState()
        let tracks = getTracks()
        
        for track in tracks {
            state.tracks.append(track.file)
        }
        
        return state
    }
    
    func trackInfoUpdated(_ updatedTrack: Track) {
//        groupings.values.forEach({$0.trackInfoUpdated(updatedTrack)})
        // TODO: Inform all the grouping playlists
    }
    
    func removeTracks(_ tracks: [Track]) {
        // TODO: Not really necessary here ?
        print("Playlist.removeTracks([Track]) not implemented !")
    }
    
    // ----------------------- FlatPlaylist protocols ----------------------------
    
    func addTrackForIndex(_ track: Track) -> Int? {
        
        if (!trackExists(track)) {
            groupingPlaylists.values.forEach({_ = $0.addTrackForGroupInfo(track)})
            return flatPlaylist.addTrackForIndex(track)
        }
        
        return nil
    }
    
    func indexOfTrack(_ track: Track) -> Int? {
        return flatPlaylist.indexOfTrack(track)
    }
    
    func moveTracksDown(_ indexes: IndexSet) -> [Int : Int] {
        return flatPlaylist.moveTracksDown(indexes)
    }
    
    func moveTracksUp(_ indexes: IndexSet) -> [Int : Int] {
        return flatPlaylist.moveTracksUp(indexes)
    }
    
    func peekTrackAt(_ index: Int?) -> IndexedTrack? {
        return flatPlaylist.peekTrackAt(index)
    }
    
    func removeTracks(_ indexes: IndexSet) -> [Track] {
        
        let tracksRemoved = flatPlaylist.removeTracks(indexes)
        tracksRemoved.forEach({tracksByFilePath.removeValue(forKey: $0.file.path)})
        
        groupingPlaylists.values.forEach({
            $0.removeTracks(tracksRemoved)
        })
        
        return tracksRemoved
    }
    
    func reorderTracks(_ reorderOperations: [PlaylistReorderOperation]) {
        flatPlaylist.reorderTracks(reorderOperations)
    }
    
    // ----------------------- GroupingPlaylist protocols ----------------------------
    
    func getGroupAt(_ type: GroupType, _ index: Int) -> Group {
        return groupingPlaylists[type]!.getGroupAt(index)
    }
    
    func getGroupingInfoForTrack(_ type: GroupType, _ track: Track) -> GroupedTrack {
        return groupingPlaylists[type]!.getGroupingInfoForTrack(track)
    }
    
    func getIndexOf(_ group: Group) -> Int {
        return groupingPlaylists[group.type]!.getIndexOf(group)
    }
    
    func getNumberOfGroups(_ type: GroupType) -> Int {
        return groupingPlaylists[type]!.getNumberOfGroups()
    }
    
    func addTrackForGroupInfo(_ track: Track) -> [GroupedTrackAddResult]? {
        
        if (!trackExists(track)) {
        
            _ = flatPlaylist.addTrackForIndex(track)
            
            var groupingResults = [GroupedTrackAddResult]()
            groupingPlaylists.values.forEach({groupingResults.append($0.addTrackForGroupInfo(track))})
            
            return groupingResults
        }
        
        return nil
    }
    
    func removeTracksAndGroups(_ request: RemoveTracksAndGroupsRequest) {
        
        // Can remove groups only from grouping playlist matching request's group type
        let groupType = request.groupType
        groupingPlaylists[groupType]!.removeTracksAndGroups(request)
        
        // For the other playlists, need to expand the removed groups into individual tracks
        var removedTracks: [Track] = [Track]()
        
        request.mappings.forEach({
            // Just expand all removed groups into their constituent tracks
            removedTracks.append(contentsOf: $0.groupRemoved ? $0.group.tracks : $0.tracks!)
        })
        
        groupingPlaylists.values.forEach({
        
            if $0.getGroupType() != groupType {
                $0.removeTracks(removedTracks)
            }
        })
        
        flatPlaylist.removeTracks(removedTracks)
    }
    
    func displayNameFor(_ type: GroupType, _ track: Track) -> String {
        return groupingPlaylists[type]!.displayNameFor(track)
    }
}

struct TrackAddResult {
    
    let index: Int
    let groupInfo: [GroupedTrackAddResult]
}

struct GroupedTrackAddResult {
    
    let type: GroupType
    let track: GroupedTrack
    let groupCreated: Bool
}

struct TrackRemoveResults {
    
    let results: [(parentGroup: Group?, parentGroupIndex: Int?, childIndex: Int)]
}
