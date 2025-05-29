//
// History+PlayQueueObserver.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension History: PlayQueueObserver {
    
    var id: String {
        "History"
    }
    
    func startedAddingTracks(params: PlayQueueTrackLoadParams) {}
    
    func addedTracks(at trackIndices: IndexSet, params: PlayQueueTrackLoadParams) {}
    
    func doneAddingTracks(urls: [URL], params: PlayQueueTrackLoadParams) {
        
        if firstTrackLoad {
            
            firstTrackLoad = false
            resumeSequenceOnStartup()
        }
        
        guard params.markLoadedItemsForHistory else {return}
        
        for url in urls {
            
            if url.isSupportedAudioFile {
                
                if let track = playQueue.findTrack(forFile: url) {
                    markAddEventForTrack(track)
                }
                
            } else if url.isDirectory {
                markAddEventForFolder(url)
                
            } else if url.isSupportedPlaylistFile {
                markAddEventForPlaylistFile(url)
            }
        }
    }
    
    private func resumeSequenceOnStartup() {
        
        let autoplayPrefs = preferences.playbackPreferences.autoplay
        
        guard autoplayPrefs.autoplayOnStartup && autoplayPrefs.autoplayOnStartupOption == .resumeSequence else {return}
        
        if playQueue.shuffleMode == .off {
            resumeLastPlayedTrack()
        } else {
            resumeShuffleSequence()
        }
    }
    
    private func doResumeShuffleSequence() {
        
        //        if firstTrackLoad, shuffleMode == .on,
        //           let pQPersistentState = appPersistentState.playQueue,
        //           let persistentTracks = pQPersistentState.tracks,
        //           let historyPersistentState = pQPersistentState.history,
        //           let shuffleSequencePersistentState = historyPersistentState.shuffleSequence,
        //           let playedTrackIndices = shuffleSequencePersistentState.playedTracks,
        //           let sequenceTrackIndices = shuffleSequencePersistentState.sequence,
        //           (sequenceTrackIndices.count + playedTrackIndices.count) == persistentTracks.count,
        //           let playingSequenceTrackIndex = sequenceTrackIndices.first,
        //           let lastPlayedSequenceTrack = _tracks[persistentTracks[playingSequenceTrackIndex]],
        //           let lastPlayedTrackFile = historyPersistentState.mostRecentTrackItem?.trackFile,
        //           lastPlayedTrackFile == lastPlayedSequenceTrack.file {
        //
        //            var sequenceTracks: OrderedSet<Track> = OrderedSet(sequenceTrackIndices.compactMap {_tracks[persistentTracks[$0]]})
        //            let playedTracks: OrderedSet<Track> = OrderedSet(playedTrackIndices.compactMap {_tracks[persistentTracks[$0]]})
        //
        //            // Add to the sequence tracks that weren't there before (if loading from folder, maybe new tracks were added to the folder between app runs).
        //
        //            let persistentTracksSet = Set<URL>(persistentTracks)
        //
        //            for (file, track) in _tracks {
        //
        //                if !persistentTracksSet.contains(file) {
        //                    sequenceTracks.append(track)
        //                }
        //            }
        //
        //            shuffleSequence.initialize(with: sequenceTracks,
        //                                       playedTracks: playedTracks)
        //
        //            if autoplayResumeSequence.value, let track = sequenceTracks.first,
        //               let playbackPosition = historyPersistentState.lastPlaybackPosition {
        //
        //                player.resumeShuffleSequence(with: track, atPosition: playbackPosition)
        //            }
        //        }
    }
}
