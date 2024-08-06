import AVFoundation

class PlayQueue: TrackList, PlayQueueProtocol {
    
    override var displayName: String {"The Play Queue"}
    
    // MARK: Accessor functions

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
    
    private lazy var messenger = Messenger(for: self)
    
    override func search(_ searchQuery: SearchQuery) -> SearchResults {
        SearchResults(scope: .playQueue, tracks.enumerated().compactMap {executeQuery(index: $0, track: $1, searchQuery)})
    }
    
    // MARK: Mutator functions ------------------------------------------------------------------------
    
    private var autoplay: AtomicBool = AtomicBool(value: false)
    private var markLoadedItemsForHistory: AtomicBool = AtomicBool(value: true)
    
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
        
        let indices = super.insertTracks(newTracks, at: insertionIndex)
        
        // Check if the new tracks were inserted above (<) or below (>) the playing track index.
        if let playingTrackIndex = currentTrackIndex, insertionIndex <= playingTrackIndex {
            currentTrackIndex = playingTrackIndex + newTracks.count
        }
        
        return indices
    }
    
    override func removeTracks(at indexes: IndexSet) -> [Track] {

        let removedTracks = super.removeTracks(at: indexes)

        if let playingTrackIndex = currentTrackIndex {

            // Playing track removed
            if indexes.contains(playingTrackIndex) {
                stop()

            } else {

                // Compute how many tracks above (i.e. <) playingTrackIndex were removed ... this will determine the adjustment to the playing track index.
                currentTrackIndex = playingTrackIndex - (indexes.filter {$0 < playingTrackIndex}.count)
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

        let playingTrack = currentTrack
        let moveResults = moveOperation()

        // If the playing track was moved, update the index of the playing track within the sequence
        
        // TODO: Looking up index of the playing track is not very efficient ... this should be calculated
        // from the move results ... and move results need to be improved to include the rows which were
        // indirectly affected by the move (cascaded up / down).
        
        if let playingTrack = playingTrack,
           let newPlayingTrackIndex = indexOfTrack(playingTrack) {
            
            currentTrackIndex = newPlayingTrackIndex
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
        
        for track in _tracks.values {
            
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
        
        print("\nGapless audio format: \(audioFormatsSet.first!)")
    }
    
    override func preTrackLoad() {
        messenger.publish(.PlayQueue.startedAddingTracks)
    }
    
    override func firstTrackLoaded(atIndex index: Int) {
        
        // Use for autoplay
        if autoplay.value {
            playbackDelegate.play(trackAtIndex: index, .defaultParams())
        }
    }
    
    override func postBatchLoad(indices: IndexSet) {
        messenger.publish(PlayQueueTracksAddedNotification(trackIndices: indices))
    }
    
    override func postTrackLoad() {
        
        if markLoadedItemsForHistory.value {
            messenger.publish(HistoryItemsAddedNotification(itemURLs: session.urls))
        }
        
        messenger.publish(.PlayQueue.doneAddingTracks)
    }
}
