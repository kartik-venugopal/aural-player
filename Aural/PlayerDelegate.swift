import Cocoa

/*
    Concrete implementation of a middleman/facade between AppDelegate (UI) and Player. Accepts all requests originating from AppDelegate, converts/marshals them into lower-level requests suitable for Player, and forwards them to Player. Also, notifies AppDelegate when important events (such as playback completion) have occurred in Player.

    See AuralPlayerDelegate, AuralSoundTuningDelegate, and EventSubscriber protocols to learn more about the public functions implemented here.
*/
class PlayerDelegate: AuralPlayerDelegate, AuralSoundTuningDelegate, EventSubscriber {
    
    // Time in seconds for seeking forward/backward
    private static let SEEK_TIME: Double = 5
    private static let VOLUME_DELTA: Float = 0.05
    private static let BALANCE_DELTA: Float = 0.1
    
    private var playerState: SavedPlayerState?
    
    // Currently playing track
    private var playingTrack: Track?
    
    // See PlaybackState
    private var playbackState: PlaybackState = .NO_FILE
    
    private var repeatMode: RepeatMode = RepeatMode.OFF
    private var shuffleMode: ShuffleMode = ShuffleMode.OFF
    
    // The current player playlist
    private var playlist: Playlist {
        return Playlist.instance()
    }
    
    private static let singleton: PlayerDelegate = PlayerDelegate()
    
    // The actual audio player
    private var player: Player
    
    static func instance() -> PlayerDelegate {
        return singleton
    }
    
    private init() {
        
        // TODO: This is a horribly ugly hack, should be in AppDelegate
        PlayerDelegate.configureLogging()
        
        player = Player.instance()
        loadPlayerState()
        
        // Register self as a subscriber to PlaybackCompleted events (published by Player)
        EventRegistry.subscribe(.PlaybackCompleted, subscriber: self)
    }
    
    
    // Make sure all logging is done to the app's log file
    private static func configureLogging() {
        
        let allPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = allPaths.first!
        let pathForLog = documentsDirectory.stringByAppendingString("/" + AppConstants.logFileName)
        
        freopen(pathForLog.cStringUsingEncoding(NSASCIIStringEncoding)!, "a+", stderr)
    }
    
    // Loads saved player state from app config file, and initializes the player with that state
    private func loadPlayerState() {
        
        playerState = PlayerStateIO.load()
        
        if (playerState != nil) {
            
            player.loadPlayerState(playerState!)
            
            repeatMode = playerState!.repeatMode
            shuffleMode = playerState!.shuffleMode
            
            for track in playerState!.playlist {
                playlist.addTrack(NSURL(fileURLWithPath: track))
            }
        }
    }
    
    func addTracks(files: [NSURL]) {
        
        if (files.count > 0) {
            
            for file in files {
                
                if (Utils.isDirectory(file)) {
                    addTracksFromDir(file)
                } else {
                    addSingleTrack(file)
                }
            }
        }
    }
    
    private func addSingleTrack(file: NSURL) {
        
        let fileExtension = file.pathExtension!.lowercaseString
        
        if (fileExtension == AppConstants.customPlaylistExtension) {
            // Playlist
            PlaylistIO.loadPlaylist(file)
            
        } else if (AppConstants.supportedAudioFileTypes.contains(fileExtension)) {
            // Track
            if (!playlist.trackExists(file.path!)) {
                playlist.addTrack(file)
            }
        } else {
            // Unsupported file type, ignore
            NSLog("Ignoring unsupported file: %@", file.path!)
        }
    }
    
    private func addTracksFromDir(dir: NSURL) {
        
        let fileManager: NSFileManager = NSFileManager.defaultManager()
        
        do {
            
        // Retrieve all files/subfolders within this folder
        let files = try fileManager.contentsOfDirectoryAtURL(dir, includingPropertiesForKeys: [], options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
            
            // Add them
            addTracks(files)
            
        } catch let error as NSError {
            NSLog("Error retrieving contents of directory '%@': %@", dir.path!, error.description)
        }
    }
    
    func removeTrack(index: Int) -> Int? {
        
        let selTrack = playlist.getTrackAt(index)
        playlist.removeTrack(index)
        
        // If the removed track is not the playing track, continue playing !
        if (selTrack?.file!.path == playingTrack?.file!.path) {
            player.stop()
            playingTrack = nil
            playbackState = .NO_FILE
            return nil
        } else {
            return getPlayingTrackIndex()
        }
    }
    
    func moveTrackDown(index: Int) -> Int {
        
        if (index < (playlist.size() - 1)) {
            playlist.shiftTrackDown(playlist.getTrackAt(index)!)
            return index + 1
        }
        
        return index
    }
    
    func moveTrackUp(index: Int) -> Int {
        
        if (index > 0) {
            playlist.shiftTrackUp(playlist.getTrackAt(index)!)
            return index - 1
        }
        
        return index
    }
    
    func clearPlaylist() {
        playlist.clear()
        player.stop()
        playbackState = .NO_FILE
        playingTrack = nil
    }
    
    func savePlaylist(file: NSURL) {
        PlaylistIO.savePlaylist(file)
    }
    
    func getPlayingTrack() -> Track? {
        return playingTrack
    }
    
    func getPlayingTrackIndex() -> Int? {
        if (playingTrack == nil) {
            return nil
        }
        
        return playlist.indexOf(playingTrack!)
    }
    
    func getMoreInfo() -> Track? {
        
        if (playingTrack == nil) {
            return nil
        }
        
        TrackIO.loadDetailedTrackInfo(playingTrack!)
        return playingTrack
    }
    
    func getPlaybackState() -> PlaybackState {
        return playbackState
    }
    
    func togglePlayPause() -> (playbackState: PlaybackState, playingTrack: Track?, playingTrackIndex: Int?, trackChanged: Bool) {
        
        var trackChanged = false
        
        // Determine current state of player, to then toggle it
        switch playbackState {
            
        case .NO_FILE: continuePlaying()
        if (playingTrack != nil) {
            trackChanged = true
            }
            
        case .PAUSED: resume()
            
        case .PLAYING: pause()
            
        }
        
        return (playbackState, playingTrack, getPlayingTrackIndex(), trackChanged)
    }
    
    func play(index: Int) -> Track {
        
        // Playing a random track invalidates the current shuffle sequence
        playlist.clearShuffleSequence()
        
        let track = playlist.getTrackAt(index)!
        play(track)
        
        return track
    }
    
    func continuePlaying() -> (playingTrack: Track?, playingTrackIndex: Int?) {
        play(playlist.continuePlaying(playingTrack, repeatMode: repeatMode, shuffleMode: shuffleMode))
        return (playingTrack, getPlayingTrackIndex())
    }
    
    private func play(track: Track?) {
        playingTrack = track
        if (track != nil) {
            TrackIO.prepareForPlayback(track!)
            player.play(track!)
            playbackState = .PLAYING
        }
    }
    
    private func pause() {
        player.pause()
        playbackState = .PAUSED
    }
    
    private func resume() {
        player.resume()
        playbackState = .PLAYING
    }
    
    func getSeekSecondsAndPercentage() -> (seconds: Double, percentage: Double) {
        
        let seconds = player.getSeekPosition()
        let percentage = playingTrack != nil ? seconds * 100 / playingTrack!.duration! : 0
        
        return (seconds, percentage)
    }
    
    func seekForward() {
        
        if (playbackState != .PLAYING) {
            return
        }
        
        let curPosn = player.getSeekPosition()
        let newPosn = min(playingTrack!.duration!, curPosn + PlayerDelegate.SEEK_TIME)
        
        player.seekToTime(newPosn)
    }
    
    func seekBackward() {
        
        if (playbackState != .PLAYING) {
            return
        }
        
        let curPosn = player.getSeekPosition()
        let newPosn = max(0, curPosn - PlayerDelegate.SEEK_TIME)
        
        player.seekToTime(newPosn)
    }
    
    func seekToPercentage(percentage: Double) {
        
        if (playbackState != .PLAYING) {
            return
        }
        
        let newPosn = percentage * playingTrack!.duration! / 100
        player.seekToTime(newPosn)
    }
    
    func nextTrack() -> (playingTrack: Track?, playingTrackIndex: Int?) {
        
        let nextTrack = playlist.next(playingTrack!, repeatMode: repeatMode, shuffleMode: shuffleMode)
        
        if (nextTrack != nil) {
            play(nextTrack!)
        }
        
        return (nextTrack, getPlayingTrackIndex())
    }
    
    func previousTrack() -> (playingTrack: Track?, playingTrackIndex: Int?) {
        
        let prevTrack = playlist.previous(playingTrack!, repeatMode: repeatMode, shuffleMode: shuffleMode)
        
        if (prevTrack != nil) {
            play(prevTrack!)
        }
        
        return (prevTrack, getPlayingTrackIndex())
    }
    
    func getVolume() -> Float {
        return round(player.getVolume() * 100)
    }
    
    func setVolume(volumePercentage: Float) {
        player.setVolume(volumePercentage / 100)
    }
    
    func increaseVolume() -> Float {
        let curVolume = player.getVolume()
        let newVolume = min(1, curVolume + PlayerDelegate.VOLUME_DELTA)
        player.setVolume(newVolume)
        return round(newVolume * 100)
    }
    
    func decreaseVolume() -> Float {
        let curVolume = player.getVolume()
        let newVolume = max(0, curVolume - PlayerDelegate.VOLUME_DELTA)
        player.setVolume(newVolume)
        return round(newVolume * 100)
    }
    
    func toggleMute() -> Bool {
        
        let muted = isMuted()
        if muted {
            player.unmute()
        } else {
            player.mute()
        }
        
        return !muted
    }
    
    func isMuted() -> Bool {
        return player.isMuted()
    }
    
    func getBalance() -> Float {
        return player.getBalance()
    }
    
    func setBalance(balance: Float) {
        player.setBalance(balance)
    }
    
    func panLeft() -> Float {
        
        let curBalance = player.getBalance()
        let newBalance = max(-1, curBalance - Float(PlayerDelegate.BALANCE_DELTA))
        player.setBalance(newBalance)
        
        return newBalance
    }
    
    func panRight() -> Float {
        
        let curBalance = player.getBalance()
        let newBalance = min(1, curBalance + Float(PlayerDelegate.BALANCE_DELTA))
        player.setBalance(newBalance)
        
        return newBalance
    }
    
    // Sets global gain (or preamp) for the equalizer
    func setEQGlobalGain(gain: Float) {
        player.setEQGlobalGain(gain)
    }
    
    func setEQBand(frequency: Int, gain: Float) {
        player.setEQBand(frequency, gain: gain)
    }
    
    func setEQBands(bands: [Int : Float]) {
        player.setEQBands(bands)
    }
    
    func togglePitchBypass() -> Bool {
        return player.togglePitchBypass()
    }
    
    func setPitch(pitch: Float) {
        // Convert from octaves (-2, 2) to cents (-2400, 2400)
        player.setPitch(pitch * 1200)
    }
    
    func setPitchOverlap(overlap: Float) {
        player.setPitchOverlap(overlap)
    }
    
    func toggleReverbBypass() -> Bool {
        return player.toggleReverbBypass()
    }
    
    func setReverb(preset: ReverbPresets) {
        player.setReverb(preset)
    }
    
    func setReverbAmount(amount: Float) {
        return player.setReverbAmount(amount)
    }
    
    func toggleDelayBypass() -> Bool {
        return player.toggleDelayBypass()
    }
    
    func setDelayAmount(amount: Float) {
        player.setDelayAmount(amount)
    }
    
    func setDelayTime(time: Double) {
        player.setDelayTime(time)
    }
    
    func setDelayFeedback(percent: Float) {
        player.setDelayFeedback(percent)
    }
    
    func setDelayLowPassCutoff(cutoff: Float) {
        player.setDelayLowPassCutoff(cutoff)
    }
    
    func toggleFilterBypass() -> Bool {
        return player.toggleFilterBypass()
    }
    
    func setFilterHighPassCutoff(cutoff: Float) {
        player.setFilterHighPassCutoff(cutoff)
    }
    
    func setFilterLowPassCutoff(cutoff: Float) {
        player.setFilterLowPassCutoff(cutoff)
    }
    
    // Playback completed
    func consumeEvent(event: Event) {
        
        let newTrackInfo = continuePlaying()
        playingTrack = newTrackInfo.playingTrack
        
        let trackChangedEvent = TrackChangedEvent(newTrack: playingTrack, newTrackIndex: newTrackInfo.playingTrackIndex)
        
        if (playingTrack != nil) {
            playbackState = .PLAYING
        } else {
            playbackState = .NO_FILE
        }
        
        // Notify the UI about this track change event
        EventRegistry.publishEvent(.TrackChanged, event: trackChangedEvent)
    }
    
    func toggleRepeatMode() -> RepeatMode {
        
        switch repeatMode {
            
        case .OFF: repeatMode = .ONE
        case .ONE: repeatMode = .ALL
        case .ALL: repeatMode = .OFF
            
        }
        
        playlist.clearShuffleSequence()
        
        return repeatMode
    }
    
    func toggleShuffleMode() -> ShuffleMode {
        
        switch shuffleMode {
            
        case .OFF: shuffleMode = .ON
        case .ON: shuffleMode = .OFF
            
        }
        
        playlist.clearShuffleSequence()
        
        return shuffleMode
    }
    
    func getPlayerState() -> SavedPlayerState? {
        return playerState
    }
    
    func tearDown() {
        
        player.tearDown()
        
        // Save player state
        let state = player.getPlayerState()
        
        state.repeatMode = repeatMode
        state.shuffleMode = shuffleMode
        
        // Read playlist
        for track in playlist.getTracks() {
            state.playlist.append(track.file!.path!)
        }
        
        PlayerStateIO.save(state)
    }
}