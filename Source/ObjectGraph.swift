//
//  ObjectGraph.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

/*
    Takes care of loading all persistent app state from disk, and constructing the critical objects in the app's object tree - player, playlist, audio graph (i.e., "the back end"), and all delegates (middlemen/facades) for interaction between the UI and the "back end".
 */
class ObjectGraph {
    
    static let persistentState: PersistentAppState = PersistentStateIO.load() ?? PersistentAppState.defaults
    
    static let lastPresentedAppMode: AppMode = persistentState.ui?.appMode ?? AppDefaults.appMode
    
    static let preferences: Preferences = Preferences.instance
    
    private static let playlist: PlaylistCRUDProtocol = Playlist(FlatPlaylist(),
                                                                 [GroupingPlaylist(.artists), GroupingPlaylist(.albums), GroupingPlaylist(.genres)])
    
    static let playlistDelegate: PlaylistDelegateProtocol = PlaylistDelegate(persistentState: persistentState.playlist, playlist, trackReader, preferences,
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
        
        let playlistType = persistentState.ui?.playlist?.view ?? .tracks
        return Sequencer(persistentState: persistentState.playbackSequence, playlist, playlistType)
    }()
    
    static let sequencerDelegate: SequencerDelegateProtocol = SequencerDelegate(sequencer)
    static var sequencerInfoDelegate: SequencerInfoDelegateProtocol! {sequencerDelegate}
    
    static let playbackDelegate: PlaybackDelegateProtocol = {
        
        let profiles = PlaybackProfiles(persistentState: persistentState.playbackProfiles ?? [])
        
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
    static let historyDelegate: HistoryDelegateProtocol = HistoryDelegate(persistentState: persistentState.history, history, playlistDelegate, playbackDelegate)
    
    static var favoritesDelegate: FavoritesDelegateProtocol = FavoritesDelegate(persistentState: persistentState.favorites, playlistDelegate,
                                                                                playbackDelegate)
    
    static let bookmarksDelegate: BookmarksDelegateProtocol = BookmarksDelegate(persistentState: persistentState.bookmarks, playlistDelegate,
                                                                                playbackDelegate)
    
    static let fileReader: FileReader = FileReader()
    static let trackReader: TrackReader = TrackReader(fileReader, coverArtReader)
    
    static let mediaKeyHandler: MediaKeyHandler = MediaKeyHandler(preferences.controlsPreferences.mediaKeys)
    
    static let coverArtReader: CoverArtReader = CoverArtReader(fileCoverArtReader, musicBrainzCoverArtReader)
    static let fileCoverArtReader: FileCoverArtReader = FileCoverArtReader(fileReader)
    static let musicBrainzCoverArtReader: MusicBrainzCoverArtReader = MusicBrainzCoverArtReader(preferences: preferences.metadataPreferences.musicBrainz,
                                                                                                cache: musicBrainzCache)
    
    static let musicBrainzCache: MusicBrainzCache = MusicBrainzCache(state: persistentState.musicBrainzCache,
                                                                     preferences: preferences.metadataPreferences.musicBrainz)
    
    static let windowLayoutsManager: WindowLayoutsManager = WindowLayoutsManager(persistentState: persistentState.ui?.windowLayout)
    static let themesManager: ThemesManager = ThemesManager(persistentState: persistentState.ui?.themes, fontSchemesManager: fontSchemesManager)
    static let fontSchemesManager: FontSchemesManager = FontSchemesManager(persistentState: persistentState.ui?.fontSchemes)
    static let colorSchemesManager: ColorSchemesManager = ColorSchemesManager(persistentState: persistentState.ui?.colorSchemes)
    
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
        
        WindowLayoutState.initialize(persistentState.ui?.windowLayout)
        
        PlayerViewState.initialize(persistentState.ui?.player)
        PlaylistViewState.initialize(persistentState.ui?.playlist)
        VisualizerViewState.initialize(persistentState.ui?.visualizer)
        WindowAppearanceState.initialize(persistentState.ui?.windowAppearance)
        MenuBarPlayerViewState.initialize(persistentState.ui?.menuBarPlayer)
        
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
        
        for folder in [transcoderDir, artDir] {
            folder.delete()
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
        
        persistentState.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString", String.self] ?? "1.0.0"
        
        persistentState.audioGraph = (audioGraph as! AudioGraph).persistentState
        persistentState.playlist = (playlist as! Playlist).persistentState
        persistentState.playbackSequence = (sequencer as! Sequencer).persistentState
        persistentState.playbackProfiles = playbackDelegate.profiles.all().map {PlaybackProfilePersistentState(file: $0.file, lastPosition: $0.lastPosition)}
        
        let uiState = UIPersistentState()
        
        uiState.appMode = AppModeManager.mode
        uiState.windowLayout = WindowLayoutState.persistentState
        uiState.themes = themesManager.persistentState
        uiState.fontSchemes = fontSchemesManager.persistentState
        uiState.colorSchemes = colorSchemesManager.persistentState
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
        
        // App state persistence and shutting down the audio engine can be performed concurrently
        // on two background threads to save some time when exiting the app.
        
        // App state persistence to disk
        tearDownOpQueue.addOperation {
            PersistentStateIO.save(persistentState)
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
