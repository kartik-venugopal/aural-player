/*
    Initializes the app, alongside AppDelegate. Takes care of configuring logging, loading all app state from disk, and constructing the critical high level objects in the app's object tree - player, playlist, playerDelegate.
 */

import Foundation

class ObjectGraph {
    
    private static var appState: AppState?
    private static var uiAppState: UIAppState?
    private static var preferences: Preferences?
    
    private static var playlist: Playlist?
    private static var playlistDelegate: PlaylistDelegateProtocol?
    
    private static var audioGraph: AudioGraph?
    private static var audioGraphDelegate: AudioGraphDelegateProtocol?
    
    private static var player: Player?
    private static var playbackSequence: PlaybackSequence?
    private static var playbackDelegate: PlaybackDelegate?
    
    private static var recorder: Recorder?
    private static var recorderDelegate: RecorderDelegateProtocol?
    
    private static var initialized: Bool = false
    
    // Make sure all logging is done to the app's log file
    private static func configureLogging() {
        
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = allPaths.first!
        let pathForLog = documentsDirectory + ("/" + AppConstants.logFileName)
        
        freopen(pathForLog.cString(using: String.Encoding.ascii)!, "a+", stderr)
    }
    
    static func initialize() {
        
        configureLogging()
        
        // Load saved player state from app config file, and initialize the player with that state
        appState = AppStateIO.load()
        
        if (appState == nil) {
            appState = AppState.defaults
        }
        
        preferences = Preferences.instance()
        
        uiAppState = UIAppState(appState!, preferences!)
        
        // Audio Graph
        
        audioGraph = AudioGraph(appState!.audioGraphState)
        if (preferences!.volumeOnStartup == .specific) {
            audioGraph?.setVolume(preferences!.startupVolumeValue)
            audioGraph?.unmute()
        }
        
        // Audio Graph Delegate
        audioGraphDelegate = AudioGraphDelegate(audioGraph!, preferences!)
        
        // Player
        player = Player(audioGraph!)
        
        // Playlist
        playlist = Playlist()
        
        // Playback Sequence
        let repeatMode = appState!.playlistState.repeatMode
        let shuffleMode = appState!.playlistState.shuffleMode
        playbackSequence = PlaybackSequence(0, repeatMode, shuffleMode)
        
        // Playback Delegate
        playbackDelegate = PlaybackDelegate(player!, playbackSequence!, playlist!, preferences!)

        // Playlist Delegate
        let accessor = PlaylistAccessorDelegate(playlist!)
        let mutator = PlaylistMutatorDelegate(playlist!, playbackSequence!, playbackDelegate!, appState!.playlistState, preferences!)
        playlistDelegate = PlaylistDelegate(accessor, mutator)
        
        
        
        // Recorder and Recorder Delegate
        recorder = Recorder(audioGraph!)
        recorderDelegate = RecorderDelegate(recorder!)
        
        initialized = true
    }
    
    static func getAppState() -> AppState {
        
        if (!initialized) {
            initialize()
        }
        
        return appState!
    }
    
    static func getUIAppState() -> UIAppState {
        
        if (!initialized) {
            initialize()
        }
        
        return uiAppState!
    }
    
    static func getPreferences() -> Preferences {
        
        if (!initialized) {
            initialize()
        }
        
        return preferences!
    }
    
    static func getPlaylistAccessor() -> PlaylistAccessorProtocol {
        
        if (!initialized) {
            initialize()
        }
        
        return playlist!
    }
    
    static func getPlaylistDelegate() -> PlaylistDelegateProtocol {
        
        if (!initialized) {
            initialize()
        }
        
        return playlistDelegate!
    }
    
    static func getAudioGraphDelegate() -> AudioGraphDelegateProtocol {
        
        if (!initialized) {
            initialize()
        }
        
        return audioGraphDelegate!
    }
    
    static func getPlaybackDelegate() -> PlaybackDelegateProtocol {
        
        if (!initialized) {
            initialize()
        }
        
        return playbackDelegate!
    }
    
    static func getPlaybackInfoDelegate() -> PlaybackInfoDelegateProtocol {
        return getPlaybackDelegate()
    }
    
    static func getRecorderDelegate() -> RecorderDelegateProtocol {
        
        if (!initialized) {
            initialize()
        }
        
        return recorderDelegate!
    }
    
    // Called when app exits
    static func tearDown() {
        
        audioGraph?.tearDown()
        
        appState?.audioGraphState = audioGraph!.getPersistentState()
        appState?.playlistState = playlist!.persistentState()
        
        let uiState = UIState()
        uiState.windowLocationX = Float(WindowState.location().x)
        uiState.windowLocationY = Float(WindowState.location().y)
        uiState.showEffects = WindowState.showingEffects
        uiState.showPlaylist = WindowState.showingPlaylist
        
        appState?.uiState = uiState
        
        AppStateIO.save(appState!)
    }
}
