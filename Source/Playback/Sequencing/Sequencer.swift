//
//  Sequencer.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Provides convenient CRUD access to the playback sequence
/// to select tracks/groups for playback and/or determine which track will play next.
///
/// The Sequencer is what enables the Player to keep track of which track
/// is currently playing.
///
/// - SeeAlso: `SequencerProtocol`
/// - SeeAlso: `PlaybackSequence`
///
class Sequencer: SequencerProtocol, NotificationSubscriber {
    
    // The underlying linear sequence of tracks for the current playback scope
    let sequence: PlaybackSequence
    
    // The current playback scope (See SequenceScope for more details)
    // NOTE - The default sequence scope is "All tracks"
    let scope: SequenceScope
    
    // The current playlist view type selected by the user (this is used to determine the scope)
    private(set) var playlistType: PlaylistType = .tracks
    
    // Used to access the playlist's tracks/groups
    private let playlist: PlaylistAccessorProtocol
    
    // Stores the currently playing track, if there is one
    private(set) var currentTrack: Track?
    
    private lazy var messenger = Messenger(for: self)
    
    init(persistentState: PlaybackSequencePersistentState?, _ playlist: PlaylistAccessorProtocol, _ playlistType: PlaylistType) {
        
        let repeatMode = persistentState?.repeatMode ?? .defaultMode
        let shuffleMode = persistentState?.shuffleMode ?? .defaultMode
        
        self.sequence = PlaybackSequence(repeatMode, shuffleMode)
        self.playlist = playlist
        
        self.playlistType = playlistType
        self.scope = SequenceScope(playlistType.toPlaylistScopeType())
        
        // Subscribe to notifications that the playlist view type has changed
        messenger.subscribe(to: .playlist_viewChanged, handler: playlistTypeChanged(_:))
    }
    
    var sequenceInfo: (scope: SequenceScope, trackIndex: Int, totalTracks: Int) {
        
        // The sequence cursor is the index of the currently playing track within the current playback sequence
        return (scope, (sequence.curTrackIndex ?? -1) + 1, sequence.size)
    }
    
    func begin() -> Track? {
        
        // Set the scope of the new sequence according to the playlist view type. For ex, if the "Artists" playlist view is selected, the new sequence will consist of all tracks in the "Artists" playlist, and the order of playback will be determined by the ordering within the Artists playlist (in addition to the repeat/shuffle modes).
        
        scope.type = playlistType.toPlaylistScopeType()
        scope.group = nil
        
        // Reset the sequence, with the size of the playlist
        sequence.resizeAndStart(size: playlist.size, withTrackIndex: nil)
        
        // Begin playing the subsequent track (first track determined by the sequence)
        return subsequent()
    }
    
    func end() {
        
        // Reset the sequence cursor (to indicate that no track is playing)
        sequence.end()
        currentTrack = nil
        
        // Reset the scope and the scope type depending on which playlist view is currently selected
        scope.group = nil
        scope.type = playlistType.toPlaylistScopeType()
    }
    
    // MARK: Specific track selection functions -------------------------------------------------------------------------------------
    
    func select(_ index: Int) -> Track? {
        
        // "All tracks" playback scope implied. So, reset the scope to allTracks, and reset the sequence size.
        scope.type = .allTracks
        scope.group = nil
        
        return startSequence(playlist.size, index)
    }
    
    // Helper function to select a track with a specific index within the current playback sequence
    private func startSequence(_ size: Int, _ trackIndex: Int) -> Track? {
        
        sequence.resizeAndStart(size: size, withTrackIndex: trackIndex)
        
        if let track = getTrackForSequenceIndex(trackIndex) {
            
            currentTrack = track
            return track
        }
        
        return nil
    }
    
    func select(_ track: Track) -> Track? {
        
        if playlistType == .tracks, let index = playlist.indexOfTrack(track) {
            return select(index)
        }
        
        // Get the parent group of the selected track, and set it as the playback scope
        if let scopeType = playlistType.toGroupScopeType(), let groupType = playlistType.toGroupType(),
            let groupInfo = playlist.groupingInfoForTrack(groupType, track) {
            
            scope.type = scopeType
            scope.group = groupInfo.group
            
            // Select the specified track within its parent group, for playback
            return startSequence(groupInfo.group.size, groupInfo.trackIndex)
        }
        
        return nil
    }
    
    func select(_ group: Group) -> Track? {
        
        // Determine the type of the selected track's parent group (which depends on which playlist view type is selected). This will determine the scope type.
        scope.type = group.type.toScopeType()
        
        // Set the scope to the selected group
        scope.group = group
        
        // Reset the sequence based on the group's size
        sequence.resizeAndStart(size: group.size, withTrackIndex: nil)
        
        // Begin playing the subsequent track (first track determined by the sequence)
        return subsequent()
    }
    
    // MARK: Sequence iteration functions -------------------------------------------------------------------------------------
    
    func subsequent() -> Track? {
        
        let subsequent = getTrackForSequenceIndex(sequence.subsequent())
        currentTrack = subsequent
        return subsequent
    }
    
    func next() -> Track? {

        // If there is no next track, don't change the playingTrack variable, because the playing track will continue playing
        if let next = getTrackForSequenceIndex(sequence.next()) {
            
            currentTrack = next
            return next
        }
        
        return nil
    }
    
    func previous() -> Track? {
        
        // If there is no previous track, don't change the playingTrack variable, because the playing track will continue playing
        if let previous = getTrackForSequenceIndex(sequence.previous()) {
            
            currentTrack = previous
            return previous
        }
        
        return nil
    }
    
    func peekSubsequent() -> Track? {
        return getTrackForSequenceIndex(sequence.peekSubsequent())
    }
    
    func peekNext() -> Track? {
        return getTrackForSequenceIndex(sequence.peekNext())
    }
    
    func peekPrevious() -> Track? {
        return getTrackForSequenceIndex(sequence.peekPrevious())
    }
    
    // Helper function that, given the index of a track within the current plyback sequence,
    // returns the corresponding track and its index within the playlist.
    private func getTrackForSequenceIndex(_ sequenceIndex: Int?) -> Track? {
        
        // Unwrap optional cursor value
        if let index = sequenceIndex {
            
            switch scope.type {
                
            // For a single group, the index is the track index within that group
            case .artist, .album, .genre:
                
                if let group = scope.group {
                    return group.trackAtIndex(index)
                }
                
            // For the allTracks scope, the index is the absolute index within the flat playlist
            case .allTracks:
                
                return playlist.trackAtIndex(index)
                
            // For the allArtists, allAlbums, and allGenres scopes, the index is an absolute index that needs to be mapped to a group index and track index within that group.
                
            case .allArtists, .allAlbums, .allGenres:
                
                if let groupType = scope.type.toGroupType() {
                    return getGroupedTrackForAbsoluteIndex(groupType, index)
                }
            }
        }
        
        return nil
    }
    
    /*
        Given an absolute index within a grouping/hierarchical playlist, maps the absolute index to a group index and track index within that group, and returns the corresponding track at that location.
     
        Example: The track with an absolute index of 5, is Track 0 under Group 2, below.
     
        Group 0
            -> Track 0 (absolute index 0)
            -> Track 1 (absolute index 1)
            -> Track 2 (absolute index 2)
     
        Group 1
            -> Track 0 (absolute index 3)
            -> Track 1 (absolute index 4)
     
        Group 2
            -> Track 0 (absolute index 5)
            -> Track 1 (absolute index 6)
    */
    private func getGroupedTrackForAbsoluteIndex(_ groupType: GroupType, _ absoluteIndex: Int) -> Track? {
        
        var groupIndex = 0
        var tracksSoFar = 0
        var trackIndexInGroup = 0
        
        // Iterate over groups while the tracks count (tracksSoFar) is less than the target absolute index
        while tracksSoFar < absoluteIndex {
            
            if let group = playlist.groupAtIndex(groupType, groupIndex) {
            
                // Add the size of the current group, to tracksSoFar
                tracksSoFar += group.size
                
                // Increment the groupIndex to iterate to the next group
                groupIndex.increment()
                
            } else {
                
                // Group at index groupIndex not found
                return nil
            }
        }
        
        // If you've overshot the target index, go back one group, and use the offset to calculate track index within that previous group
        if tracksSoFar > absoluteIndex {
            
            groupIndex.decrement()
            
            if let group = playlist.groupAtIndex(groupType, groupIndex) {
                
                trackIndexInGroup = group.size - (tracksSoFar - absoluteIndex)
                
            } else {
                
                // Group at index groupIndex not found
                return nil
            }
        }
        
        // Given the groupIndex and trackIndex, retrieve the desired track
        if let group = playlist.groupAtIndex(groupType, groupIndex) {
            return group.trackAtIndex(trackIndexInGroup)
        }
        
        return nil
    }
   
    /*
        Does the opposite/inverse of what getGroupedTrackForAbsoluteIndex() does.
        Maps a track within a grouping/hierarchical playlist to its absolute index within that playlist.
     */
    private func getAbsoluteIndexForGroupedTrack(_ groupType: GroupType, _ groupIndex: Int, _ trackIndex: Int) -> Int? {
        
        // If we're looking inside the first group, the absolute index is simply the track index
        if groupIndex == 0 {
            return trackIndex
        }
        
        // Iterate over all the groups, noting the size of each group, till the target group is reached
        var absIndexSoFar = 0
        for i in 0..<groupIndex {
            
            if let group = playlist.groupAtIndex(groupType, i) {
                absIndexSoFar += group.size
            } else {
                return nil  // group not found
            }
        }
        
        // The target group has been reached. Now, simply add the track index to absIndexSoFar, and that is the desired value
        return absIndexSoFar + trackIndex
    }
    
    // MARK: Repeat/Shuffle functions -------------------------------------------------------------------------------------
    
    func setRepeatMode(_ repeatMode: RepeatMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequence.setRepeatMode(repeatMode)
    }
    
    func setShuffleMode(_ shuffleMode: ShuffleMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequence.setShuffleMode(shuffleMode)
    }
    
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequence.toggleRepeatMode()
    }
    
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequence.toggleShuffleMode()
    }
    
    var repeatAndShuffleModes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return sequence.repeatAndShuffleModes
    }
    
    // MARK: PlaylistChangeListenerProtocol methods --------------------------------------------------------------
    
    func tracksAdded(_ addResults: [TrackAddResult]) {
        
        guard addResults.isNonEmpty else {return}
        
        if let group = scope.group {
            
            // We are only interested in the results matching the scope's group type.
            let filteredResults: [GroupedTrackAddResult?] = addResults.map {$0.groupingPlaylistResults[group.type]}

            // Look for any results matching both the type and name of the scope group.
            // If nothing is found, the scope is unaffected by this playlist add operation.
            if !filteredResults.contains(where: {group == $0?.track.group}) {
                return
            }
        }
        
        updateSequence(true)
    }
    
    func tracksReordered(_ moveResults: ItemMoveResults) {
        
        // Only update the sequence if the type of the playlist that was reordered matches the playback sequence scope.
        // In other words, if, for example, the Albums playlist was reordered, that does not affect the Artists playlist.
        guard scope.type.toPlaylistType() == moveResults.playlistType else {return}

        // If the scope is a group, it will only have been affected if any tracks within it were moved.
        // NOTE - A group being moved doesn't affect the playback scope if the scope is limited to that group.
        if let group = scope.group, !moveResults.results.contains(where: {group == ($0 as? TrackMoveResult)?.parentGroup}) {
            return
        }
        
        updateSequence(false)
    }
    
    func playlistSorted(_ sortResults: SortResults) {
        
        // Only update the sequence if the type of the playlist that was sorted matches the playback sequence scope.
        // In other words, if, for example, the Albums playlist was sorted, that does not affect the Artists playlist.
        guard scope.type.toPlaylistType() == sortResults.playlistType else {return}
        
        // If the scope is a group, it will only have been affected if any tracks within it were sorted.
        // NOTE - Groups being sorted doesn't affect the playback scope if the scope is limited to a single group (and no tracks within it were sorted).
        // Check the parent groups of the sorted tracks, and check if the scope group was one of them.
        if let group = scope.group {
            
            // No tracks were sorted (only groups were sorted) ... just return.
            if !sortResults.tracksSorted {
                return
            }
            
            // Tracks (within selected groups) were sorted ... if the scope group was not affected, return.
            if let trackSortGroupsScope = sortResults.affectedGroupsScope, trackSortGroupsScope == .selectedGroups,
                !sortResults.affectedParentGroups.contains(group) {
                
                return
            }
        }
        
        updateSequence(false)
    }
    
    func tracksRemoved(_ removeResults: TrackRemovalResults) {
        
        // Playing track was not removed. If the scope is a group, it might be unaffected.
        guard !removeResults.tracks.isEmpty else {return}
        
        if let thePlayingTrack = currentTrack, !playlist.hasTrack(thePlayingTrack) {
            
            messenger.publish(.sequencer_playingTrackRemoved, payload: thePlayingTrack)
            end()
        }
        
        if let group = scope.group {

            // We are only interested in the results matching the scope's group type.
            let filteredResults: [GroupedItemRemovalResult]? = removeResults.groupingPlaylistResults[group.type]
            
            // Loop through the results to see if a result for the scope group exists.
            if let theResults = filteredResults, !theResults.contains(where: {group == ($0 as? GroupedTracksRemovalResult)?.group}) {
                return
            }
        }
        
        updateSequence(true)
    }
    
    func playlistCleared() {
        
        if let thePlayingTrack = currentTrack {
            messenger.publish(.sequencer_playingTrackRemoved, payload: thePlayingTrack)
        }
        
        end()
        sequence.clear()
    }
    
    // Updates the playback sequence. This function is called in response to changes in the playlist,
    // to update the size of the sequence, and the sequence cursor, both of which may have changed.
    private func updateSequence(_ resize: Bool) {
        
        let playingTrackIndex = calculatePlayingTrackIndex()
        
        if resize {
            
            // Calculate the new sequence size (either the size of the group scope, if there is one, or of the entire playlist).
            let newSequenceSize: Int = scope.group?.size ?? playlist.size
            newSequenceSize == 0 ? sequence.clear() : sequence.resizeAndStart(size: newSequenceSize, withTrackIndex: playingTrackIndex)
            
        } else {
            sequence.start(withTrackIndex: playingTrackIndex)
        }
    }
    
    // Calculates the index of the playing track within the current playback sequence.
    // This function is called in response to changes in the playlist, to update the index which may have changed.
    private func calculatePlayingTrackIndex() -> Int? {
        
        // We only need to do this if there is a track currently playing
        if let playingTrack = currentTrack {
            
            switch scope.type {
                
            case .allArtists, .allAlbums, .allGenres:
                
                // Recalculate the absolute index of the playing track, given its parent group and track index within that group
        
                if let groupType = scope.type.toGroupType(), let groupInfo = playlist.groupingInfoForTrack(groupType, playingTrack) {
                    return getAbsoluteIndexForGroupedTrack(groupType, groupInfo.groupIndex, groupInfo.trackIndex)
                }
                
            case .artist, .album, .genre:
                
                // The index of the playing track within the group is simply its track index
                if let group = scope.group {
                    return group.indexOfTrack(playingTrack)
                }
                
            case .allTracks:
                
                // The index of the playing track within the flat playlist is simply its absolute index
                return playlist.indexOfTrack(playingTrack)
            }
        }
        
        return nil
    }
    
    // MARK: Message handling --------------------------------------------------------------------------------------------------------------
    
    // When the selected playlist view type changes in the UI (i.e. the selected playlist tab changes), this notification is sent out. Here, we make note of the new playlist type, so that the playback scope may be determined from it.
    func playlistTypeChanged(_ newPlaylistType: PlaylistType) {
        
        // Updates the instance variable playlistType, with the new playlistType value
        self.playlistType = newPlaylistType
    }
}
