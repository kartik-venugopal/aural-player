import Cocoa
import MediaPlayer

///
/// Provides the macOS Now Playing Info Center with updated information about the current state of the player,
/// i.e. playback state, playback rate, track info, etc.
///
@available(OSX 10.12.2, *)
class NowPlayingInfoManager: NSObject, NotificationSubscriber {

    /// The underlying Now Playing Info Center.
    fileprivate let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    
    /// Provides current player information (eg. which track is playing, playback state, playback position, etc).
    private let playbackInfo: PlaybackInfoDelegateProtocol
    
    /// Provides audio engine information (eg. playback rate).
    private let audioGraph: AudioGraphDelegateProtocol
    
    /// Provides current playback sequence information (eg. repeat / shuffle modes, how many tracks are in the playback queue, etc).
    private let sequencer: SequencerInfoDelegateProtocol
    
    private static let optimalArtworkSize: NSSize = NSMakeSize(50, 50)
    
    private var preTrackChange: Bool = false
    
    init(playbackInfo: PlaybackInfoDelegateProtocol, audioGraph: AudioGraphDelegateProtocol, sequencer: SequencerInfoDelegateProtocol) {
        
        self.playbackInfo = playbackInfo
        self.audioGraph = audioGraph
        self.sequencer = sequencer
        
        super.init()
    
        // Initialize the Now Playing Info Center with current info.
        self.updateNowPlayingInfo()
        self.playbackStateChanged()
        
        //
        // Subscribe to notifications about changes in the player's state, so that the Now Playing Info Center can be
        // updated in response to any of those changes.
        //
        // TODO: Also listen for changes in playback rate, seek events, repeat / shuffle mode, sequence scope, etc.
        //
        Messenger.subscribe(self, .player_preTrackChange, self.handlePreTrackChange)
        Messenger.subscribe(self, .player_trackTransitioned, self.trackChanged(_:), filter: {msg in msg.trackChanged})
        Messenger.subscribe(self, .player_trackNotPlayed, self.trackNotPlayed)
        Messenger.subscribe(self, .player_playbackStateChanged, self.playbackStateChanged)
        Messenger.subscribe(self, .player_seekPerformed, self.seekPerformed)
        Messenger.subscribe(self, .fx_playbackRateChanged, self.playbackRateChanged(_:))
    }
    
    private func handlePreTrackChange() {
        preTrackChange = true
    }
    
    ///
    /// Responds to a change in the currently playing track. Updates the Now Playing Info Center with information
    /// about the new playing track.
    ///
    private func trackChanged(_ notification: TrackTransitionNotification) {
        
        updateNowPlayingInfo()
        preTrackChange = false
    }
    
    private func trackNotPlayed() {
        
        updateNowPlayingInfo()
        preTrackChange = false
    }
    
    ///
    /// Responds to a change in the player's playback state. Updates the Now Playing Info Center with the new state.
    ///
    private func playbackStateChanged() {
        
        if preTrackChange {return}
        
        nowPlayingInfoCenter.playbackState = MPNowPlayingPlaybackState.fromPlaybackState(playbackInfo.state)
        
        if var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo {
            
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playbackInfo.seekPosition.timeElapsed
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = playbackInfo.state == .playing ? Double(audioGraph.timeUnit.rate) : 0.0
            
            nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        }
    }
    
    private func playbackRateChanged(_ newRate: Float) {
        
        if var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo {
            
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = playbackInfo.state == .playing ? Double(newRate) : 0.0
            nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate]
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playbackInfo.seekPosition.timeElapsed
            
            nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        }
    }
    
    ///
    /// Responds to the player performing a seek. Updates the Now Playing Info Center with the new seek position.
    ///
    private func seekPerformed() {
        nowPlayingInfoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playbackInfo.seekPosition.timeElapsed
    }
    
    ///
    /// Updates the Now Playing Info Center with information about the currently playing track.
    ///
    private func updateNowPlayingInfo() {
        
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
        
        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.audio.rawValue
        
        let playingTrack = playbackInfo.playingTrack
        
        // Metadata
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = playingTrack?.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = playingTrack?.artist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = playingTrack?.album
        nowPlayingInfo[MPMediaItemPropertyGenre] = playingTrack?.genre
        
        nowPlayingInfo[MPMediaItemPropertyAlbumTrackNumber] = playingTrack?.trackNumber
        nowPlayingInfo[MPMediaItemPropertyAlbumTrackCount] = playingTrack?.totalTracks
        nowPlayingInfo[MPMediaItemPropertyDiscNumber] = playingTrack?.discNumber
        nowPlayingInfo[MPMediaItemPropertyDiscCount] = playingTrack?.totalDiscs
        
        if #available(OSX 10.13.2, *) {
            
            if let artwork = playingTrack?.art?.image {
                
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: Self.optimalArtworkSize, requestHandler: {size in
                    
                    let imageCopy: NSImage = artwork.copy() as! NSImage
                    imageCopy.size = Self.optimalArtworkSize
                    return imageCopy
                })
                
            } else {
                nowPlayingInfo[MPMediaItemPropertyArtwork] = nil
            }
        }
        
        // Seek position and duration
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playbackInfo.seekPosition.timeElapsed
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playingTrack?.duration
        
        // Playback rate
        
        let playbackRate = Double(audioGraph.timeUnit.rate)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = playbackRate
        
        // Playback sequence scope
        
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackQueueIndex] = UInt(sequencer.sequenceInfo.trackIndex)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackQueueCount] = UInt(sequencer.sequenceInfo.totalTracks)
        
        // Update the nowPlayingInfo dictionary in the Now Playing Info Center.
        nowPlayingInfoCenter.playbackState = MPNowPlayingPlaybackState.fromPlaybackState(playbackInfo.state)
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
}

@available(OSX 10.12.2, *)
extension MPNowPlayingPlaybackState {

    ///
    /// A convenience function to convert a **PlaybackState** enum to a **MPNowPlayingPlaybackState** that is
    /// required by the Now Playing Info Center.
    ///
    static func fromPlaybackState(_ state: PlaybackState) -> MPNowPlayingPlaybackState {
        
        switch state {
        
        case .noTrack:  return .stopped
            
        case .playing:  return .playing
            
        case .paused:   return .paused
            
        }
    }
}
