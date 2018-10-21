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
    
    private static var player: PlayerProtocol?
    private static var playbackSequencer: PlaybackSequencer?
    private static var playbackSequencerInfoDelegate: PlaybackSequencerInfoDelegate?
    private static var playbackDelegate: PlaybackDelegate?
    
    private static var recorder: Recorder?
    private static var recorderDelegate: RecorderDelegate?
    
    private static var history: History?
    private static var historyDelegate: HistoryDelegate?
    
    private static var favorites: Favorites?
    private static var favoritesDelegate: FavoritesDelegate?
    
    private static var bookmarks: Bookmarks?
    private static var bookmarksDelegate: BookmarksDelegate?
    
    private static var layoutManager: LayoutManager?
    
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
        
        // History (and delegate)
        history = History(preferences!.historyPreferences)
        
        // Playlist Delegate
        let accessor = PlaylistAccessorDelegate(playlist!)
        
        let changeListeners: [PlaylistChangeListenerProtocol] = [playbackSequencer!, playbackDelegate!]
        let mutator = PlaylistMutatorDelegate(playlist!, playbackSequencer!, playbackDelegate!, appState!.playlistState, preferences!, changeListeners)
        
        playlistDelegate = PlaylistDelegate(accessor, mutator)
        
        // Recorder (and delegate)
        recorder = Recorder(audioGraph!)
        recorderDelegate = RecorderDelegate(recorder!)
        
        historyDelegate = HistoryDelegate(history!, playlistDelegate!, playbackDelegate!, appState!.historyState)
        
        bookmarks = Bookmarks()
        bookmarksDelegate = BookmarksDelegate(bookmarks!, playlistDelegate!, playbackDelegate!, appState!.bookmarksState)
        
        favorites = Favorites()
        favoritesDelegate = FavoritesDelegate(favorites!, playlistDelegate!, playbackDelegate!, appState!.favoritesState)
        
        WindowLayouts.loadUserDefinedLayouts((appState?.uiState.windowLayoutState.userWindowLayouts)!)
        
        layoutManager = LayoutManager(appState!.uiState.windowLayoutState, preferences!.viewPreferences)
        
        // TODO: Who should own this initialization ???
        appState?.soundProfilesState.profiles.forEach({
            SoundProfiles.saveProfile($0.file, $0.volume, $0.balance, $0.effects)
        })
        
        appState?.playbackProfilesState.profiles.forEach({
            PlaybackProfiles.saveProfile($0.file, $0.lastPosition)
        })
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
    
    static func getFavoritesDelegate() -> FavoritesDelegateProtocol {
        return favoritesDelegate!
    }
    
    static func getBookmarksDelegate() -> BookmarksDelegateProtocol {
        return bookmarksDelegate!
    }
    
    static func getLayoutManager() -> LayoutManager {
        return layoutManager!
    }
    
    // Called when app exits
    static func tearDown() {
        
        // Gather all pieces of app state into the appState object
        
        appState?.audioGraphState = audioGraph!.persistentState() as! AudioGraphState
        appState?.playlistState = playlist!.persistentState() as! PlaylistState
        appState?.playbackSequenceState = playbackSequencer!.persistentState() as! PlaybackSequenceState
        
        appState?.uiState = UIState()
        appState?.uiState.windowLayoutState = layoutManager!.persistentState()
        appState?.uiState.playerState = PlayerViewState.persistentState()
        appState?.uiState.nowPlayingState = NowPlayingViewState.persistentState()
        
        appState?.historyState = historyDelegate!.persistentState() as! HistoryState
        appState?.favoritesState = favoritesDelegate!.persistentState() as! FavoritesState
        appState?.bookmarksState = bookmarksDelegate!.persistentState() as! BookmarksState
        appState?.soundProfilesState = SoundProfiles.getPersistentState()
        appState?.playbackProfilesState = PlaybackProfiles.getPersistentState()
        
        // Persist app state to disk
        AppStateIO.save(appState!)
        
        // Tear down the audio engine
        player?.tearDown()
        audioGraph?.tearDown()
    }
}
