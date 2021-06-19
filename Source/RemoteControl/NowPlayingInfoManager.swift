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
    
    private static let optimalArtworkSize: NSSize = NSMakeSize(50, 50)
    private static let defaultArtwork: NSImage = Images.imgPlayingArt.copy(ofSize: optimalArtworkSize)
    
    private var preTrackChange: Bool = false
    
    init(playbackInfo: PlaybackInfoDelegateProtocol, audioGraph: AudioGraphDelegateProtocol, sequencer: SequencerInfoDelegateProtocol) {
        
        self.playbackInfo = playbackInfo
        self.audioGraph = audioGraph
        self.sequencer = sequencer
        
        super.init()
    
        // Initialize the Now Playing Info Center with current info.
        infoCenter.nowPlayingInfo = [String: Any]()
        infoCenter.nowPlayingInfo![MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.audio.rawValue
        self.updateNowPlayingInfo()
        
        //
        // Subscribe to notifications about changes in the player's state, so that the Now Playing Info Center can be
        // updated in response to any of those changes.
        //
        Messenger.subscribe(self, .player_preTrackChange, self.handlePreTrackChange)
        Messenger.subscribe(self, .player_trackTransitioned, self.trackChanged)
        Messenger.subscribe(self, .player_trackNotPlayed, self.trackChanged)
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
    private func trackChanged() {
        
        updateNowPlayingInfo()
        preTrackChange = false
    }
    
    ///
    /// Responds to a change in the player's playback state. Updates the Now Playing Info Center with the new state.
    ///
    private func playbackStateChanged() {
        
        if preTrackChange {return}
        
        infoCenter.playbackState = MPNowPlayingPlaybackState.fromPlaybackState(playbackInfo.state)
        playbackRateChanged(audioGraph.timeUnit.effectiveRate)
    }
    
    private func playbackRateChanged(_ newRate: Float) {
        
        var nowPlayingInfo = infoCenter.nowPlayingInfo!
        
        // Set playback rate
        let playbackRate: Double = playbackInfo.state == .playing ? Double(newRate) : 0.0
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
        
        if #available(OSX 10.13.2, *) {
            
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: Self.optimalArtworkSize, requestHandler: {size in playingTrack?.art?.image.copy(ofSize: size) ?? Self.defaultArtwork})
        }
        
        // Seek position and duration
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playbackInfo.seekPosition.timeElapsed
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playingTrack?.duration
        
        // Playback rate
        
        let playbackRate: Double = playbackInfo.state == .playing ? Double(audioGraph.timeUnit.effectiveRate) : 0.0
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
