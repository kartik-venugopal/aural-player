import Foundation

///
/// Closes all open audio file handles for tracks that have previously been prepared
/// for playback. There should not be any audio file handles open when no track is
/// being played (i.e. when playback is stopped).
///
class CloseFileHandlesAction: PlaybackChainAction {
    
    private let playlist: PlaylistAccessorProtocol
    
    init(playlist: PlaylistAccessorProtocol) {
        self.playlist = playlist
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        // This operation is not time-critical, so do it async to unblock the main thread.
        DispatchQueue.global(qos: .utility).async {

            // Iterate through all tracks in the playlist,
            // and close their associated playback contexts
            // i.e. audio file handles.
            for track in self.playlist.tracks {
                track.playbackContext?.close()
            }
        }
                    
        chain.proceed(context)
    }
}

