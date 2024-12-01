import AVFoundation

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
    var eligibleToResumeShuffleSequence: Bool = false
    
    private lazy var messenger = Messenger(for: self)
    
    // MARK: Accessor functions
    
    override func search(_ searchQuery: SearchQuery) -> SearchResults {
        SearchResults(scope: .playQueue, tracks.enumerated().compactMap {executeQuery(index: $0, track: $1, searchQuery)})
    }
    
    // MARK: Mutator functions ------------------------------------------------------------------------
    
    private var autoplay: AtomicBool = AtomicBool(value: false)
    private var markLoadedItemsForHistory: AtomicBool = AtomicBool(value: true)
    
    @discardableResult override func addTracks(_ newTracks: [Track]) -> IndexSet {
        
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
    
    func loadTracks(from urls: [URL], atPosition position: Int?, params: PlayQueueTrackLoadParams) {
        
        autoplay.setValue(params.autoplay)
        markLoadedItemsForHistory.setValue(params.markLoadedItemsForHistory)
        
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

        let moveResults = moveOperation()
        
        if moveResults.isEmpty {return moveResults}

        // If the playing track was moved, update the index of the playing track within the sequence
        
        if let theCurrentTrackIndex = self.currentTrackIndex {
            
            if let result = moveResults.first(where: {$0.sourceIndex == theCurrentTrackIndex}) {
                self.currentTrackIndex = result.destinationIndex
            }
        }

        return moveResults
    }
    
    override func sort(_ sort: TrackListSort) {
        
        let playingTrack = currentTrack
        super.sort(sort)
        
        if let playingTrack = playingTrack,
           let newPlayingTrackIndex = indexOfTrack(playingTrack) {
            
            currentTrackIndex = newPlayingTrackIndex
        }
    }
    
    func prepareForGaplessPlayback() throws {
     
        var audioFormatsSet: Set<AVAudioFormat> = Set()
        var errorMsg: String? = nil
        
        for track in self.tracks {
            
            do {
                
                try trackReader.prepareForPlayback(track: track, immediate: false)
                
                if let audioFormat = track.playbackContext?.audioFormat {
                    
                    audioFormatsSet.insert(audioFormat)
                    
                    if audioFormatsSet.count > 1 {
                        
                        errorMsg = "The tracks in the Play Queue do not all have the same audio format."
                        break
                    }
                    
                } else {
                    
                    errorMsg = "Unable to prepare for gapless playback: No audio context for track: \(track)."
                    break
                }
                
            } catch {
                
                errorMsg = "Unable to prepare track \(track) for gapless playback: \(error)"
                break
            }
        }
        
        if let theErrorMsg = errorMsg {
            throw GaplessPlaybackNotPossibleError(theErrorMsg)
        }
        
        let success = audioFormatsSet.count == 1
        
        guard success else {
            throw GaplessPlaybackNotPossibleError("The tracks in the Play Queue do not all have the same audio format.")
        }
        
        if repeatMode == .one {
            repeatMode = .off
        }
        
        if shuffleMode == .on {
            shuffleMode = .off
        }
    }
    
    override func preTrackLoad() {
        messenger.publish(.PlayQueue.startedAddingTracks)
    }
    
    override func firstBatchLoaded(atIndices indices: IndexSet) {
        
        // Use for autoplay
        guard autoplay.value else {return}
        
        if shuffleMode == .off {
            
            if let firstIndex = indices.first {
                playbackDelegate.play(trackAtIndex: firstIndex, .defaultParams())
            }
            
        } else if let randomFirstIndex = indices.randomElement() {
            playbackDelegate.play(trackAtIndex: randomFirstIndex, .defaultParams())
        }
    }
    
    override func postBatchLoad(indices: IndexSet) {
        messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
    }
    
    override func postTrackLoad() {
        
        if markLoadedItemsForHistory.value {
            messenger.publish(HistoryItemsAddedNotification(itemURLs: session.urls))
        }
        
        if preferences.metadataPreferences.cacheTrackMetadata.value {
            metadataRegistry.persistCoverArt()
        }
        
        messenger.publish(.PlayQueue.doneAddingTracks)
        
        if eligibleToResumeShuffleSequence, shuffleMode == .on,
            let shuffleSequencePersistentState = appPersistentState.playQueue?.history?.shuffleSequence,
            let playedTracks = shuffleSequencePersistentState.playedTracks,
           let sequenceTracks = shuffleSequencePersistentState.sequence {
            
            defer {eligibleToResumeShuffleSequence = false}
           
            guard (playedTracks.count + sequenceTracks.count) == self.size else {return}
            
            for file in playedTracks {
                
                if !self.hasTrack(forFile: file) {
                    return
                }
            }
            
            for file in sequenceTracks {
                
                if !self.hasTrack(forFile: file) {
                    return
                }
            }
            
            print("\nCan resume Shuffle Sequence !!! ... with \(playedTracks.count) played tracks + \(sequenceTracks.count) pending tracks")
            var tracksMap: [URL: Track] = [:]
            
            for track in self._tracks {
                tracksMap[track.key] = track.value
            }
            
            shuffleSequence.initialize(with: shuffleSequencePersistentState, playQueueTracks: tracksMap)
        }
    }
}
