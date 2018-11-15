/*
    Takes care of loading all persistent app state from disk, and constructing the critical objects in the app's object tree - player, playlist, audio graph (i.e., "the back end"), and all delegates (middlemen/facades) for interaction between the UI and the "back end".
 */

import Foundation

class ObjectGraph {
    
    static var appState: AppState!
    static var preferences: Preferences!
    
    static var preferencesDelegate: PreferencesDelegate!
    
    private static var playlist: PlaylistCRUDProtocol!
    static var playlistAccessor: PlaylistAccessorProtocol {return playlist}
    
    static var playlistDelegate: PlaylistDelegateProtocol!
    static var playlistAccessorDelegate: PlaylistAccessorDelegateProtocol {return playlistDelegate}
    
    private static var audioGraph: AudioGraphProtocol!
    static var audioGraphDelegate: AudioGraphDelegateProtocol!
    
    private static var player: PlayerProtocol!
    private static var playbackSequencer: PlaybackSequencerProtocol!
    
    static var playbackSequencerInfoDelegate: PlaybackSequencerInfoDelegateProtocol!
    static var playbackDelegate: PlaybackDelegateProtocol!
    static var playbackInfoDelegate: PlaybackInfoDelegateProtocol {return playbackDelegate}
    
    private static var recorder: Recorder!
    static var recorderDelegate: RecorderDelegateProtocol!
    
    private static var history: History!
    static var historyDelegate: HistoryDelegateProtocol!
    
    private static var favorites: Favorites!
    static var favoritesDelegate: FavoritesDelegateProtocol!
    
    private static var bookmarks: Bookmarks!
    static var bookmarksDelegate: BookmarksDelegateProtocol!
    
    static var layoutManager: LayoutManager!
    
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
        preferencesDelegate = PreferencesDelegate(preferences)
        
        // Audio Graph (and delegate)
        audioGraph = AudioGraph(appState.audioGraphState)
        
        // Player
        player = Player(audioGraph)
        
        // Playlist
        let flatPlaylist = FlatPlaylist()
        let artistsPlaylist = GroupingPlaylist(.artists, .artist)
        let albumsPlaylist = GroupingPlaylist(.albums, .album)
        let genresPlaylist = GroupingPlaylist(.genres, .genre)
        
        playlist = Playlist(flatPlaylist, [artistsPlaylist, albumsPlaylist, genresPlaylist])
        
        // Playback Sequencer and delegate
        let repeatMode = appState.playbackSequenceState.repeatMode
        let shuffleMode = appState.playbackSequenceState.shuffleMode
        playbackSequencer = PlaybackSequencer(playlist, repeatMode, shuffleMode)
        
        playbackSequencerInfoDelegate = PlaybackSequencerInfoDelegate(playbackSequencer)
        
        // Playback Delegate
        playbackDelegate = PlaybackDelegate(appState.playbackProfilesState, player, playbackSequencer, playlist, preferences.playbackPreferences)
        
        audioGraphDelegate = AudioGraphDelegate(audioGraph, playbackDelegate, preferences.soundPreferences)
        
        // History (and delegate)
        history = History(preferences.historyPreferences)
        
        // Playlist Delegate
        let accessor = PlaylistAccessorDelegate(playlist)
        
        let changeListeners: [PlaylistChangeListenerProtocol] = [playbackSequencer as! PlaybackSequencer, playbackDelegate as! PlaybackDelegate]
        let mutator = PlaylistMutatorDelegate(playlist, playbackSequencer, playbackDelegate, appState.playlistState, preferences, changeListeners)
        
        playlistDelegate = PlaylistDelegate(accessor, mutator)
        
        // Recorder (and delegate)
        recorder = Recorder(audioGraph)
        recorderDelegate = RecorderDelegate(recorder)
        
        historyDelegate = HistoryDelegate(history, playlistDelegate, playbackDelegate, appState.historyState)
        
        bookmarks = Bookmarks()
        bookmarksDelegate = BookmarksDelegate(bookmarks, playlistDelegate, playbackDelegate, appState.bookmarksState)
        
        favorites = Favorites()
        favoritesDelegate = FavoritesDelegate(favorites, playlistDelegate, playbackDelegate, appState.favoritesState)
        
        WindowLayouts.loadUserDefinedLayouts(appState.uiState.windowLayoutState.userWindowLayouts)
        
        layoutManager = LayoutManager(appState.uiState.windowLayoutState, preferences.viewPreferences)
    }
    
    // Called when app exits
    static func tearDown() {
        
        // Gather all pieces of app state into the appState object
        
        appState.audioGraphState = (audioGraph as! AudioGraph).persistentState() as! AudioGraphState
        appState.playlistState = (playlist as! Playlist).persistentState() as! PlaylistState
        appState.playbackSequenceState = (playbackSequencer as! PlaybackSequencer).persistentState() as! PlaybackSequenceState
        appState.playbackProfilesState.profiles = playbackDelegate.profiles.all()
        
        appState.uiState = UIState()
        appState.uiState.windowLayoutState = layoutManager.persistentState()
        appState.uiState.playerState = PlayerViewState.persistentState()
        
        appState.historyState = (historyDelegate as! HistoryDelegate).persistentState() as! HistoryState
        appState.favoritesState = (favoritesDelegate as! FavoritesDelegate).persistentState() as! FavoritesState
        appState.bookmarksState = (bookmarksDelegate as! BookmarksDelegate).persistentState() as! BookmarksState
        
        // Persist app state to disk
        AppStateIO.save(appState!)
        
        // Tear down the audio engine
        player.tearDown()
        audioGraph.tearDown()
    }
}
