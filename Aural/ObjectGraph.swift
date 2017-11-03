/*
    Takes care of loading all persistent app state from disk, and constructing the critical objects in the app's object tree - player, playlist, audio graph (i.e., "the back end"), and all delegates (middlemen/facades) for interaction between the UI and the "back end".
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
    private static var playbackSequencer: PlaybackSequencer?
    private static var playbackDelegate: PlaybackDelegate?
    
    private static var recorder: Recorder?
    private static var recorderDelegate: RecorderDelegateProtocol?
    
    // Don't let any code invoke this initializer to create instances of ObjectGraph
    private init() {}
    
    // Performs all necessary object initialization
    static func initialize() {
        
        // Load persistent app state from disk
        appState = AppStateIO.load()
        
        // Use defaults if app state could not be loaded from disk
        if (appState == nil) {
            appState = AppState.defaults
        }
        
        // Preferences (and delegate)
        preferences = Preferences.instance()
        preferencesDelegate = PreferencesDelegate(preferences!)
        
        // State used for UI initialization
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
        
        let flatPlaylist = FlatPlaylist()
        let artistsPlaylist = GroupingPlaylist(.artist)
        let albumsPlaylist = GroupingPlaylist(.album)
        let genresPlaylist = GroupingPlaylist(.genre)
        
        // Playlist
        playlist = Playlist(flatPlaylist, [artistsPlaylist, albumsPlaylist, genresPlaylist])
        
        // Playback Sequence
        let repeatMode = appState!.playbackSequenceState.repeatMode
        let shuffleMode = appState!.playbackSequenceState.shuffleMode
        playbackSequencer = PlaybackSequencer(playlist!, repeatMode, shuffleMode)
        
        // Playback Delegate
        playbackDelegate = PlaybackDelegate(player!, playbackSequencer!, playlist!, preferences!)

        // Playlist Delegate
        let accessor = PlaylistAccessorDelegate(playlist!)
        
        let changeListeners: [PlaylistChangeListenerProtocol] = [playbackSequencer!, playbackDelegate!]
        let mutator = PlaylistMutatorDelegate(playlist!, playbackSequencer!, playbackDelegate!, appState!.playlistState, preferences!, changeListeners)
        
        playlistDelegate = PlaylistDelegate(accessor, mutator)
        
        // Recorder (and delegate)
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
    
        // Tear down the audio engine
        audioGraph?.tearDown()
        
        // Gather all pieces of app state into the appState object
        
        appState?.audioGraphState = audioGraph!.getPersistentState()
        appState?.playlistState = playlist!.persistentState()
        appState?.playbackSequenceState = playbackSequencer!.getPersistentState()
        appState?.uiState = WindowState.getPersistentState()
        
        // Persist app state to disk
        AppStateIO.save(appState!)
    }
}
