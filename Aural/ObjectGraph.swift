/*
    Takes care of loading all persistent app state from disk, and constructing the critical objects in the app's object tree - player, playlist, audio graph (i.e., "the back end"), and all delegates (middlemen/facades) for interaction between the UI and the "back end".
 */

import Foundation

class ObjectGraph {
    
    private static var appState: AppState?
    private static var uiAppState: UIAppState?
    private static var preferences: Preferences?
    
    private static var preferencesDelegate: PreferencesDelegate?
    
    private static var playlist: Playlist?
    private static var playlistDelegate: PlaylistDelegate?
    
    private static var audioGraph: AudioGraph?
    private static var audioGraphDelegate: AudioGraphDelegate?
    
    private static var player: Player?
    private static var playbackSequencer: PlaybackSequencer?
    private static var playbackSequencerInfoDelegate: PlaybackSequencerInfoDelegate?
    private static var playbackDelegate: PlaybackDelegate?
    
    private static var recorder: Recorder?
    private static var recorderDelegate: RecorderDelegate?
    
    private static var history: History?
    private static var historyDelegate: HistoryDelegate?
    
    private static var bookmarks: Bookmarks?
    private static var bookmarksDelegate: BookmarksDelegate?
    
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
        
        // Audio Graph (and delegate)
        audioGraph = AudioGraph(appState!.audioGraphState)
        audioGraphDelegate = AudioGraphDelegate(audioGraph!, preferences!.soundPreferences)
        
        // Player
        player = Player(audioGraph!)
        
        // Playlist
        let flatPlaylist = FlatPlaylist()
        let artistsPlaylist = GroupingPlaylist(.artists, .artist)
        let albumsPlaylist = GroupingPlaylist(.albums, .album)
        let genresPlaylist = GroupingPlaylist(.genres, .genre)
        
        playlist = Playlist(flatPlaylist, [artistsPlaylist, albumsPlaylist, genresPlaylist])
        
        // Playback Sequencer and delegate
        let repeatMode = appState!.playbackSequenceState.repeatMode
        let shuffleMode = appState!.playbackSequenceState.shuffleMode
        playbackSequencer = PlaybackSequencer(playlist!, repeatMode, shuffleMode)
        
        playbackSequencerInfoDelegate = PlaybackSequencerInfoDelegate(playbackSequencer!)
        
        // Playback Delegate
        playbackDelegate = PlaybackDelegate(player!, playbackSequencer!, playlist!, preferences!.playbackPreferences)

        // Playlist Delegate
        let accessor = PlaylistAccessorDelegate(playlist!)
        
        let changeListeners: [PlaylistChangeListenerProtocol] = [playbackSequencer!, playbackDelegate!]
        let mutator = PlaylistMutatorDelegate(playlist!, playbackSequencer!, playbackDelegate!, appState!.playlistState, preferences!, changeListeners)
        
        playlistDelegate = PlaylistDelegate(accessor, mutator)
        
        // Recorder (and delegate)
        recorder = Recorder(audioGraph!)
        recorderDelegate = RecorderDelegate(recorder!)
        
        // History (and delegate)
        history = History(preferences!.historyPreferences)
        historyDelegate = HistoryDelegate(history!, playlistDelegate!, playbackDelegate!, appState!.historyState)
        
        bookmarks = Bookmarks()
        bookmarksDelegate = BookmarksDelegate(bookmarks!, playlistDelegate!, playbackDelegate!)
    }
    
    // MARK: Accessor methods to retrieve objects
    
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
    
    static func getPlaylistAccessorDelegate() -> PlaylistAccessorDelegateProtocol {
        return playlistDelegate!
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
    
    static func getPlaybackSequencerInfoDelegate() -> PlaybackSequencerInfoDelegateProtocol {
        return playbackSequencerInfoDelegate!
    }
    
    static func getRecorderDelegate() -> RecorderDelegateProtocol {
        return recorderDelegate!
    }
    
    static func getHistoryDelegate() -> HistoryDelegateProtocol {
        return historyDelegate!
    }
    
    static func getBookmarksDelegate() -> BookmarksDelegateProtocol {
        return bookmarksDelegate!
    }
    
    // Called when app exits
    static func tearDown() {
    
        // Tear down the audio engine
        audioGraph?.tearDown()
        
        // Gather all pieces of app state into the appState object
        
        appState?.audioGraphState = audioGraph!.persistentState() as! AudioGraphState
        appState?.playlistState = playlist!.persistentState() as! PlaylistState
        appState?.playbackSequenceState = playbackSequencer!.persistentState() as! PlaybackSequenceState
        appState?.uiState = WindowState.persistentState()
        appState?.historyState = historyDelegate!.persistentState() as! HistoryState
        
        // Persist app state to disk
        AppStateIO.save(appState!)
    }
}
