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
    
    static var windowManager: WindowManagerProtocol!
    
    static var transcoder: TranscoderProtocol!
    static var muxer: MuxerProtocol!
    
    static var commonAVAssetParser: CommonAVAssetParser!
    static var id3Parser: ID3Parser!
    static var iTunesParser: ITunesParser!
    static var audioToolboxParser: AudioToolboxParser!
    
    static var commonFFMpegParser: CommonFFMpegMetadataParser!
    static var wmParser: WMParser!
    static var vorbisParser: VorbisCommentParser!
    static var apeParser: ApeV2Parser!
    static var defaultParser: DefaultFFMpegMetadataParser!
    
    static var mediaKeyHandler: MediaKeyHandler!
    
    // Don't let any code invoke this initializer to create instances of ObjectGraph
    private init() {}
    
    // Performs all necessary object initialization
    static func initialize() {
        
        // Load persistent app state from disk
        // Use defaults if app state could not be loaded from disk
        appState = AppStateIO.load() ?? AppState.defaults
        
        // Preferences (and delegate)
        preferences = Preferences.instance
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
        
        // History (and delegate)
        history = History(preferences.historyPreferences)
        
        transcoder = Transcoder(appState.transcoder, preferences.playbackPreferences.transcodingPreferences)
        
        // Playback Delegate
        playbackDelegate = PlaybackDelegate(appState.playbackProfiles, player, playbackSequencer, playlist, transcoder, preferences.playbackPreferences)
        
        audioGraphDelegate = AudioGraphDelegate(audioGraph, playbackDelegate, preferences.soundPreferences, appState.audioGraph)
        
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
        favoritesDelegate = FavoritesDelegate(favorites, playlistDelegate, playbackDelegate, appState!.favorites)
        
        windowManager = WindowManager(appState.ui.windowLayout, preferences.viewPreferences)
        WindowLayouts.loadUserDefinedLayouts(appState.ui.windowLayout.userLayouts)
        
        PlayerViewState.initialize(appState.ui.player)
        PlaylistViewState.initialize(appState.ui.playlist)
        EffectsViewState.initialize(appState.ui.effects)
        ColorSchemes.initialize(appState.ui.colorSchemes)
        
        muxer = Muxer()
        
        commonAVAssetParser = CommonAVAssetParser()
        id3Parser = ID3Parser()
        iTunesParser = ITunesParser()
        audioToolboxParser = AudioToolboxParser()
        
        commonFFMpegParser = CommonFFMpegMetadataParser()
        wmParser = WMParser()
        vorbisParser = VorbisCommentParser()
        apeParser = ApeV2Parser()
        defaultParser = DefaultFFMpegMetadataParser()
        
        mediaKeyHandler = MediaKeyHandler()
    }
    
    // Called when app exits
    static func tearDown() {
        
        // Gather all pieces of app state into the appState object
        
        appState.audioGraph = (audioGraph as! AudioGraph).persistentState as! AudioGraphState
        appState.playlist = (playlist as! Playlist).persistentState as! PlaylistState
        appState.playbackSequence = (playbackSequencer as! PlaybackSequencer).persistentState as! PlaybackSequenceState
        appState.playbackProfiles = playbackDelegate.profiles.all()
        
        appState.transcoder = (transcoder as! Transcoder).persistentState as! TranscoderState
        
        appState.ui = UIState()
        appState.ui.windowLayout = (windowManager as! WindowManager).persistentState
        appState.ui.colorSchemes = ColorSchemes.persistentState
        appState.ui.player = PlayerViewState.persistentState
        appState.ui.playlist = PlaylistViewState.persistentState
        appState.ui.effects = EffectsViewState.persistentState
        
        appState.history = (historyDelegate as! HistoryDelegate).persistentState as! HistoryState
        appState.favorites = (favoritesDelegate as! FavoritesDelegate).persistentState
        appState.bookmarks = (bookmarksDelegate as! BookmarksDelegate).persistentState
        
        // Persist app state to disk
        AppStateIO.save(appState!)
        
        // Tear down the audio engine
        player.tearDown()
        audioGraph.tearDown()
    }
}
