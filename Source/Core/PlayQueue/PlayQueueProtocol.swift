import Foundation

protocol PlayQueueProtocol: TrackListProtocol, SequencingProtocol {
    
    var currentTrack: Track? {get}
    
    var currentTrackIndex: Int? {get}
    
    var tracksPendingPlayback: [Track] {get}
    
    // MARK: Mutating functions ---------------------------------------------------------------
    
    // Adds tracks to the end of the queue, i.e. "Play Later"
    func enqueueTracks(_ newTracks: [Track], clearQueue: Bool) -> IndexSet

    // Inserts tracks immediately after the current track, i.e. "Play Next"
    func enqueueTracksAfterCurrentTrack(_ newTracks: [Track]) -> IndexSet
    
    // Moves tracks immediately after the current track, i.e. "Play Next"
    func moveTracksAfterCurrentTrack(from indices: IndexSet) -> IndexSet
    
    func loadTracks(from urls: [URL], atPosition position: Int?, params: PlayQueueTrackLoadParams)
    
    // Returns whether or not gapless playback is possible.
    func prepareForGaplessPlayback() throws
}

extension PlayQueueProtocol {
    
    func loadTracks(from urls: [URL]) {
        loadTracks(from: urls, atPosition: nil, params: .defaultParams)
    }
    
    func loadTracks(from urls: [URL], atPosition position: Int?) {
        loadTracks(from: urls, atPosition: position, params: .defaultParams)
    }
    
    func loadTracks(from urls: [URL], params: PlayQueueTrackLoadParams) {
        loadTracks(from: urls, atPosition: nil, params: params)
    }
}
