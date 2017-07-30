import Cocoa

/*
    Concrete implementation of a middleman/facade between AppDelegate (UI) and Player. Accepts all requests originating from AppDelegate, converts/marshals them into lower-level requests suitable for Player, and forwards them to Player. Also, notifies AppDelegate when important events (such as playback completion) have occurred in Player.

    See AuralPlayerDelegate, AuralSoundTuningDelegate, and EventSubscriber protocols to learn more about the public functions implemented here.
*/
class PlayerDelegate: AuralPlayerDelegate, AuralPlaylistControlDelegate, AuralSoundTuningDelegate, AuralRecorderDelegate, EventSubscriber {
    
    // Time in seconds for seeking forward/backward
    fileprivate static let SEEK_TIME: Double = 5
    fileprivate static let VOLUME_DELTA: Float = 0.05
    fileprivate static let BALANCE_DELTA: Float = 0.1
    
    fileprivate var playerState: SavedPlayerState?
    
    // Currently playing track
    fileprivate var playingTrack: Track?
    
    // See PlaybackState
    fileprivate var playbackState: PlaybackState = .no_FILE
    
    fileprivate var repeatMode: RepeatMode = RepeatMode.off
    fileprivate var shuffleMode: ShuffleMode = ShuffleMode.off
    
    // The current player playlist
    fileprivate var playlist: Playlist {
        return Playlist.instance()
    }
    
    fileprivate static let singleton: PlayerDelegate = PlayerDelegate()
    
    // The actual audio player
    fileprivate var player: Player
    
    static func instance() -> PlayerDelegate {
        return singleton
    }
    
    fileprivate init() {
        
        // TODO: This is a horribly ugly hack, should be in AppDelegate
        PlayerDelegate.configureLogging()
        
        player = Player.instance()
        loadPlayerState()
        
        EventRegistry.subscribe(EventType.playbackCompleted, subscriber: self, dispatchQueue: GCDDispatchQueue(queueType: QueueType.main))
    }
    
    // Make sure all logging is done to the app's log file
    fileprivate static func configureLogging() {
        
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = allPaths.first!
        let pathForLog = documentsDirectory + ("/" + AppConstants.logFileName)
        
        freopen(pathForLog.cString(using: String.Encoding.ascii)!, "a+", stderr)
    }
    
    // Loads saved player state from app config file, and initializes the player with that state
    fileprivate func loadPlayerState() {
        
        playerState = PlayerStateIO.load()
        
        if (playerState != nil) {
            
            player.loadPlayerState(playerState!)
            
            repeatMode = playerState!.repeatMode
            shuffleMode = playerState!.shuffleMode
            
            // Add tracks async, updating the UI one at a time
            DispatchQueue.global(qos: .userInitiated).async {
                
                for track in self.playerState!.playlist {
                    
                    let index = self.playlist.addTrack(URL(fileURLWithPath: track))
                    if (index >= 0) {
                        self.notifyTrackAdded(index)
                    }
                }
                
                // After tracks have been loaded, prep one for playback
                self.prepForNextTrack()
            }
        }
    }
    
    // Prepares one track for playback, by loading metadata, so as to minimize the time taken to start playback when the track is actually played.
    private func prepForNextTrack() {
        
        if (playlist.size() > 0) {
        
            DispatchQueue.global(qos: .background).async {
                
                let nextTracks: [Track] = self.playlist.determineNextTrack(self.playingTrack, repeatMode: self.repeatMode, shuffleMode: self.shuffleMode)
                
                for track in nextTracks {
                    TrackIO.prepareForPlayback(track)
                }
            }
        }
    }
    
    // This method should only be called from outside this class. For adding tracks within this class, always call the private method addTracks_sync().
    func addTracks(_ files: [URL]) {
        
        // Move to a background thread to unblock the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.addTracks_sync(files)
            
            if (self.playingTrack == nil) {
                self.prepForNextTrack()
            }
        }
    }
    
    // Adds a bunch of tracks synchronously
    private func addTracks_sync(_ files: [URL]) {
        
        if (files.count > 0) {
            
            for file in files {
                
                if (Utils.isDirectory(file)) {
                    self.addTracksFromDir(file)
                } else {
                    self.addSingleTrack(file)
                }
            }
        }
    }
    
    fileprivate func addSingleTrack(_ file: URL) {
        
        let fileExtension = file.pathExtension.lowercased()
        
        if (fileExtension == AppConstants.customPlaylistExtension) {
            
            // Playlist
            let loadedPlaylist = PlaylistIO.loadPlaylist(file)
            if (loadedPlaylist != nil) {
                playlist.addPlaylist(loadedPlaylist!, notifyTrackAdded)
            }
            
        } else if (AppConstants.supportedAudioFileTypes.contains(fileExtension)) {
            // Track
            let newTrackIndex = playlist.addTrack(file)
            if (newTrackIndex >= 0) {
                notifyTrackAdded(newTrackIndex)
            }
        } else {
            // Unsupported file type, ignore
            NSLog("Ignoring unsupported file: %@", file.path)
        }
    }
    
    // Publishes a notification that a new track has been added to the playlist
    func notifyTrackAdded(_ trackIndex: Int) {
        
        let trackAddedEvent = TrackAddedEvent(trackIndex: trackIndex)
        EventRegistry.publishEvent(.trackAdded, trackAddedEvent)
    }
    
    fileprivate func addTracksFromDir(_ dir: URL) {
        
        let fileManager: FileManager = FileManager.default
        
        do {
            
        // Retrieve all files/subfolders within this folder
        let files = try fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: [], options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            
            // Add them
            addTracks_sync(files)
            
        } catch let error as NSError {
            NSLog("Error retrieving contents of directory '%@': %@", dir.path, error.description)
        }
    }
    
    func removeTrack(_ index: Int) -> Int? {
        
        let selTrack = playlist.getTrackAt(index)
        playlist.removeTrack(index)
        
        // If the removed track is not the playing track, continue playing !
        if (selTrack?.file!.path == playingTrack?.file!.path) {
            player.stop()
            playingTrack = nil
            playbackState = .no_FILE
            return nil
        } else {
            return getPlayingTrackIndex()
        }
    }
    
    func moveTrackDown(_ index: Int) -> Int {
        
        if (index < (playlist.size() - 1)) {
            playlist.shiftTrackDown(playlist.getTrackAt(index)!)
            return index + 1
        }
        
        return index
    }
    
    func moveTrackUp(_ index: Int) -> Int {
        
        if (index > 0) {
            playlist.shiftTrackUp(playlist.getTrackAt(index)!)
            return index - 1
        }
        
        return index
    }
    
    func clearPlaylist() {
        playlist.clear()
        player.stop()
        playbackState = .no_FILE
        playingTrack = nil
    }
    
    func savePlaylist(_ file: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            PlaylistIO.savePlaylist(file)
        }
    }
    
    func getPlaylistSummary() -> (numTracks: Int, totalDuration: Double) {
        return (playlist.size(), playlist.totalDuration())
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
            
        case .no_FILE: continuePlaying()
            if (playingTrack != nil) {
                trackChanged = true
            }
            
        case .paused: resume()
            
        case .playing: pause()
            
        }
        
        return (playbackState, playingTrack, getPlayingTrackIndex(), trackChanged)
    }
    
    func play(_ index: Int) -> Track {
        
        // Playing a random track invalidates the current shuffle sequence
        playlist.clearShuffleSequence()
        
        let track = playlist.getTrackAt(index)!
        play(track)
        
        return track
    }
    
    func continuePlaying() -> (playingTrack: Track?, playingTrackIndex: Int?) {
        play(playlist.continuePlaying(playingTrack, repeatMode, shuffleMode))
        return (playingTrack, getPlayingTrackIndex())
    }
    
    fileprivate func play(_ track: Track?) {
        
        playingTrack = track
        if (track != nil) {
            TrackIO.prepareForPlayback(track!)
            
            // Stop if currently playing
            if (playbackState == .playing || playbackState == .paused) {
                player.stop()
            }
            
            player.play(track!)
            playbackState = .playing
            prepForNextTrack()
        }
    }
    
    fileprivate func pause() {
        player.pause()
        playbackState = .paused
    }
    
    fileprivate func resume() {
        player.resume()
        playbackState = .playing
    }
    
    func getSeekSecondsAndPercentage() -> (seconds: Double, percentage: Double) {
        
        let seconds = player.getSeekPosition()
        let percentage = playingTrack != nil ? seconds * 100 / playingTrack!.duration! : 0
        
        return (seconds, percentage)
    }
    
    func seekForward() {
        
        if (playbackState != .playing) {
            return
        }
        
        let curPosn = player.getSeekPosition()
        let newPosn = min(playingTrack!.duration!, curPosn + PlayerDelegate.SEEK_TIME)
        
        player.seekToTime(newPosn)
    }
    
    func seekBackward() {
        
        if (playbackState != .playing) {
            return
        }
        
        let curPosn = player.getSeekPosition()
        let newPosn = max(0, curPosn - PlayerDelegate.SEEK_TIME)
        
        player.seekToTime(newPosn)
    }
    
    func seekToPercentage(_ percentage: Double) {
        
        if (playbackState != .playing) {
            return
        }
        
        let newPosn = percentage * playingTrack!.duration! / 100
        player.seekToTime(newPosn)
    }
    
    func nextTrack() -> (playingTrack: Track?, playingTrackIndex: Int?) {
        
        let nextTrack = playlist.next(playingTrack, repeatMode: repeatMode, shuffleMode: shuffleMode)
        
        if (nextTrack != nil) {
            play(nextTrack!)
        }
        
        return (nextTrack, getPlayingTrackIndex())
    }
    
    func previousTrack() -> (playingTrack: Track?, playingTrackIndex: Int?) {
        
        let prevTrack = playlist.previous(playingTrack, repeatMode: repeatMode, shuffleMode: shuffleMode)
        
        if (prevTrack != nil) {
            play(prevTrack!)
        }
        
        return (prevTrack, getPlayingTrackIndex())
    }
    
    func getVolume() -> Float {
        return round(player.getVolume() * 100)
    }
    
    func setVolume(_ volumePercentage: Float) {
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
    
    func setBalance(_ balance: Float) {
        player.setBalance(balance)
    }
    
    func panLeft() -> Float {
        
        let curBalance = player.getBalance()
        var newBalance = max(-1, curBalance - Float(PlayerDelegate.BALANCE_DELTA))
        
        // Snap to center
        if (curBalance > 0 && newBalance < 0) {
            newBalance = 0
        }
        
        player.setBalance(newBalance)
        
        return newBalance
    }
    
    func panRight() -> Float {
        
        let curBalance = player.getBalance()
        var newBalance = min(1, curBalance + Float(PlayerDelegate.BALANCE_DELTA))
        
        // Snap to center
        if (curBalance < 0 && newBalance > 0) {
            newBalance = 0
        }
        
        player.setBalance(newBalance)
        
        return newBalance
    }
    
    // Sets global gain (or preamp) for the equalizer
    func setEQGlobalGain(_ gain: Float) {
        player.setEQGlobalGain(gain)
    }
    
    func setEQBand(_ frequency: Int, gain: Float) {
        player.setEQBand(frequency, gain: gain)
    }
    
    func setEQBands(_ bands: [Int : Float]) {
        player.setEQBands(bands)
    }
    
    func togglePitchBypass() -> Bool {
        return player.togglePitchBypass()
    }
    
    func setPitch(_ pitch: Float) {
        // Convert from octaves (-2, 2) to cents (-2400, 2400)
        player.setPitch(pitch * 1200)
    }
    
    func setPitchOverlap(_ overlap: Float) {
        player.setPitchOverlap(overlap)
    }
    
    func toggleTimeBypass() -> Bool {
        return player.toggleTimeBypass()
    }
    
    func isTimeBypass() -> Bool {
        return player.isTimeBypass()
    }
    
    func setTimeStretchRate(_ rate: Float) {
        player.setTimeStretchRate(rate)
    }
    
    func toggleReverbBypass() -> Bool {
        return player.toggleReverbBypass()
    }
    
    func setReverb(_ preset: ReverbPresets) {
        player.setReverb(preset)
    }
    
    func setReverbAmount(_ amount: Float) {
        return player.setReverbAmount(amount)
    }
    
    func toggleDelayBypass() -> Bool {
        return player.toggleDelayBypass()
    }
    
    func setDelayAmount(_ amount: Float) {
        player.setDelayAmount(amount)
    }
    
    func setDelayTime(_ time: Double) {
        player.setDelayTime(time)
    }
    
    func setDelayFeedback(_ percent: Float) {
        player.setDelayFeedback(percent)
    }
    
    func setDelayLowPassCutoff(_ cutoff: Float) {
        player.setDelayLowPassCutoff(cutoff)
    }
    
    func toggleFilterBypass() -> Bool {
        return player.toggleFilterBypass()
    }
    
    func setFilterBassBand(_ min: Float, _ max: Float) {
        player.setFilterBassBand(min, max)
    }
    
    func setFilterMidBand(_ min: Float, _ max: Float) {
        player.setFilterMidBand(min, max)
    }
    
    func setFilterTrebleBand(_ min: Float, _ max: Float) {
        player.setFilterTrebleBand(min, max)
    }
    
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        
        switch repeatMode {
            
        case .off: repeatMode = .one
        
        // If repeating one track, cannot also shuffle
        if (shuffleMode == .on) {
            shuffleMode = .off
        }
        case .one: repeatMode = .all
        case .all: repeatMode = .off
            
        }
        
        // Invalidate the shuffle sequence (if there is one), and prepare the next track for playback
        playlist.clearShuffleSequence()
        prepForNextTrack()
        
        return (repeatMode, shuffleMode)
    }
    
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        
        switch shuffleMode {
            
        case .off: shuffleMode = .on
        
        // Can't shuffle and repeat one track
        if (repeatMode == .one) {
            repeatMode = .off
        }
            
        case .on: shuffleMode = .off
            
        }
        
        // Invalidate the shuffle sequence (if there is one), and prepare the next track for playback
        playlist.clearShuffleSequence()
        prepForNextTrack()
        
        return (repeatMode, shuffleMode)
    }
    
    func startRecording(_ format: RecordingFormat) {
        player.startRecording(format)
    }
    
    func stopRecording() {
        player.stopRecording()
    }
    
    func saveRecording(_ url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.player.saveRecording(url)
        }
    }
    
    func deleteRecording() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.player.deleteRecording()
        }
    }
    
    func getRecordingDuration() -> Double {
        return player.getRecordingDuration()
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
            state.playlist.append(track.file!.path)
        }
        
        let app = (NSApplication.shared().delegate as! AppDelegate)
        
        // Read UI state
        state.showEffects = app.isEffectsShown()
        state.showPlaylist = app.isPlaylistShown()
        
        PlayerStateIO.save(state)
    }
    
    // Called when playback of the current track completes
    func consumeEvent(_ event: Event) {
        
        player.stop()
        
        let newTrackInfo = continuePlaying()
        
        let trackChangedEvent = TrackChangedEvent(newTrack: playingTrack, newTrackIndex: newTrackInfo.playingTrackIndex)
        
        if (playingTrack != nil) {
            playbackState = .playing
        } else {
            playbackState = .no_FILE
        }
        
        // Notify the UI about this track change event
        EventRegistry.publishEvent(.trackChanged, trackChangedEvent)
    }
    
    func searchPlaylist(searchQuery: SearchQuery) -> SearchResults {
        return playlist.searchPlaylist(searchQuery: searchQuery)
    }
    
    func sortPlaylist(sort: Sort) {
        playlist.sortPlaylist(sort: sort)
    }
}
