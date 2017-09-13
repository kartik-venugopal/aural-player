/*
    Initializes the app, alongside AppDelegate. Takes care of configuring logging, loading all app state from disk, and constructing the critical high level objects in the app's object tree - player, playlist, playerDelegate.
 */

import Foundation

class ObjectGraph {
    
    private static var appState: AppState?
    private static var uiAppState: UIAppState?
    private static var preferences: Preferences?
    
    private static var preferencesDelegate: PreferencesDelegateProtocol?
    
    private static var playlist: Playlist?
    private static var playlistDelegate: PlaylistDelegateProtocol?
    
    private static var audioGraph: AudioGraph?
    private static var audioGraphDelegate: AudioGraphDelegateProtocol?
    
    private static var player: Player?
    private static var playbackSequence: PlaybackSequence?
    private static var playbackDelegate: PlaybackDelegate?
    
    private static var recorder: Recorder?
    private static var recorderDelegate: RecorderDelegateProtocol?
    
    // Don't let any code invoke this initializer to create instances of ObjectGraph
    private init() {}
    
    static func initialize() {
        
        // Load saved player state from app config file, and initialize the player with that state
        appState = AppStateIO.load()
        
        if (appState == nil) {
            appState = AppState.defaults
        }
        
        preferences = Preferences.instance()
        preferencesDelegate = PreferencesDelegate(preferences!)
        
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
        let repeatMode = appState!.playbackSequenceState.repeatMode
        let shuffleMode = appState!.playbackSequenceState.shuffleMode
        playbackSequence = PlaybackSequence(0, repeatMode, shuffleMode)
        
        // Playback Delegate
        playbackDelegate = PlaybackDelegate(player!, playbackSequence!, playlist!, preferences!)

        // Playlist Delegate
        let accessor = PlaylistAccessorDelegate(playlist!)
        
        let changeListeners: [PlaylistChangeListener] = [playbackSequence!, playbackDelegate!]
        let mutator = PlaylistMutatorDelegate(playlist!, playbackSequence!, playbackDelegate!, appState!.playlistState, preferences!, changeListeners)
        
        playlistDelegate = PlaylistDelegate(accessor, mutator)
        
        // Recorder and Recorder Delegate
        recorder = Recorder(audioGraph!)
        recorderDelegate = RecorderDelegate(recorder!)
    }
    
    static func getAppState() -> AppState {
        return appState!
    }
    
    static func getUIAppState() -> UIAppState {
        return uiAppState!
    }
    
    static func getPreferencesDelegate() -> PreferencesDelegateProtocol {
        return preferencesDelegate!
    }
    
    static func getPlaylistAccessor() -> PlaylistAccessorProtocol {
        return playlist!
    }
    
    static func getPlaylistDelegate() -> PlaylistDelegateProtocol {
        return playlistDelegate!
    }
    
    static func getAudioGraphDelegate() -> AudioGraphDelegateProtocol {
        return audioGraphDelegate!
    }
    
    static func getPlaybackDelegate() -> PlaybackDelegateProtocol {
        return playbackDelegate!
    }
    
    static func getPlaybackInfoDelegate() -> PlaybackInfoDelegateProtocol {
        return getPlaybackDelegate()
    }
    
    static func getRecorderDelegate() -> RecorderDelegateProtocol {
        return recorderDelegate!
    }
    
    // Called when app exits
    static func tearDown() {
        
        audioGraph?.tearDown()
        
        appState?.audioGraphState = audioGraph!.getPersistentState()
        appState?.playlistState = playlist!.persistentState()
        appState?.playbackSequenceState = playbackSequence!.getPersistentState()
        
        let uiState = UIState()
        uiState.windowLocationX = Float(WindowState.location().x)
        uiState.windowLocationY = Float(WindowState.location().y)
        uiState.showEffects = WindowState.showingEffects
        uiState.showPlaylist = WindowState.showingPlaylist
        
        appState?.uiState = uiState
        
        AppStateIO.save(appState!)
    }
}
