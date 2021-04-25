/*
    Takes care of loading all persistent app state from disk, and constructing the critical objects in the app's object tree - player, playlist, audio graph (i.e., "the back end"), and all delegates (middlemen/facades) for interaction between the UI and the "back end".
 */

import Foundation

class ObjectGraph {
    
    static var lastPresentedAppMode: AppMode!
    
    static let preferences: Preferences = Preferences.instance
    
    private static let playlist: PlaylistCRUDProtocol = Playlist(FlatPlaylist(), [GroupingPlaylist(.artists), GroupingPlaylist(.albums), GroupingPlaylist(.genres)])
    
    static var playlistDelegate: PlaylistDelegateProtocol!
    static var playlistAccessorDelegate: PlaylistAccessorDelegateProtocol! {return playlistDelegate}
    
    static let audioUnitsManager: AudioUnitsManager = AudioUnitsManager()
    
    private static var audioGraph: AudioGraphProtocol!
    static var audioGraphDelegate: AudioGraphDelegateProtocol!
    
    private static var player: PlayerProtocol!
    private static var avfScheduler: PlaybackSchedulerProtocol!
    private static var ffmpegScheduler: PlaybackSchedulerProtocol!
    private static var sequencer: SequencerProtocol!
    
    static let sampleConverter: SampleConverterProtocol = FFmpegSampleConverter()
    
    static var sequencerDelegate: SequencerDelegateProtocol!
    static var sequencerInfoDelegate: SequencerInfoDelegateProtocol! {return sequencerDelegate}
    
    static var playbackDelegate: PlaybackDelegateProtocol!
    static var playbackInfoDelegate: PlaybackInfoDelegateProtocol! {return playbackDelegate}
    
    private static var recorder: Recorder!
    static var recorderDelegate: RecorderDelegateProtocol!
    
    static var historyDelegate: HistoryDelegateProtocol!
    static var favoritesDelegate: FavoritesDelegateProtocol!
    static var bookmarksDelegate: BookmarksDelegateProtocol!
    
    static let fileReader: FileReader = FileReader()
    static var trackReader: TrackReader!
    
    static var coverArtReader: CoverArtReader!
    static let fileCoverArtReader: FileCoverArtReader = FileCoverArtReader(fileReader)
    
    static var musicBrainzCache: MusicBrainzCache!
    static var musicBrainzCoverArtReader: MusicBrainzCoverArtReader!
    
    static let mediaKeyHandler: MediaKeyHandler = MediaKeyHandler(preferences.controlsPreferences)
    
    static let fileSystem: FileSystem = FileSystem()
    
    static let fft: FFT = FFT()
    
    // Don't let any code invoke this initializer to create instances of ObjectGraph
    private init() {}
    
    // Performs all necessary object initialization
    static func initialize() {
        
        // Load persistent app state from disk
        // Use defaults if app state could not be loaded from disk
        let persistentState: PersistentAppState = AppStateIO.load() ?? PersistentAppState.defaults
        
        lastPresentedAppMode = persistentState.ui?.appMode ?? AppDefaults.appMode
        
        initializeCoreModules(persistentState)
        
        initializeAuxiliaryModules(persistentState)
        
        initializeUtilities(persistentState)
        
        initializeUIPersistentState(persistentState)
        
        DispatchQueue.global(qos: .background).async {
            cleanUpTranscoderFolders()
        }
    }
    
    // Player, Audio Graph, and Playlist
    private static func initializeCoreModules(_ persistentState: PersistentAppState) {
        
        initializeAudioGraph(persistentState)
        initializePlayer(persistentState)
        initializeSequencer(persistentState)
        
        initializeCoreModuleDelegates(persistentState)
    }
    
    private static func initializeAudioGraph(_ persistentState: PersistentAppState) {
        
        audioGraph = AudioGraph(audioUnitsManager, persistentState.audioGraph)
        recorder = Recorder(audioGraph)
    }
    
    private static func initializePlayer(_ persistentState: PersistentAppState) {
        
        // The new scheduler uses an AVFoundation API that is only available with macOS >= 10.13.
        // Instantiate the legacy scheduler if running on 10.12 Sierra or older systems.
        if #available(macOS 10.13, *) {
            avfScheduler = PlaybackScheduler(audioGraph.playerNode)
        } else {
            avfScheduler = LegacyPlaybackScheduler(audioGraph.playerNode)
        }
        
        ffmpegScheduler = FFmpegScheduler(playerNode: audioGraph.playerNode, sampleConverter: sampleConverter)
        
        // Player
        player = Player(graph: audioGraph, avfScheduler: avfScheduler, ffmpegScheduler: ffmpegScheduler)
    }
    
    private static func initializeSequencer(_ persistentState: PersistentAppState) {
        
        // Sequencer and delegate
        let playlistType = persistentState.ui?.playlist?.view ?? .tracks
        sequencer = Sequencer(persistentState: persistentState.playbackSequence, playlist, playlistType)
    }
    
    private static func initializeCoreModuleDelegates(_ persistentState: PersistentAppState) {
        
        initializeTrackReader(persistentState)
        
        initializePlaybackDelegate(persistentState)
        sequencerDelegate = SequencerDelegate(sequencer)
        
        audioGraphDelegate = AudioGraphDelegate(audioGraph, playbackDelegate, preferences.soundPreferences, persistentState.audioGraph)
        recorderDelegate = RecorderDelegate(recorder)
        
        // Playlist Delegate
        playlistDelegate = PlaylistDelegate(persistentState: persistentState.playlist, playlist, trackReader, preferences,
                                            [playbackDelegate as! PlaybackDelegate])
    }
    
    private static func initializePlaybackDelegate(_ persistentState: PersistentAppState) {
        
        let profiles = PlaybackProfiles(persistentState: persistentState.playbackProfiles ?? [])
        
        let startPlaybackChain = StartPlaybackChain(player, sequencer, playlist, trackReader: trackReader, profiles, preferences.playbackPreferences)
        let stopPlaybackChain = StopPlaybackChain(player, playlist, sequencer, profiles, preferences.playbackPreferences)
        let trackPlaybackCompletedChain = TrackPlaybackCompletedChain(startPlaybackChain, stopPlaybackChain, sequencer)
        
        // Playback Delegate
        playbackDelegate = PlaybackDelegate(player, sequencer, profiles, preferences.playbackPreferences, startPlaybackChain, stopPlaybackChain, trackPlaybackCompletedChain)
    }
    
    private static func initializeTrackReader(_ persistentState: PersistentAppState) {
        
        musicBrainzCache = MusicBrainzCache(state: persistentState.musicBrainzCache, preferences: preferences.metadataPreferences.musicBrainz)
        musicBrainzCoverArtReader = MusicBrainzCoverArtReader(preferences: preferences.metadataPreferences.musicBrainz, cache: musicBrainzCache)
        
        coverArtReader = CoverArtReader(fileCoverArtReader, musicBrainzCoverArtReader)
        
        trackReader = TrackReader(fileReader, coverArtReader)
    }
    
    private static func initializeAuxiliaryModules(_ persistentState: PersistentAppState) {
        
        let history = History(preferences.historyPreferences)
        historyDelegate = HistoryDelegate(persistentState: persistentState.history, history, playlistDelegate, playbackDelegate)
        
        bookmarksDelegate = BookmarksDelegate(persistentState: persistentState.bookmarks, Bookmarks(), playlistDelegate, playbackDelegate)
        
        favoritesDelegate = FavoritesDelegate(persistentState: persistentState.favorites, Favorites(), playlistDelegate, playbackDelegate)
    }
    
    private static func initializeUtilities(_ persistentState: PersistentAppState) {
        
        PlaylistIO.initialize(playlist)
        TuneBrowserState.initialize(fromPersistentState: persistentState.tuneBrowser)
        UIUtils.initialize(preferences.viewPreferences)
    }
    
    private static func initializeUIPersistentState(_ persistentState: PersistentAppState) {
        
        Themes.initialize(persistentState.ui?.themes)
        FontSchemes.initialize(persistentState.ui?.fontSchemes)
        ColorSchemes.initialize(persistentState.ui?.colorSchemes)
        
        WindowLayoutState.initialize(persistentState.ui?.windowLayout)
        
        PlayerViewState.initialize(persistentState.ui?.player)
        PlaylistViewState.initialize(persistentState.ui?.playlist)
        VisualizerViewState.initialize(persistentState.ui?.visualizer)
        WindowAppearanceState.initialize(persistentState.ui?.windowAppearance)
        MenuBarPlayerViewState.initialize(persistentState.ui?.menuBarPlayer)
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
        persistentState.playbackProfiles = playbackDelegate.profiles.all().map {PlaybackProfilePersistentState(file: $0.file, lastPosition: $0.lastPosition)}
        
        let uiState = UIPersistentState()
        
        uiState.appMode = AppModeManager.mode
        uiState.windowLayout = WindowLayoutState.persistentState
        uiState.themes = Themes.persistentState
        uiState.fontSchemes = FontSchemes.persistentState
        uiState.colorSchemes = ColorSchemes.persistentState
        uiState.player = PlayerViewState.persistentState
        uiState.playlist = PlaylistViewState.persistentState
        uiState.visualizer = VisualizerViewState.persistentState
        uiState.windowAppearance = WindowAppearanceState.persistentState
        uiState.menuBarPlayer = MenuBarPlayerViewState.persistentState
        
        persistentState.ui = uiState
        
        persistentState.history = (historyDelegate as! HistoryDelegate).persistentState
        persistentState.favorites = (favoritesDelegate as! FavoritesDelegate).persistentState
        persistentState.bookmarks = (bookmarksDelegate as! BookmarksDelegate).persistentState
        persistentState.musicBrainzCache = musicBrainzCoverArtReader.cache.persistentState
        persistentState.tuneBrowser = TuneBrowserState.persistentState
        
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
