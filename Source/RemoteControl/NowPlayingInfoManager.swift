import Cocoa
import MediaPlayer

///
/// Provides the macOS Now Playing Info Center with updated information about the current state of the player,
/// i.e. playback state, playback rate, track info, etc.
///
@available(OSX 10.12.2, *)
class NowPlayingInfoManager: NSObject, NotificationSubscriber {

    /// The underlying Now Playing Info Center.
    fileprivate let infoCenter = MPNowPlayingInfoCenter.default()
    
    /// Provides current player information (eg. which track is playing, playback state, playback position, etc).
    private let playbackInfo: PlaybackInfoDelegateProtocol
    
    /// Provides audio engine information (eg. playback rate).
    private let audioGraph: AudioGraphDelegateProtocol
    
    /// Provides current playback sequence information (eg. repeat / shuffle modes, how many tracks are in the playback queue, etc).
    private let sequencer: SequencerInfoDelegateProtocol
    
    /// 50x50 is the size of the image view in macOS Control Center.
    private static let optimalArtworkSize: NSSize = NSMakeSize(50, 50)
    
    /// An image to display when the currently playing track does not have any associated cover art, resized to an optimal size for display in Control Center.
    private static let defaultArtwork: NSImage = Images.imgPlayingArt.copy(ofSize: optimalArtworkSize)
    
    /// A flag used to prevent unnecessary redundant updates.
    private var preTrackChange: Bool = false
    
    private var activated: Bool = false
    
    init(playbackInfo: PlaybackInfoDelegateProtocol, audioGraph: AudioGraphDelegateProtocol, sequencer: SequencerInfoDelegateProtocol) {
        
        self.playbackInfo = playbackInfo
        self.audioGraph = audioGraph
        self.sequencer = sequencer
        
        super.init()
    }
    
    func activate() {
        
        if activated {return}
        
        // Initialize the Now Playing Info Center with current info.
        
        infoCenter.nowPlayingInfo = [String: Any]()
        infoCenter.nowPlayingInfo![MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.audio.rawValue
        self.updateNowPlayingInfo()
        
        //
        // Subscribe to notifications about changes in the player's state, so that the Now Playing Info Center can be
        // updated in response to any of those changes.
        //
        Messenger.subscribeAsync(self, .player_preTrackChange, self.handlePreTrackChange, queue: .main)
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackChanged, queue: .main)
        Messenger.subscribeAsync(self, .player_trackNotPlayed, self.trackChanged, queue: .main)
        Messenger.subscribeAsync(self, .player_playbackStateChanged, self.playbackStateChanged, queue: .main)
        Messenger.subscribeAsync(self, .player_seekPerformed, self.seekPerformed, queue: .main)
        Messenger.subscribeAsync(self, .player_loopRestarted, self.loopRestarted, queue: .main)
        Messenger.subscribeAsync(self, .fx_playbackRateChanged, self.playbackRateChanged(_:), queue: .main)
        
        activated = true
    }
    
    func deactivate() {
        
        if !activated {return}
        
        infoCenter.playbackState = .stopped
        infoCenter.nowPlayingInfo?.removeAll()
        
        Messenger.unsubscribeAll(for: self)
        
        activated = false
    }
    
    ///
    /// Responds to a notification that the currently playing track is about to change.
    ///
    private func handlePreTrackChange() {
        preTrackChange = true
    }
    
    ///
    /// Responds to a change in the currently playing track. Updates the Now Playing Info Center with information
    /// about the new playing track.
    ///
    private func trackChanged() {
        
        updateNowPlayingInfo()
        preTrackChange = false
    }
    
    ///
    /// Responds to a change in the player's playback state. Updates the Now Playing Info Center with the new state.
    ///
    private func playbackStateChanged() {
        
        // If the currently playing track is about to change, don't respond to this notification
        // because another notification will be sent shortly.
        if preTrackChange {return}
        
        infoCenter.playbackState = MPNowPlayingPlaybackState.fromPlaybackState(playbackInfo.state)
        playbackRateChanged(audioGraph.timeUnit.effectiveRate)
    }
    
    private func playbackRateChanged(_ newRate: Float) {
        
        var nowPlayingInfo = infoCenter.nowPlayingInfo!
        
        // Set playback rate
        let playbackRate: Double = playbackInfo.state == .playing ? Double(newRate) : .zero
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = playbackRate
        
        // Set elapsed time
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playbackInfo.seekPosition.timeElapsed
        
        infoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    ///
    /// Responds to the player performing a seek. Updates the Now Playing Info Center with the new seek position.
    ///
    private func seekPerformed() {
        infoCenter.nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = playbackInfo.seekPosition.timeElapsed
    }
    
    ///
    /// Responds to the player restarting a segment loop. Updates the Now Playing Info Center with the new seek position (roughly corresponding to the loop's start time).
    ///
    private func loopRestarted() {
        
        infoCenter.nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = playbackInfo.seekPosition.timeElapsed

        // This is a dirty hack to get the seek position to be updated properly when a segment loop is restarted.
        // Without this hack, the Control Center's playback position continues on past the segment loop's end time.
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.infoCenter.nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.playbackInfo.seekPosition.timeElapsed
        })
    }
    
    ///
    /// Updates the Now Playing Info Center with information about the currently playing track.
    ///
    private func updateNowPlayingInfo() {
        
        var nowPlayingInfo = infoCenter.nowPlayingInfo!
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
        
        // Cover art
        
        if #available(OSX 10.13.2, *) {
            
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: Self.optimalArtworkSize, requestHandler: {size in playingTrack?.art?.image.copy(ofSize: size) ?? Self.defaultArtwork})
        }
        
        // Seek position and duration
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playbackInfo.seekPosition.timeElapsed
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playingTrack?.duration
        
        // Playback rate
        
        let playbackRate: Double = playbackInfo.state == .playing ? Double(audioGraph.timeUnit.effectiveRate) : .zero
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = playbackRate
        
        // Playback sequence scope
        
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackQueueIndex] = UInt(sequencer.sequenceInfo.trackIndex)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackQueueCount] = UInt(sequencer.sequenceInfo.totalTracks)
        
        // Update the nowPlayingInfo dictionary in the Now Playing Info Center.
        
        infoCenter.playbackState = MPNowPlayingPlaybackState.fromPlaybackState(playbackInfo.state)
        infoCenter.nowPlayingInfo = nowPlayingInfo
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
