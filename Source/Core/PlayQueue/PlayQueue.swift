//
// PlayQueue.swift
// Aural
//
// Copyright © 2025 Kartik Venugopal. All rights reserved.
//
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AVFoundation
import OrderedCollections

fileprivate typealias ObserverNotification = () -> Void

class PlayQueue: TrackList, PlayQueueProtocol, TrackRegistryClient {
    
    override var displayName: String {"The Play Queue"}
    
    override var trackLoadQoS: DispatchQoS.QoSClass {
        .userInteractive
    }
    
    // Stores the currently playing track, if there is one
    var currentTrack: Track? {
        
        guard let index = currentTrackIndex else {return nil}
        return self[index]
    }
    
    var currentTrackIndex: Int? = nil
    
    var tracksPendingPlayback: [Track] {
        
        guard let currentTrackIndex = self.currentTrackIndex else {return []}
        return Array(tracks[currentTrackIndex..<tracks.count])
    }
    
    var repeatMode: RepeatMode = .defaultMode
    var shuffleMode: ShuffleMode = .defaultMode
    
    // Contains a pre-computed shuffle sequence, when shuffleMode is .on
    lazy var shuffleSequence: ShuffleSequence = ShuffleSequence()

    // MARK: Accessor functions
    
    override func search(_ searchQuery: SearchQuery) -> SearchResults {
        SearchResults(scope: .playQueue, tracks.enumerated().compactMap {executeQuery(index: $0, track: $1, searchQuery)})
    }
    
    // MARK: Mutator functions ------------------------------------------------------------------------
    
    var params: PlayQueueTrackLoadParams!
    
    lazy var messenger: Messenger = .init(for: self)
    
    var uiObserver: (any PlayQueueUIObserver)? = nil
    var observers: [String: any PlayQueueObserver] = [:]
    
    private var sortedObservers: [PlayQueueObserver] {
        observers.values.sorted(by: {$0.observerPriority < $1.observerPriority})
    }
    
    init(persistentState: PlayQueuePersistentState?) {
        
        super.init()
        
        setRepeatMode(persistentState?.repeatMode ?? .defaultMode)
        setShuffleMode(persistentState?.shuffleMode ?? .defaultMode)
    }
    
    func registerUIObserver(_ observer: any PlayQueueUIObserver) {
        uiObserver = observer
    }
    
    func removeUIObserver() {
        uiObserver = nil
    }
    
    func registerObserver(_ observer: any PlayQueueObserver) {
        observers[observer.id] = observer
    }
    
    func removeObserver(_ observer: any PlayQueueObserver) {
        observers.removeValue(forKey: observer.id)
    }
    
    @discardableResult override func addTracks(_ newTracks: any Sequence<Track>) -> IndexSet {
        
        let sizeBeforeAdd = self.size
        let dedupedTracks = deDupeTracks(newTracks)
        let numTracksToAdd = dedupedTracks.count
        guard numTracksToAdd > 0 else {return .empty}
        
        let sizeAfterAdd = sizeBeforeAdd + numTracksToAdd
        self.doAddTracks(dedupedTracks)
        
        if shuffleMode == .on, currentTrackIndex != nil {
            shuffleSequence.addTracks(dedupedTracks)
        }
        
        let indices = IndexSet(sizeBeforeAdd..<sizeAfterAdd)
        let copiedParams = self.params!
        
        let notification: ObserverNotification = {
            
            for observer in self.sortedObservers {
                observer.addedTracks(dedupedTracks, at: indices, params: copiedParams)
            }
        }
        
        // Some Presentation Modes don't have a Play Queue UI (eg. Widget / Menu Bar)
        if let uiObserver {
            uiObserver.addedTracks(dedupedTracks, at: indices, params: copiedParams, completionHandler: notification)
        } else {
            notification()
        }
        
        return indices
    }
    
    func loadTracks(from urls: [URL], atPosition position: Int?, params: PlayQueueTrackLoadParams) {
        
        if params.clearQueue {
            removeAllTracks()
        }
        
        self.params = params
        loadTracks(from: urls, atPosition: position)
    }
    
    func enqueueTracks(_ newTracks: [Track], clearQueue: Bool) -> IndexSet {
        
        if clearQueue {
            removeAllTracks()
        }
        
        return addTracks(newTracks)
    }

//    func enqueueTracksAfterCurrentTrack(_ newTracks: [Track]) -> IndexSet {
//        
//        guard let curTrackIndex = self.currentTrackIndex else {
//            return addTracks(newTracks)
//        }
//        
//        var insertionIndex = curTrackIndex + 1
//
//        for track in newTracks {
//            
//            if let sourceIndex = indexOfTrack(track) {
//                _tracks.removeAndInsertItem(sourceIndex, insertionIndex.getAndIncrement())
//            } else {
//                _ = insertTracks([track], at: insertionIndex.getAndIncrement())
//            }
//        }
//        
//        return IndexSet(curTrackIndex...(insertionIndex - 1))
//    }
    
    override func insertTracks(_ newTracks: [Track], at insertionIndex: Int) -> IndexSet {
        
        let dedupedTracks = deDupeTracks(newTracks)
        guard dedupedTracks.isNonEmpty else {return .empty}
        
        tracksLock.write {
            
            // Need to insert in reverse order.
            for index in stride(from: dedupedTracks.lastIndex, through: 0, by: -1) {
                
                let track = dedupedTracks[index]
                self._tracks.insertItem(track, forKey: track.file, at: insertionIndex)
            }
        }
        
        // Check if the new tracks were inserted above (<) or below (>) the playing track index.
        if let playingTrackIndex = currentTrackIndex, insertionIndex <= playingTrackIndex {
            
            let newPlayingTrackIndex = playingTrackIndex + dedupedTracks.count
            currentTrackIndex = newPlayingTrackIndex
            
            if shuffleMode == .on {
                shuffleSequence.addTracks(dedupedTracks)
            }
        }
        
        let indices = IndexSet(insertionIndex..<(insertionIndex + dedupedTracks.count))
        let copiedParams = self.params!
        
        let notification: ObserverNotification = {
            
            for observer in self.sortedObservers {
                observer.addedTracks(dedupedTracks, at: indices, params: copiedParams)
            }
        }
        
        // Some Presentation Modes don't have a Play Queue UI (eg. Widget / Menu Bar)
        if let uiObserver {
            uiObserver.addedTracks(dedupedTracks, at: indices, params: copiedParams, completionHandler: notification)
        } else {
            notification()
        }
        
        return indices
    }
    
    override func removeTracks(at indexes: IndexSet) -> [Track] {

        let removedTracks = super.removeTracks(at: indexes)

        if let playingTrackIndex = currentTrackIndex {

            // Playing track removed
            if indexes.contains(playingTrackIndex) {
                
                messenger.publish(.Player.stop)
                stop()

            } else {

                // Compute how many tracks above (i.e. <) playingTrackIndex were removed ... this will determine the adjustment to the playing track index.
                let newPlayingTrackIndex = playingTrackIndex - (indexes.filter {$0 < playingTrackIndex}.count)
                currentTrackIndex = newPlayingTrackIndex
                
                if shuffleMode == .on {
                    shuffleSequence.removeTracks(removedTracks)
                }
            }
            
        } else if shuffleMode == .on {
            shuffleSequence.clear()
        }

        return removedTracks
    }

    override func removeAllTracks() {
        
        let playingTrack: Track? = currentTrack
        
        super.removeAllTracks()
        stop()
        
        if let playingTrack {
            messenger.publish(.PlayQueue.playingTrackRemoved, payload: playingTrack)
        }
    }

    override func moveTracksUp(from indices: IndexSet) -> [TrackMoveResult] {
        doMoveTracks {super.moveTracksUp(from: indices)}
    }

    override func moveTracksDown(from indices: IndexSet) -> [TrackMoveResult] {
        doMoveTracks {super.moveTracksDown(from: indices)}
    }

    override func moveTracksToTop(from indices: IndexSet) -> [TrackMoveResult] {
        doMoveTracks {super.moveTracksToTop(from: indices)}
    }

    override func moveTracksToBottom(from indices: IndexSet) -> [TrackMoveResult] {
        doMoveTracks {super.moveTracksToBottom(from: indices)}
    }

    override func moveTracks(from sourceIndexes: IndexSet, to dropIndex: Int) -> [TrackMoveResult] {
        doMoveTracks {super.moveTracks(from: sourceIndexes, to: dropIndex)}
    }

    private func doMoveTracks(_ moveOperation: () -> [TrackMoveResult]) -> [TrackMoveResult] {
        
        let playingTrack = self.currentTrack

        let moveResults = moveOperation()
        
        if moveResults.isEmpty {return moveResults}

        // Update the index of the playing track within the sequence
        
        if let playingTrack {
            self.currentTrackIndex = indexOfTrack(playingTrack)
        }

        return moveResults
    }
    
    override func sort(_ sort: TrackListSort) {
        
        let playingTrack = currentTrack
        super.sort(sort)
        
        if let playingTrack {
            self.currentTrackIndex = indexOfTrack(playingTrack)
        }
    }
    
    // MARK: Play Now, Play Next, Play Later ------------------------------------------------------------------------
    
//    @discardableResult func enqueueToPlayNext(tracks: [Track]) -> IndexSet {
//        
//        defer {history.tracksAdded(tracks)}
//        return doEnqueueToPlayNext(tracks: tracks)
//    }
//    
//    @discardableResult private func doEnqueueToPlayNext(tracks: [Track]) -> IndexSet {
//        
//        let indices = enqueueTracksAfterCurrentTrack(tracks)
//        messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
//        return indices
//    }
//    
    func moveTracksToPlayNext(from indices: IndexSet) -> IndexSet {
        
        guard let currentTrackIndex = currentTrackIndex else {return .empty}
        
        let results = moveTracks(from: indices, to: currentTrackIndex + 1)
        return IndexSet(results.map {$0.destinationIndex})
    }
//    
//    @discardableResult func enqueueToPlayLater(tracks: [Track]) -> IndexSet {
//        
//        defer {history.tracksAdded(tracks)}
//        return doEnqueueToPlayLater(tracks: tracks)
//    }
//    
//    @discardableResult private func doEnqueueToPlayLater(tracks: [Track]) -> IndexSet {
//        
//        let indices = playQueue.addTracks(tracks)
//        messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
//        return indices
//    }
    
    // ------------------------------------------------------------------------
    
    override func preTrackLoad() {
        
        let copiedParams = self.params!
        
        let notification: ObserverNotification = {
            
            for observer in self.sortedObservers {
                observer.startedAddingTracks(params: copiedParams)
            }
        }
        
        // Some Presentation Modes don't have a Play Queue UI (eg. Widget / Menu Bar)
        if let uiObserver {
            uiObserver.startedAddingTracks(params: copiedParams, completionHandler: notification)
        } else {
            notification()
        }
    }
    
    override func postTrackLoad() {
        
        let copiedParams = self.params!
        let sessionURLs = self.session.urls
        
        let notification: ObserverNotification = {
            
            for observer in self.sortedObservers {
                observer.doneAddingTracks(urls: sessionURLs, params: copiedParams)
            }
        }
        
        // Some Presentation Modes don't have a Play Queue UI (eg. Widget / Menu Bar)
        if let uiObserver {
            uiObserver.doneAddingTracks(urls: sessionURLs, params: copiedParams, completionHandler: notification)
        } else {
            notification()
        }
        
        self.params = nil
    }
    
    // MARK: Notification handling ---------------------------------------------------------------
    
    var persistentState: PlayQueuePersistentState {
        
        .init(tracks: tracks,
              repeatMode: repeatMode,
              shuffleMode: shuffleMode)
    }
    
    var shuffleSequencePersistentState: ShuffleSequencePersistentState {
        
        .init(sequence: shuffleSequence.sequence.compactMap {indexOfTrack($0)},
              playedTracks: shuffleSequence.playedTracks.compactMap {indexOfTrack($0)})
    }
    
    func updateWithTracksIfPresent(_ tracks: any Sequence<Track>) {
        
        // Play Queue
        updateTracksIfPresent(tracks)
    }
    
    func prepareForGaplessPlayback() throws {
        
        var audioFormatsSet: Set<PlaybackFormat> = Set()
        var errorMsg: String? = nil
        
        for track in self.tracks {
            
            if let audioFormat = track.playbackFormat {
                audioFormatsSet.insert(audioFormat)
                
            } else {
                errorMsg = "Unable to prepare for gapless playback: No audio format for track: \(track)."
            }
            
            if audioFormatsSet.count > 1 {
                throw GaplessPlaybackNotPossibleError("The tracks in the Play Queue do not all have the same audio format.")
                
            } else if let errorMsg {
                throw GaplessPlaybackNotPossibleError(errorMsg)
            }
        }
        
        if repeatMode == .one {
            repeatMode = .off
        }
        
        if shuffleMode == .on {
            shuffleMode = .off
        }
    }
}

class GaplessPlaybackNotPossibleError: DisplayableError {}
