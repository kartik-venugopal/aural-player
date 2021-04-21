/*
    Takes care of loading all persistent app state from disk, and constructing the critical objects in the app's object tree - player, playlist, audio graph (i.e., "the back end"), and all delegates (middlemen/facades) for interaction between the UI and the "back end".
 */

import Foundation

class ObjectGraph {
    
    // TODO: Make these vars lazily loaded
    
    static var lastPresentedAppMode: AppMode!
    
    static var preferences: Preferences!
    
    static var preferencesDelegate: PreferencesDelegate!
    
    private static var playlist: PlaylistCRUDProtocol!
    
    static var playlistDelegate: PlaylistDelegateProtocol!
    static var playlistAccessorDelegate: PlaylistAccessorDelegateProtocol! {return playlistDelegate}
    
    private static var audioGraph: AudioGraphProtocol!
    static var audioGraphDelegate: AudioGraphDelegateProtocol!
    
    private static var player: PlayerProtocol!
    private static var avfScheduler: PlaybackSchedulerProtocol!
    private static var ffmpegScheduler: PlaybackSchedulerProtocol!
    private static var sequencer: SequencerProtocol!
    
    static var sampleConverter: SampleConverterProtocol!
    
    static var sequencerDelegate: SequencerDelegateProtocol!
    static var sequencerInfoDelegate: SequencerInfoDelegateProtocol! {return sequencerDelegate}
    
    static var playbackDelegate: PlaybackDelegateProtocol!
    static var playbackInfoDelegate: PlaybackInfoDelegateProtocol! {return playbackDelegate}
    
    private static var recorder: Recorder!
    static var recorderDelegate: RecorderDelegateProtocol!
    
    private static var history: History!
    static var historyDelegate: HistoryDelegateProtocol!
    
    private static var favorites: Favorites!
    static var favoritesDelegate: FavoritesDelegateProtocol!
    
    private static var bookmarks: Bookmarks!
    static var bookmarksDelegate: BookmarksDelegateProtocol!
    
    static var fileReader: FileReader!
    static var trackReader: TrackReader!
    
    static var mediaKeyHandler: MediaKeyHandler!
    
    static var coverArtReader: CoverArtReader!
    static var fileCoverArtReader: FileCoverArtReader!
    static var musicBrainzCoverArtReader: MusicBrainzCoverArtReader!
    
    static var musicBrainzCache: MusicBrainzCache!
    
    static var audioUnitsManager: AudioUnitsManager!
    
    static var fft: FFT!
    
    // Don't let any code invoke this initializer to create instances of ObjectGraph
    private init() {}
    
    // Performs all necessary object initialization
    static func initialize() {
        
        // Load persistent app state from disk
        // Use defaults if app state could not be loaded from disk
        let persistentState: PersistentAppState = AppStateIO.load() ?? PersistentAppState.defaults
        
        lastPresentedAppMode = AppMode(rawValue: persistentState.ui.appMode) ?? AppDefaults.appMode
        
        // Preferences (and delegate)
        preferences = Preferences.instance
        preferencesDelegate = PreferencesDelegate(preferences)
        
        audioUnitsManager = AudioUnitsManager()
        
        // Audio Graph (and delegate)
        audioGraph = AudioGraph(audioUnitsManager, persistentState.audioGraph)
        
        // The new scheduler uses an AVFoundation API that is only available with macOS >= 10.13.
        // Instantiate the legacy scheduler if running on 10.12 Sierra or older systems.
        if #available(macOS 10.13, *) {
            avfScheduler = PlaybackScheduler(audioGraph.playerNode)
        } else {
            avfScheduler = LegacyPlaybackScheduler(audioGraph.playerNode)
        }
        
        sampleConverter = FFmpegSampleConverter()
        ffmpegScheduler = FFmpegScheduler(playerNode: audioGraph.playerNode, sampleConverter: sampleConverter)
        
        // Player
        player = Player(graph: audioGraph, avfScheduler: avfScheduler, ffmpegScheduler: ffmpegScheduler)
        
        // Playlist
        let flatPlaylist = FlatPlaylist()
        let artistsPlaylist = GroupingPlaylist(.artists)
        let albumsPlaylist = GroupingPlaylist(.albums)
        let genresPlaylist = GroupingPlaylist(.genres)
        
        playlist = Playlist(flatPlaylist, [artistsPlaylist, albumsPlaylist, genresPlaylist])
        
        // Sequencer and delegate
        let repeatMode = persistentState.playbackSequence.repeatMode
        let shuffleMode = persistentState.playbackSequence.shuffleMode
        let playlistType = PlaylistType(rawValue: persistentState.ui.playlist.view.lowercased()) ?? .tracks
        
        sequencer = Sequencer(playlist, repeatMode, shuffleMode, playlistType)
        sequencerDelegate = SequencerDelegate(sequencer)
        
        fileReader = FileReader()
        fileCoverArtReader = FileCoverArtReader(fileReader)
        
        musicBrainzCache = MusicBrainzCache(state: persistentState.musicBrainzCache, preferences: preferences.metadataPreferences.musicBrainz)
        musicBrainzCoverArtReader = MusicBrainzCoverArtReader(state: persistentState.musicBrainzCache, preferences: preferences.metadataPreferences.musicBrainz, cache: musicBrainzCache)
        
        coverArtReader = CoverArtReader(fileCoverArtReader, musicBrainzCoverArtReader)
        
        trackReader = TrackReader(fileReader, coverArtReader)
        
        let profiles = PlaybackProfiles()
        
        for profile in persistentState.playbackProfiles {
            profiles.add(profile.file, profile)
        }
        
        let startPlaybackChain = StartPlaybackChain(player, sequencer, playlist, trackReader: trackReader, profiles, preferences.playbackPreferences)
        let stopPlaybackChain = StopPlaybackChain(player, playlist, sequencer, profiles, preferences.playbackPreferences)
        let trackPlaybackCompletedChain = TrackPlaybackCompletedChain(startPlaybackChain, stopPlaybackChain, sequencer)
        
        // Playback Delegate
        playbackDelegate = PlaybackDelegate(player, playlist, sequencer, profiles, preferences.playbackPreferences, startPlaybackChain, stopPlaybackChain, trackPlaybackCompletedChain)
        
        audioGraphDelegate = AudioGraphDelegate(audioGraph, playbackDelegate, preferences.soundPreferences, persistentState.audioGraph)
        
        // Playlist Delegate
        playlistDelegate = PlaylistDelegate(playlist, trackReader, persistentState.playlist, preferences,
                                            [playbackDelegate as! PlaybackDelegate])
        
        // Recorder (and delegate)
        recorder = Recorder(audioGraph)
        recorderDelegate = RecorderDelegate(recorder)
        
        // History (and delegate)
        history = History(preferences.historyPreferences)
        historyDelegate = HistoryDelegate(history, playlistDelegate, playbackDelegate, persistentState.history)
        
        bookmarks = Bookmarks()
        bookmarksDelegate = BookmarksDelegate(bookmarks, playlistDelegate, playbackDelegate, persistentState.bookmarks)
        
        favorites = Favorites()
        favoritesDelegate = FavoritesDelegate(favorites, playlistDelegate, playbackDelegate, persistentState.favorites)
        
        mediaKeyHandler = MediaKeyHandler(preferences.controlsPreferences)
        
        // Initialize utility classes.
        
        PlaylistIO.initialize(playlist)
        
        // UI-related utility classes
        
        UIUtils.initialize(preferences.viewPreferences)
        
        Themes.initialize(persistentState.ui.themes)
        FontSchemes.initialize(persistentState.ui.fontSchemes)
        ColorSchemes.initialize(persistentState.ui.colorSchemes)
        
        WindowLayoutState.initialize(persistentState.ui.windowLayout)
        WindowLayouts.loadUserDefinedLayouts(persistentState.ui.windowLayout.userLayouts)
        
        PlayerViewState.initialize(persistentState.ui.player)
        PlaylistViewState.initialize(persistentState.ui.playlist)
        VisualizerViewState.initialize(persistentState.ui.visualizer)
        WindowAppearanceState.initialize(persistentState.ui.windowAppearance)
        MenuBarPlayerViewState.initialize(persistentState.ui.menuBarPlayer)
        
        fft = FFT()
        
        DispatchQueue.global(qos: .background).async {
            cleanUpTranscoderFolders()
        }
    }
    
    ///
    /// Clean up (delete) file system folders that were used by previous app versions that had the transcoder.
    ///
    private static func cleanUpTranscoderFolders() {
        
        let transcoderDir: URL = URL(fileURLWithPath: AppConstants.FilesAndPaths.baseDir.path).appendingPathComponent("transcoderStore", isDirectory: true)
        
        let artDir: URL = URL(fileURLWithPath: AppConstants.FilesAndPaths.baseDir.path).appendingPathComponent("albumArt", isDirectory: true)
        
        for folder in [transcoderDir, artDir].filter({FileSystemUtils.fileExists($0)}) {
            FileSystemUtils.deleteDir(folder)
        }
    }
    
    private static let tearDownOpQueue: OperationQueue = {

        let queue = OperationQueue()
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        queue.maxConcurrentOperationCount = 2
        
        return queue
    }()
    
    // Called when app exits
    static func tearDown() {
        
        // Gather all pieces of persistent state into the persistentState object
        let persistentState: PersistentAppState = PersistentAppState()
        
        persistentState.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        
        persistentState.audioGraph = (audioGraph as! AudioGraph).persistentState
        persistentState.playlist = (playlist as! Playlist).persistentState
        persistentState.playbackSequence = (sequencer as! Sequencer).persistentState
        persistentState.playbackProfiles = playbackDelegate.profiles.all()
        
        persistentState.ui = UIState()
        persistentState.ui.appMode = AppModeManager.mode.rawValue
        persistentState.ui.windowLayout = WindowLayoutState.persistentState
        persistentState.ui.themes = Themes.persistentState
        persistentState.ui.fontSchemes = FontSchemes.persistentState
        persistentState.ui.colorSchemes = ColorSchemes.persistentState
        persistentState.ui.player = PlayerViewState.persistentState
        persistentState.ui.playlist = PlaylistViewState.persistentState
        persistentState.ui.visualizer = VisualizerViewState.persistentState
        persistentState.ui.windowAppearance = WindowAppearanceState.persistentState
        persistentState.ui.menuBarPlayer = MenuBarPlayerViewState.persistentState
        
        persistentState.history = (historyDelegate as! HistoryDelegate).persistentState
        persistentState.favorites = (favoritesDelegate as! FavoritesDelegate).persistentState
        persistentState.bookmarks = (bookmarksDelegate as! BookmarksDelegate).persistentState
        persistentState.musicBrainzCache = musicBrainzCoverArtReader.cache.persistentState
        
        // App state persistence and shutting down the audio engine can be performed concurrently
        // on two background threads to save some time when exiting the app.
        
        // App state persistence to disk
        tearDownOpQueue.addOperation {
            AppStateIO.save(persistentState)
        }

        // Tear down the audio engine
        tearDownOpQueue.addOperation {
            player.tearDown()
            audioGraph.tearDown()
        }

        // Wait for all concurrent operations to finish executing.
        tearDownOpQueue.waitUntilAllOperationsAreFinished()
    }
}
