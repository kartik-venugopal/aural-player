/*
    Takes care of loading all persistent app state from disk, and constructing the critical objects in the app's object tree - player, playlist, audio graph (i.e., "the back end"), and all delegates (middlemen/facades) for interaction between the UI and the "back end".
 */

import Foundation

class ObjectGraph {
    
    static let persistentState: PersistentAppState = AppStateIO.load() ?? PersistentAppState.defaults
    
    static let lastPresentedAppMode: AppMode = AppMode(rawValue: persistentState.ui.appMode) ?? AppDefaults.appMode
    
    static let preferences: Preferences = Preferences.instance
    
    private static let playlist: PlaylistCRUDProtocol = Playlist(FlatPlaylist(),
                                                                 [GroupingPlaylist(.artists), GroupingPlaylist(.albums), GroupingPlaylist(.genres)])
    
    static let playlistDelegate: PlaylistDelegateProtocol = PlaylistDelegate(playlist, trackReader, persistentState.playlist, preferences,
                                                                             [playbackDelegate as! PlaybackDelegate])
    
    static var playlistAccessorDelegate: PlaylistAccessorDelegateProtocol {playlistDelegate}
    
    static let audioUnitsManager: AudioUnitsManager = AudioUnitsManager()
    private static let audioGraph: AudioGraphProtocol = AudioGraph(audioUnitsManager, persistentState.audioGraph)
    static let audioGraphDelegate: AudioGraphDelegateProtocol = AudioGraphDelegate(audioGraph, playbackDelegate,
                                                                                   preferences.soundPreferences, persistentState.audioGraph)
    
    private static let player: PlayerProtocol = Player(graph: audioGraph, avfScheduler: avfScheduler, ffmpegScheduler: ffmpegScheduler)
    private static let avfScheduler: PlaybackSchedulerProtocol = {
        
        // The new scheduler uses an AVFoundation API that is only available with macOS >= 10.13.
        // Instantiate the legacy scheduler if running on 10.12 Sierra or older systems.
        if #available(macOS 10.13, *) {
            return AVFScheduler(audioGraph.playerNode)
        } else {
            return LegacyAVFScheduler(audioGraph.playerNode)
        }
    }()
    
    private static let ffmpegScheduler: PlaybackSchedulerProtocol = FFmpegScheduler(playerNode: audioGraph.playerNode,
                                                                                    sampleConverter: FFmpegSampleConverter())
    private static let sequencer: SequencerProtocol = {
        
        let repeatMode = persistentState.playbackSequence.repeatMode
        let shuffleMode = persistentState.playbackSequence.shuffleMode
        let playlistType = PlaylistType(rawValue: persistentState.ui.playlist.view.lowercased()) ?? .tracks
        
        return Sequencer(playlist, repeatMode, shuffleMode, playlistType)
    }()
    
    static let sequencerDelegate: SequencerDelegateProtocol = SequencerDelegate(sequencer)
    static var sequencerInfoDelegate: SequencerInfoDelegateProtocol! {sequencerDelegate}
    
    static let playbackDelegate: PlaybackDelegateProtocol = {
        
        let profiles = PlaybackProfiles(persistentState.playbackProfiles)
        
        let startPlaybackChain = StartPlaybackChain(player, sequencer, playlist, trackReader: trackReader, profiles, preferences.playbackPreferences)
        let stopPlaybackChain = StopPlaybackChain(player, playlist, sequencer, profiles, preferences.playbackPreferences)
        let trackPlaybackCompletedChain = TrackPlaybackCompletedChain(startPlaybackChain, stopPlaybackChain, sequencer)
        
        // Playback Delegate
        return PlaybackDelegate(player, playlist, sequencer, profiles, preferences.playbackPreferences,
                                startPlaybackChain, stopPlaybackChain, trackPlaybackCompletedChain)
    }()
    
    static var playbackInfoDelegate: PlaybackInfoDelegateProtocol! {playbackDelegate}
    
    @available(OSX 10.12.2, *)
    static let remoteControlManager: RemoteControlManager = RemoteControlManager(playbackInfo: playbackInfoDelegate, audioGraph: audioGraphDelegate,
                                                                                 sequencer: sequencerDelegate, preferences: preferences)
    
    private static let recorder: Recorder = Recorder(audioGraph)
    static let recorderDelegate: RecorderDelegateProtocol = RecorderDelegate(recorder)
    
    private static let history: History = History(preferences.historyPreferences)
    static let historyDelegate: HistoryDelegateProtocol = HistoryDelegate(history, playlistDelegate, playbackDelegate, persistentState.history)
    
    private static let favorites: Favorites = Favorites()
    static var favoritesDelegate: FavoritesDelegateProtocol = FavoritesDelegate(favorites, playlistDelegate, playbackDelegate, persistentState.favorites)
    
    private static let bookmarks: Bookmarks = Bookmarks()
    static let bookmarksDelegate: BookmarksDelegateProtocol = BookmarksDelegate(bookmarks, playlistDelegate, playbackDelegate, persistentState.bookmarks)
    
    static let fileReader: FileReader = FileReader()
    static let trackReader: TrackReader = TrackReader(fileReader, coverArtReader)
    
    static let mediaKeyHandler: MediaKeyHandler = MediaKeyHandler(preferences.controlsPreferences.mediaKeys)
    
    static let coverArtReader: CoverArtReader = CoverArtReader(fileCoverArtReader, musicBrainzCoverArtReader)
    static let fileCoverArtReader: FileCoverArtReader = FileCoverArtReader(fileReader)
    static let musicBrainzCoverArtReader: MusicBrainzCoverArtReader = MusicBrainzCoverArtReader(state: persistentState.musicBrainzCache,
                                                                                                preferences: preferences.metadataPreferences.musicBrainz,
                                                                                                cache: musicBrainzCache)
    
    static let musicBrainzCache: MusicBrainzCache = MusicBrainzCache(state: persistentState.musicBrainzCache,
                                                                     preferences: preferences.metadataPreferences.musicBrainz)
    
    // Don't let any code invoke this initializer to create instances of ObjectGraph
    private init() {}
    
    // Performs all necessary object initialization
    static func initialize() {
        
         // Force initialization of objects that would not be initialized soon enough otherwise
        // (they are not referred to in code that is executed on app startup).
        
        _ = mediaKeyHandler
        
        if #available(OSX 10.12.2, *) {
            _ = remoteControlManager
        }
        
        // Initialize utility classes.
        
        UIUtils.initialize(preferences.viewPreferences)
        
        Themes.initialize(persistentState.ui.themes)
        FontSchemes.initialize(persistentState.ui.fontSchemes)
        ColorSchemes.initialize(persistentState.ui.colorSchemes)
        
        WindowLayoutState.initialize(persistentState.ui.windowLayout)
        
        PlayerViewState.initialize(persistentState.ui.player)
        PlaylistViewState.initialize(persistentState.ui.playlist)
        VisualizerViewState.initialize(persistentState.ui.visualizer)
        WindowAppearanceState.initialize(persistentState.ui.windowAppearance)
        MenuBarPlayerViewState.initialize(persistentState.ui.menuBarPlayer)
        
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
