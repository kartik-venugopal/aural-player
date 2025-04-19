import AVFoundation
import OrderedCollections

class PlayQueue: TrackList, PlayQueueProtocol {
    
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
    
    private var autoplayFirstAddedTrack: AtomicBool = AtomicBool(value: false)
    private var autoplayResumeSequence: AtomicBool = AtomicBool(value: false)
    private var markLoadedItemsForHistory: AtomicBool = AtomicBool(value: true)
    
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
        
        return IndexSet(sizeBeforeAdd..<sizeAfterAdd)
    }
    
    func setTrackLoadParams(params: PlayQueueTrackLoadParams) {
        
        autoplayFirstAddedTrack.setValue(params.autoplayFirstAddedTrack)
        autoplayResumeSequence.setValue(params.autoplayResumeSequence)
        markLoadedItemsForHistory.setValue(params.markLoadedItemsForHistory)
    }
    
    func loadTracks(from urls: [URL], atPosition position: Int?, params: PlayQueueTrackLoadParams) {
        
        setTrackLoadParams(params: params)
        loadTracks(from: urls, atPosition: position)
    }
    
    func enqueueTracks(_ newTracks: [Track], clearQueue: Bool) -> IndexSet {
        
        if clearQueue {
            removeAllTracks()
        }
        
        return addTracks(newTracks)
    }

    func enqueueTracksAfterCurrentTrack(_ newTracks: [Track]) -> IndexSet {
        
        guard let curTrackIndex = self.currentTrackIndex else {
            return addTracks(newTracks)
        }
        
        var insertionIndex = curTrackIndex + 1

        for track in newTracks {
            
            if let sourceIndex = indexOfTrack(track) {
                _tracks.removeAndInsertItem(sourceIndex, insertionIndex.getAndIncrement())
            } else {
                _ = insertTracks([track], at: insertionIndex.getAndIncrement())
            }
        }
        
        return IndexSet(curTrackIndex...(insertionIndex - 1))
    }
    
    func moveTracksAfterCurrentTrack(from indices: IndexSet) -> IndexSet {
        
        guard let currentTrackIndex = currentTrackIndex else {return .empty}
        
        let results = moveTracks(from: indices, to: currentTrackIndex + 1)
        return IndexSet(results.map {$0.destinationIndex})
    }
    
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
        
        return IndexSet(insertionIndex..<(insertionIndex + dedupedTracks.count))
    }
    
    override func removeTracks(at indexes: IndexSet) -> [Track] {

        let removedTracks = super.removeTracks(at: indexes)

        if let playingTrackIndex = currentTrackIndex {

            // Playing track removed
            if indexes.contains(playingTrackIndex) {
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
        
        super.removeAllTracks()
        stop()
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
    
    override func preTrackLoad() {
        Messenger.publish(.PlayQueue.startedAddingTracks)
    }
    
    override func firstBatchLoaded(atIndices indices: IndexSet) {
        
        // Use for autoplay
        guard autoplayFirstAddedTrack.value else {return}
        
        if shuffleMode == .off {
            
            if let firstIndex = indices.first {
                player.play(trackAtIndex: firstIndex)
            }
            
        } else if let randomFirstIndex = indices.randomElement() {
            player.play(trackAtIndex: randomFirstIndex)
        }
    }
    
    override func postBatchLoad(indices: IndexSet) {
        Messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
    }
    
    override func postTrackLoad() {
        
        if markLoadedItemsForHistory.value {
            Messenger.publish(HistoryItemsAddedNotification(itemURLs: session.urls))
        }
        
        if preferences.metadataPreferences.cacheTrackMetadata {
            metadataRegistry.persistCoverArt()
        }
        
        Messenger.publish(.PlayQueue.doneAddingTracks)
        
        defer {
            
            firstTrackLoad = false
            autoplayResumeSequence.setFalse()
        }
        
        if firstTrackLoad, shuffleMode == .on,
           let pQPersistentState = appPersistentState.playQueue,
           let persistentTracks = pQPersistentState.tracks,
           let historyPersistentState = pQPersistentState.history,
           let shuffleSequencePersistentState = historyPersistentState.shuffleSequence,
           let playedTrackIndices = shuffleSequencePersistentState.playedTracks,
           let sequenceTrackIndices = shuffleSequencePersistentState.sequence,
           (sequenceTrackIndices.count + playedTrackIndices.count) == persistentTracks.count,
           let playingSequenceTrackIndex = sequenceTrackIndices.first,
           let lastPlayedSequenceTrack = _tracks[persistentTracks[playingSequenceTrackIndex]],
           let lastPlayedTrackFile = historyPersistentState.mostRecentTrackItem?.trackFile,
           lastPlayedTrackFile == lastPlayedSequenceTrack.file {
            
            var sequenceTracks: OrderedSet<Track> = OrderedSet(sequenceTrackIndices.compactMap {_tracks[persistentTracks[$0]]})
            let playedTracks: OrderedSet<Track> = OrderedSet(playedTrackIndices.compactMap {_tracks[persistentTracks[$0]]})
            
            // Add to the sequence tracks that weren't there before (if loading from folder, maybe new tracks were added to the folder between app runs).
            
            let persistentTracksSet = Set<URL>(persistentTracks)
            
            for (file, track) in _tracks {
                
                if !persistentTracksSet.contains(file) {
                    sequenceTracks.append(track)
                }
            }
            
            shuffleSequence.initialize(with: sequenceTracks,
                                       playedTracks: playedTracks)
            
            if autoplayResumeSequence.value, let track = sequenceTracks.first,
               let playbackPosition = historyPersistentState.lastPlaybackPosition {
                
                player.resumeShuffleSequence(with: track, atPosition: playbackPosition)
            }
        }
        
        if autoplayResumeSequence.value, shuffleMode == .off,
           let historyPersistentState = appPersistentState.playQueue?.history,
           let lastPlayedTrackFile = historyPersistentState.mostRecentTrackItem?.trackFile,
           let track = _tracks[lastPlayedTrackFile],
           let playbackPosition = historyPersistentState.lastPlaybackPosition,
           playbackPosition > 0 {
            
            player.play(track: track, params: PlaybackParams().withStartAndEndPosition(playbackPosition))
        }
    }
}

fileprivate var firstTrackLoad: Bool = true

class GaplessPlaybackNotPossibleError: DisplayableError {}
