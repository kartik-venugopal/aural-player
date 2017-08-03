import Cocoa

/*
 Concrete implementation of a middleman/facade between AppDelegate (UI) and Player. Accepts all requests originating from AppDelegate, converts/marshals them into lower-level requests suitable for Player, and forwards them to Player. Also, notifies AppDelegate when important events (such as playback completion) have occurred in Player.
 
 See AuralPlayerDelegate, AuralSoundTuningDelegate, and EventSubscriber protocols to learn more about the public functions implemented here.
 */
class PlayerDelegate: AuralPlayerDelegate, AuralPlaylistControlDelegate, AuralSoundTuningDelegate, AuralRecorderDelegate, EventSubscriber {
    
    // Time in seconds for seeking forward/backward
    private static let SEEK_TIME: Double = 5
    private static let VOLUME_DELTA: Float = 0.05
    private static let BALANCE_DELTA: Float = 0.1
    
    private var playerState: SavedPlayerState?
    
    // The current player playlist
    private var playlist: Playlist
    
    // The actual audio player
    private var player: Player
    
    // Currently playing track
    fileprivate var playingTrack: IndexedTrack?
    
    // See PlaybackState
    fileprivate var playbackState: PlaybackState = .noTrack
    
    private static let singleton: PlayerDelegate = AppInitializer.getPlayerDelegate()
    
    static func instance() -> PlayerDelegate {
        return singleton
    }
    
    init(_ player: Player, _ playerState: SavedPlayerState, _ playlist: Playlist) {
        
        self.player = player
        self.playlist = playlist
        self.playerState = playerState
        
        EventRegistry.subscribe(EventType.playbackCompleted, subscriber: self, dispatchQueue: GCDDispatchQueue(queueType: QueueType.main))
    }
    
    // This is called when the app loads initially. Loads the playlist from the app state file on disk. Only meant to be called once.
    func loadPlaylistFromSavedState() {
        
        // Add tracks async, notifying the UI one at a time
        DispatchQueue.global(qos: .userInitiated).async {
            
            for track in self.playerState!.playlist {
                
                let index = self.playlist.addTrack(URL(fileURLWithPath: track))
                if (index >= 0) {
                    self.notifyTrackAdded(index)
                }
            }
        }
    }
    
    func getPlayerState() -> SavedPlayerState? {
        return playerState
    }
    
    // This method should only be called from outside this class. For adding tracks within this class, always call the private method addTracks_sync().
    func addTracks(_ files: [URL]) {
        
        // Move to a background thread to unblock the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.addTracks_sync(files)
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
    
    private func addSingleTrack(_ file: URL) {
        
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
    
    private func addTracksFromDir(_ dir: URL) {
        
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
        
        let removingPlayingTrack: Bool = (index == playlist.cursor())
        playlist.removeTrack(index)
        
        // If the removed track is not the playing track, continue playing !
        if (removingPlayingTrack) {
            stopPlayback()
        }
        
        // Update playing track index (which may have changed)
        playingTrack?.index = playlist.cursor()
        
        return playlist.cursor()
    }
    
    func moveTrackDown(_ index: Int) -> Int {
        
        if (index < (playlist.size() - 1)) {
            playlist.shiftTrackDown(index)
            
            // Update playing track index (which may have changed)
            playingTrack?.index = playlist.cursor()
            
            return index + 1
        }
        
        return index
    }
    
    func moveTrackUp(_ index: Int) -> Int {
        
        if (index > 0) {
            playlist.shiftTrackUp(index)
            
            // Update playing track index (which may have changed)
            playingTrack?.index = playlist.cursor()
            
            return index - 1
        }
        
        return index
    }
    
    func clearPlaylist() {
        playlist.clear()
        stopPlayback()
    }
    
    private func stopPlayback() {
        PlaybackSession.invalidate()
        player.stop()
        playbackState = .noTrack
        playingTrack = nil
    }
    
    func savePlaylist(_ file: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            PlaylistIO.savePlaylist(file)
        }
    }
    
    func getPlayingTrack() -> IndexedTrack? {
        return playingTrack
    }
    
    func getPlaylistSummary() -> (numTracks: Int, totalDuration: Double) {
        return (playlist.size(), playlist.totalDuration())
    }
    
    func getMoreInfo() -> IndexedTrack? {
        
        if (playingTrack == nil) {
            return nil
        }
        
        TrackIO.loadDetailedTrackInfo(playingTrack!.track!)
        return playingTrack
    }
    
    func togglePlayPause() -> (playbackState: PlaybackState, playingTrack: IndexedTrack?, trackChanged: Bool) {
        
        var trackChanged = false
        
        // Determine current state of player, to then toggle it
        switch playbackState {
            
        case .noTrack: continuePlaying()
        if (playingTrack != nil) {
            trackChanged = true
        }
            
        case .paused: resume()
            
        case .playing: pause()
    
        }
        
        return (playbackState, playingTrack, trackChanged)
    }

    func play(_ index: Int) -> IndexedTrack {
        
        let track = playlist.selectTrackAt(index)!
        play(track)
        
        return playingTrack!
    }
    
    func continuePlaying() -> IndexedTrack? {
        play(playlist.continuePlaying())
        return playingTrack
    }

    func nextTrack() -> IndexedTrack? {
    
        let nextTrack = playlist.next()
        if (nextTrack != nil) {
            play(nextTrack)
        }
        
        return nextTrack
    }
    
    func previousTrack() -> IndexedTrack? {
        
        let prevTrack = playlist.previous()
        if (prevTrack != nil) {
            play(prevTrack)
        }
        
        return prevTrack
    }
    
    private func play(_ track: IndexedTrack?) {
        
        playingTrack = track
        if (track != nil) {
            
            PlaybackSession.start(track!)
            TrackIO.prepareForPlayback(track!.track!)
            
            // Stop if currently playing
            
            if (playbackState == .paused || playbackState == .playing) {
                player.stop()
            }
            
            player.play(track!.track!)
            playbackState = .playing
        }
    }
    
    private func pause() {
        player.pause()
        playbackState = .paused
    }
    
    private func resume() {
        player.resume()
        playbackState = .playing
    }
    
    func getPlaybackState() -> PlaybackState {
        return playbackState
    }
    
    func getSeekSecondsAndPercentage() -> (seconds: Double, percentage: Double) {
        
        let seconds = playingTrack != nil ? player.getSeekPosition() : 0
        let percentage = playingTrack != nil ? seconds * 100 / playingTrack!.track!.duration! : 0
        
        return (seconds, percentage)
    }
    
    func seekForward() {
        
        if (playbackState != .playing) {
            return
        }
        
        PlaybackSession.start(playingTrack!)
        
        let curPosn = player.getSeekPosition()
        let newPosn = min(playingTrack!.track!.duration!, curPosn + PlayerDelegate.SEEK_TIME)
        
        // TODO: If reached end of duration, end it here instead of passing on the request
        player.seekToTime(newPosn)
    }
    
    func seekBackward() {
        
        if (playbackState != .playing) {
            return
        }
        
        PlaybackSession.start(playingTrack!)
        
        let curPosn = player.getSeekPosition()
        let newPosn = max(0, curPosn - PlayerDelegate.SEEK_TIME)
        
        player.seekToTime(newPosn)
    }
    
    func seekToPercentage(_ percentage: Double) {
        
        if (playbackState != .playing) {
            return
        }
        
        PlaybackSession.start(playingTrack!)
        
        // TODO: If reached end of duration, end it here instead of passing on the request
        let newPosn = percentage * playingTrack!.track!.duration! / 100
        
        player.seekToTime(newPosn)
    }
    
    func getVolume() -> Float {
        return round(player.getVolume() * AppConstants.volumeConversion_playerToUI)
    }
    
    func setVolume(_ volumePercentage: Float) {
        player.setVolume(volumePercentage * AppConstants.volumeConversion_UIToPlayer)
    }
    
    func increaseVolume() -> Float {
        let curVolume = player.getVolume()
        let newVolume = min(1, curVolume + PlayerDelegate.VOLUME_DELTA)
        player.setVolume(newVolume)
        return round(newVolume * AppConstants.volumeConversion_playerToUI)
    }
    
    func decreaseVolume() -> Float {
        let curVolume = player.getVolume()
        let newVolume = max(0, curVolume - PlayerDelegate.VOLUME_DELTA)
        player.setVolume(newVolume)
        return round(newVolume * AppConstants.volumeConversion_playerToUI)
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
    
    func setPitch(_ pitch: Float) -> String {
        // Convert from octaves (-2, 2) to cents (-2400, 2400)
        player.setPitch(pitch * AppConstants.pitchConversion_UIToPlayer)
        return ValueFormatter.formatPitch(pitch)
    }
    
    func setPitchOverlap(_ overlap: Float) -> String {
        player.setPitchOverlap(overlap)
        return ValueFormatter.formatOverlap(overlap)
    }
    
    func toggleTimeBypass() -> Bool {
        return player.toggleTimeBypass()
    }
    
    func isTimeBypass() -> Bool {
        return player.isTimeBypass()
    }
    
    func setTimeStretchRate(_ rate: Float) -> String {
        player.setTimeStretchRate(rate)
        return ValueFormatter.formatTimeStretchRate(rate)
    }
    
    func setTimeOverlap(_ overlap: Float) -> String {
        player.setTimeOverlap(overlap)
        return ValueFormatter.formatOverlap(overlap)
    }
    
    func toggleReverbBypass() -> Bool {
        return player.toggleReverbBypass()
    }
    
    func setReverb(_ preset: ReverbPresets) {
        player.setReverb(preset)
    }
    
    func setReverbAmount(_ amount: Float) -> String {
        player.setReverbAmount(amount)
        return ValueFormatter.formatReverbAmount(amount)
    }
    
    func toggleDelayBypass() -> Bool {
        return player.toggleDelayBypass()
    }
    
    func setDelayAmount(_ amount: Float) -> String {
        player.setDelayAmount(amount)
        return ValueFormatter.formatDelayAmount(amount)
    }
    
    func setDelayTime(_ time: Double) -> String {
        player.setDelayTime(time)
        return ValueFormatter.formatDelayTime(time)
    }
    
    func setDelayFeedback(_ percent: Float) -> String {
        player.setDelayFeedback(percent)
        return ValueFormatter.formatDelayFeedback(percent)
    }
    
    func setDelayLowPassCutoff(_ cutoff: Float) -> String {
        player.setDelayLowPassCutoff(cutoff)
        return ValueFormatter.formatDelayLowPassCutoff(cutoff)
    }
    
    func toggleFilterBypass() -> Bool {
        return player.toggleFilterBypass()
    }
    
    func setFilterBassBand(_ min: Float, _ max: Float) -> String {
        player.setFilterBassBand(min, max)
        return ValueFormatter.formatFilterFrequencyRange(min, max)
    }
    
    func setFilterMidBand(_ min: Float, _ max: Float) -> String {
        player.setFilterMidBand(min, max)
        return ValueFormatter.formatFilterFrequencyRange(min, max)
    }
    
    func setFilterTrebleBand(_ min: Float, _ max: Float) -> String {
        player.setFilterTrebleBand(min, max)
        return ValueFormatter.formatFilterFrequencyRange(min, max)
    }
    
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return playlist.toggleRepeatMode()
    }
    
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return playlist.toggleShuffleMode()
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
    
    func getRecordingInfo() -> RecordingInfo {
        return player.getRecordingInfo()
    }
    
    func tearDown() {
        
        player.tearDown()
        
        // Save player state
        let state = player.getPlayerState()
        
        state.repeatMode = playlist.getRepeatMode()
        state.shuffleMode = playlist.getShuffleMode()
        
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
        
        let _evt = event as! PlaybackCompletedEvent
        
        // Do not accept duplicate/old events
        if (PlaybackSession.isCurrent(_evt.session)) {
            
            // Stop playback of the old track
            stopPlayback()
            
            // Continue the playback sequence
            continuePlaying()
            
            let trackChangedEvent = TrackChangedEvent(playingTrack)
            
            if (playingTrack != nil) {
                playbackState = .playing
            } else {
                playbackState = .noTrack
            }
            
            // Notify the UI about this track change event
            EventRegistry.publishEvent(.trackChanged, trackChangedEvent)
        }
    }
    
    func searchPlaylist(searchQuery: SearchQuery) -> SearchResults {
        return playlist.searchPlaylist(searchQuery: searchQuery)
    }
    
    func sortPlaylist(sort: Sort) {
        playlist.sortPlaylist(sort: sort)
        
        // Update playing track index (which may have changed)
        playingTrack?.index = playlist.cursor()
    }
}
