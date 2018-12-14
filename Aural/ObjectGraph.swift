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
    
    static var pTypes: Set<String> = Set<String>()
    static var types: Set<String> = Set<String>()
    static var map: [String: String] = [:]
    static var map2: [String: Int] = [:]
    
    private static func mirror(_ label: String, _ obj: Any) {
        
        let mir = Mirror(reflecting: obj)
        map[String(describing: mir.subjectType)] = String(describing: mir.displayStyle)
        map2[String(describing: mir.subjectType)] = mir.children.count
        
        if mir.allChildren().count == 0 {
//        if mir.allChildren().count == 0 && mir.displayStyle != .collection && mir.displayStyle != .dictionary {
            pTypes.insert(String(describing: mir.subjectType))
        }
        
        for ch in mir.children {
            mirror(ch.label ?? "<NO-LABEL>", ch.value)
        }
    }
    
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
        audioGraph = AudioGraph(appState.audioGraph)
        
        // Player
        player = Player(audioGraph)
        
        // Playlist
        let flatPlaylist = FlatPlaylist()
        let artistsPlaylist = GroupingPlaylist(.artists, .artist)
        let albumsPlaylist = GroupingPlaylist(.albums, .album)
        let genresPlaylist = GroupingPlaylist(.genres, .genre)
        
        playlist = Playlist(flatPlaylist, [artistsPlaylist, albumsPlaylist, genresPlaylist])
        
        // Playback Sequencer and delegate
        let repeatMode = appState.playbackSequence.repeatMode
        let shuffleMode = appState.playbackSequence.shuffleMode
        playbackSequencer = PlaybackSequencer(playlist, repeatMode, shuffleMode)
        
        playbackSequencerInfoDelegate = PlaybackSequencerInfoDelegate(playbackSequencer)
        
        // Playback Delegate
        playbackDelegate = PlaybackDelegate(appState.playbackProfiles, player, playbackSequencer, playlist, preferences.playbackPreferences)
        
        audioGraphDelegate = AudioGraphDelegate(audioGraph, playbackDelegate, preferences.soundPreferences)
        
        // History (and delegate)
        history = History(preferences.historyPreferences)
        
        // Playlist Delegate
        let accessor = PlaylistAccessorDelegate(playlist)
        
        let changeListeners: [PlaylistChangeListenerProtocol] = [playbackSequencer as! PlaybackSequencer, playbackDelegate as! PlaybackDelegate]
        let mutator = PlaylistMutatorDelegate(playlist, playbackSequencer, playbackDelegate, appState.playlist, preferences, changeListeners)
        
        playlistDelegate = PlaylistDelegate(accessor, mutator)
        
        // Recorder (and delegate)
        recorder = Recorder(audioGraph)
        recorderDelegate = RecorderDelegate(recorder)
        
        historyDelegate = HistoryDelegate(history, playlistDelegate, playbackDelegate, appState.history)
        
        bookmarks = Bookmarks()
        bookmarksDelegate = BookmarksDelegate(bookmarks, playlistDelegate, playbackDelegate, appState.bookmarks)
        
        favorites = Favorites()
        favoritesDelegate = FavoritesDelegate(favorites, playlistDelegate, playbackDelegate, appState.favorites)
        
        WindowLayouts.loadUserDefinedLayouts(appState.ui.windowLayout.userLayouts)
        
        layoutManager = LayoutManager(appState.ui.windowLayout, preferences.viewPreferences)
        
        Transcoder.initializeStore(appState.transcoder)
    }
    
    // Called when app exits
    static func tearDown() {
        
        // Gather all pieces of app state into the appState object
        
        appState.audioGraph = (audioGraph as! AudioGraph).persistentState() as! AudioGraphState
        appState.playlist = (playlist as! Playlist).persistentState() as! PlaylistState
        appState.playbackSequence = (playbackSequencer as! PlaybackSequencer).persistentState() as! PlaybackSequenceState
        appState.playbackProfiles = playbackDelegate.profiles.all()
        
        appState.transcoder = TranscoderState()
        appState.transcoder.entries = Transcoder.store.map
        
        appState.ui = UIState()
        appState.ui.windowLayout = layoutManager.persistentState()
        appState.ui.player = PlayerViewState.persistentState()
        
        appState.history = (historyDelegate as! HistoryDelegate).persistentState() as! HistoryState
        appState.favorites = (favoritesDelegate as! FavoritesDelegate).persistentState()
        appState.bookmarks = (bookmarksDelegate as! BookmarksDelegate).persistentState()
        
        // Persist app state to disk
        AppStateIO.save(appState!)
        
        // Tear down the audio engine
        player.tearDown()
        audioGraph.tearDown()
    }
}
