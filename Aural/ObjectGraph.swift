/*
    Initializes the app, alongside AppDelegate. Takes care of configuring logging, loading all app state from disk, and constructing the critical high level objects in the app's object tree - player, playlist, playerDelegate.
 */

import Foundation

class ObjectGraph {
    
    private static var playerDelegate: PlayerDelegateProtocol?
    
    private static var playlistDelegate: PlaylistDelegateProtocol?
    
    private static var audioGraphDelegate: AudioGraphDelegateProtocol?
    
    private static var recorderDelegate: RecorderDelegateProtocol?
    
    private static var appState: AppState?
    
    private static var uiAppState: UIAppState?
    
    private static var preferences: Preferences?
    
    private static var audioGraph: AudioGraph?
    
    private static var player: Player?
    
    private static var recorder: Recorder?
    
    private static var playlist: Playlist?
    
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
        
        // Initialize the player
        preferences = Preferences.instance()
        
        uiAppState = UIAppState(appState!, preferences!)
        
        audioGraph = AudioGraph(appState!.audioGraphState)
        if (preferences!.volumeOnStartup == .specific) {
            audioGraph?.setVolume(preferences!.startupVolumeValue)
            audioGraph?.unmute()
        }
        
        audioGraphDelegate = AudioGraphDelegate(audioGraph!, preferences!)
        
        player = Player(audioGraph!)
        
        recorder = Recorder(audioGraph!)
        recorderDelegate = RecorderDelegate(recorder!)
        
        // Initialize playlist with playback sequence (repeat/shuffle) and track list
        let repeatMode = appState!.playlistState.repeatMode
        let shuffleMode = appState!.playlistState.shuffleMode
        
        playlist = Playlist(repeatMode, shuffleMode)
        
        // Initialize playerDelegate
        playerDelegate = PlayerAndPlaylistDelegate(playlist!, player!, appState!, preferences!)
        playlistDelegate = (playerDelegate as! PlaylistDelegateProtocol)
        
        initialized = true
    }
    
    static func getPlaylist() -> Playlist {
        
        if (!initialized) {
            initialize()
        }
        
        return playlist!
    }
    
    static func getPlaylistAccessor() -> PlaylistAccessor {
        return getPlaylist()
    }
    
    static func getPlayerDelegate() -> PlayerDelegateProtocol {
        
        if (!initialized) {
            initialize()
        }
        
        return playerDelegate!
    }
    
    static func getPlaylistDelegate() -> PlaylistDelegateProtocol {
        
        if (!initialized) {
            initialize()
        }
        
        return playlistDelegate!
    }
    
    static func getRecorderDelegate() -> RecorderDelegateProtocol {
        
        if (!initialized) {
            initialize()
        }
        
        return recorderDelegate!
    }
    
    static func getAudioGraphDelegate() -> AudioGraphDelegateProtocol {
        
        if (!initialized) {
            initialize()
        }
        
        return audioGraphDelegate!
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

    // Called when app exits
    static func tearDown() {
        
        audioGraph?.tearDown()
        
        appState?.audioGraphState = audioGraph!.getPersistentState()
        appState?.playlistState = playlist!.getState()
        
        let uiState = UIState()
        uiState.windowLocationX = Float(WindowState.location().x)
        uiState.windowLocationY = Float(WindowState.location().y)
        uiState.showEffects = WindowState.showingEffects
        uiState.showPlaylist = WindowState.showingPlaylist
        
        appState?.uiState = uiState
        
        AppStateIO.save(appState!)
    }
}
