//
//  Globals.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit
let appVersion: String = NSApp.appVersion
let appSetup: AppSetup = .shared

fileprivate let logger: Logger = .init()

let jsonDecoder: JSONDecoder = JSONDecoder()
let jsonEncoder: JSONEncoder = JSONEncoder()

fileprivate var needToMigrateLegacySettings: Bool = false

let appDelegate: AppDelegate = NSApp.delegate as! AppDelegate

let persistenceManager: PersistenceManager = PersistenceManager(persistentStateFile: FilesAndPaths.persistentStateFile,
                                                                metadataStateFile: FilesAndPaths.metadataStateFile)

let appPersistentState: AppPersistentState = {
    
    // TODO: Replace try? with do {try} and log the error!
    // TODO: Add an arg to Logger.error(error: Error)
    guard let jsonString = try? String(contentsOf: FilesAndPaths.persistentStateFile, encoding: .utf8),
          let jsonData = jsonString.data(using: .utf8),
          let dict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
        
        logger.warning("Error loading app state config file.")
        return .defaults
    }
    
    if let appVersionString = dict["appVersion"] as? String,
       let appVersion = AppVersion(versionString: appVersionString) {
        
        if appVersion.majorVersion < 4 {
            
            needToMigrateLegacySettings = true
            
            if let legacyPersistentState: LegacyAppPersistentState = persistenceManager.load(objectOfType: LegacyAppPersistentState.self) {
                
                // Attempt migration and return the mapped instance.
                print("Mapped persistent state from app version: \(appVersionString)\n")
                return AppPersistentState(legacyAppPersistentState: legacyPersistentState)
            }
        }
    }
    
    return persistenceManager.load(objectOfType: AppPersistentState.self) ?? .defaults
}()

let userDefaults: UserDefaults = .standard
let preferences: Preferences = Preferences(defaults: userDefaults, needToMigrateLegacySettings: needToMigrateLegacySettings)

let appModeManager: AppModeManager = AppModeManager(persistentState: appPersistentState.ui,
                                                    preferences: preferences.viewPreferences)

fileprivate let playQueue: PlayQueue = PlayQueue()

var playQueueDelegate: PlayQueueDelegateProtocol {_playQueueDelegate}
fileprivate let _playQueueDelegate: PlayQueueDelegate = PlayQueueDelegate(playQueue: playQueue,
                                                                     persistentState: appPersistentState.playQueue)

//let library: Library = Library(persistentState: appPersistentState.library)
//let libraryDelegate: LibraryDelegateProtocol = LibraryDelegate()

//let playlistsManager: PlaylistsManager = PlaylistsManager()

//    let playlistDelegate: PlaylistDelegateProtocol = PlaylistDelegate(persistentState: appPersistentState.playlist, playlist,
//                                                                           trackReader, preferences)

let audioUnitsManager: AudioUnitsManager = AudioUnitsManager()
fileprivate let audioEngine: AudioEngine = AudioEngine()

let audioGraph: AudioGraph = AudioGraph(audioEngine: audioEngine, audioUnitsManager: audioUnitsManager,
                                                    persistentState: appPersistentState.audioGraph)

var audioGraphDelegate: AudioGraphDelegateProtocol = AudioGraphDelegate(graph: audioGraph, persistentState: appPersistentState.audioGraph,
                                                                        player: playbackDelegate, preferences: preferences.soundPreferences)

let player: PlayerProtocol = Player(graph: audioGraph, avfScheduler: avfScheduler, ffmpegScheduler: ffmpegScheduler)

fileprivate let avfScheduler: PlaybackSchedulerProtocol = AVFScheduler(audioGraph.playerNode)

fileprivate let ffmpegScheduler: PlaybackSchedulerProtocol = FFmpegScheduler(playerNode: audioGraph.playerNode)

let playbackProfiles = PlaybackProfiles(persistentState: appPersistentState.playbackProfiles ?? [])

let playbackDelegate: PlaybackDelegateProtocol = {
    
    let startPlaybackChain = StartPlaybackChain(player, playQueue: playQueue, trackReader: trackReader, playbackProfiles, preferences.playbackPreferences)
    let stopPlaybackChain = StopPlaybackChain(player, playQueue, playbackProfiles, preferences.playbackPreferences)
    let trackPlaybackCompletedChain = TrackPlaybackCompletedChain(startPlaybackChain, stopPlaybackChain, playQueue)
    
    // Playback Delegate
    return PlaybackDelegate(player, playQueue: playQueue, playbackProfiles, preferences.playbackPreferences,
                            startPlaybackChain, stopPlaybackChain, trackPlaybackCompletedChain)
}()

var playbackInfoDelegate: PlaybackInfoDelegateProtocol {playbackDelegate}

let replayGainScanner = ReplayGainScanner(persistentState: appPersistentState.audioGraph?.replayGainAnalysisCache)

var historyDelegate: HistoryDelegateProtocol {playQueueDelegate}

var favoritesDelegate: FavoritesDelegateProtocol {_favoritesDelegate}
fileprivate let _favoritesDelegate: FavoritesDelegate = FavoritesDelegate(playQueueDelegate, playbackDelegate)

var bookmarksDelegate: BookmarksDelegateProtocol {_bookmarksDelegate}
fileprivate let _bookmarksDelegate: BookmarksDelegate = BookmarksDelegate(playQueueDelegate, playbackDelegate)

let fileReader: FileReader = FileReader()
let trackReader: TrackReader = TrackReader()

let metadataPersistentState = persistenceManager.loadMetadata()
let metadataRegistry: MetadataRegistry = MetadataRegistry(persistentState: metadataPersistentState)

let coverArtReader: CoverArtReader = CoverArtReader(fileCoverArtReader, musicBrainzCoverArtReader)
let fileCoverArtReader: FileCoverArtReader = FileCoverArtReader(fileReader)
let musicBrainzCoverArtReader: MusicBrainzCoverArtReader = MusicBrainzCoverArtReader(preferences: preferences.metadataPreferences.musicBrainz,
                                                                                     cache: musicBrainzCache)

let musicBrainzCache: MusicBrainzCache = MusicBrainzCache(state: appPersistentState.musicBrainzCache,
                                                          preferences: preferences.metadataPreferences.musicBrainz)

let lastFMCache: LastFMScrobbleCache = .init(persistentState: appPersistentState.lastFMCache)
let lastFMClient: LastFM_WSClientProtocol = LastFM_WSClient(cache: lastFMCache)

// Fast Fourier Transform
let fft: FFT = FFT()

let windowLayoutsManager: WindowLayoutsManager = WindowLayoutsManager(persistentState: appPersistentState.ui?.windowLayout,
                                                                      viewPreferences: preferences.viewPreferences)

let themesManager: ThemesManager = ThemesManager(persistentState: appPersistentState.ui?.themes, fontSchemesManager: fontSchemesManager)

let fontSchemesManager: FontSchemesManager = FontSchemesManager(persistentState: appPersistentState.ui?.fontSchemes)
var systemFontScheme: FontScheme {fontSchemesManager.systemScheme}

let colorSchemesManager: ColorSchemesManager = ColorSchemesManager(persistentState: appPersistentState.ui?.colorSchemes)
let systemColorScheme: ColorScheme = colorSchemesManager.systemScheme

let playerUIState: PlayerUIState = PlayerUIState(persistentState: appPersistentState.ui?.modularPlayer)
let unifiedPlayerUIState: UnifiedPlayerUIState = UnifiedPlayerUIState(persistentState: appPersistentState.ui?.unifiedPlayer)
let compactPlayerUIState: CompactPlayerUIState = .init(persistentState: appPersistentState.ui?.compactPlayer)

let playQueueUIState: PlayQueueUIState = PlayQueueUIState(persistentState: appPersistentState.ui?.playQueue)
//let playlistsUIState: PlaylistsUIState = PlaylistsUIState()
let menuBarPlayerUIState: MenuBarPlayerUIState = MenuBarPlayerUIState(persistentState: appPersistentState.ui?.menuBarPlayer)
let widgetPlayerUIState: WidgetPlayerUIState = WidgetPlayerUIState(persistentState: appPersistentState.ui?.widgetPlayer)
let visualizerUIState: VisualizerUIState = VisualizerUIState(persistentState: appPersistentState.ui?.visualizer)
//let tuneBrowserUIState: TuneBrowserUIState = TuneBrowserUIState(persistentState: appPersistentState.ui?.tuneBrowser)

let mediaKeyHandler: MediaKeyHandler = MediaKeyHandler(preferences.controlsPreferences.mediaKeys)

//let libraryMonitor: LibraryMonitor = .init(libraryPersistentState: appPersistentState.library)

let remoteControlManager: RemoteControlManager = RemoteControlManager(playbackInfo: playbackInfoDelegate, playQueue: playQueueDelegate, 
                                                                      audioGraph: audioGraphDelegate,
                                                                      preferences: preferences)

var persistentStateOnExit: AppPersistentState {
    
    // Gather all pieces of persistent state into the persistentState object
    var persistentState: AppPersistentState = AppPersistentState()
    
    persistentState.appVersion = appVersion
    
    persistentState.audioGraph = audioGraph.persistentState
    persistentState.playQueue = _playQueueDelegate.persistentState
    
//    persistentState.library = library.persistentState
//    persistentState.playlists = playlistsManager.persistentState
    persistentState.favorites = _favoritesDelegate.persistentState
    persistentState.bookmarks = _bookmarksDelegate.persistentState
    
    persistentState.playbackProfiles = playbackDelegate.profiles.all().map {PlaybackProfilePersistentState(profile: $0)}
    
    persistentState.ui = UIPersistentState(appMode: appModeManager.currentMode,
                                           windowLayout: windowLayoutsManager.persistentState,
                                           themes: themesManager.persistentState,
                                           fontSchemes: fontSchemesManager.persistentState,
                                           colorSchemes: colorSchemesManager.persistentState,
                                           
                                           modularPlayer: playerUIState.persistentState,
                                           unifiedPlayer: unifiedPlayerUIState.persistentState,
                                           menuBarPlayer: menuBarPlayerUIState.persistentState,
                                           widgetPlayer: widgetPlayerUIState.persistentState,
                                           compactPlayer: compactPlayerUIState.persistentState,
                                           
                                           playQueue: playQueueUIState.persistentState,
                                           visualizer: visualizerUIState.persistentState,
                                           waveform: WaveformView.persistentState)
    
    persistentState.musicBrainzCache = musicBrainzCoverArtReader.cache.persistentState
    
    return persistentState
}
