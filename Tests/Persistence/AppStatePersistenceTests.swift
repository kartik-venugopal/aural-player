//
//  AppStatePersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

class AppStatePersistenceTests: AudioGraphTestCase {
    
    func testPersistence() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            // App version
            
            let appVersion = randomAppVersion()
            
            // Window layouts
            
            let layout = randomLayout(name: "_system_", systemDefined: true,
                                      showPlaylist: .random(), showEffects: .random())
            
            let windowLayouts = WindowLayoutsPersistentState(layout: layout, userLayouts: randomUserLayouts())
            
            // Themes
            
            let themes = ThemesPersistentState(userThemes: randomThemes())
            
            // Font schemes
            
            let systemFontScheme = randomFontScheme(named: "_system_")
            let userFontSchemes = randomFontSchemes()
            
            let fontSchemes = FontSchemesPersistentState(systemScheme: systemFontScheme, userSchemes: userFontSchemes)
            
            // Color schemes
            
            let systemColorScheme = randomColorScheme(named: "_system_")
            let userColorSchemes = randomColorSchemes()
            
            let colorSchemes = ColorSchemesPersistentState(systemScheme: systemColorScheme, userSchemes: userColorSchemes)
            
            // Player
            
            let player = PlayerUIPersistentState(viewType: .randomCase(),
                                                 showAlbumArt: .random(),
                                                 showArtist: .random(),
                                                 showAlbum: .random(),
                                                 showCurrentChapter: .random(),
                                                 showTrackInfo: .random(),
                                                 showPlayingTrackFunctions: .random(),
                                                 showControls: .random(),
                                                 showTimeElapsedRemaining: .random(),
                                                 timeElapsedDisplayType: .randomCase(),
                                                 timeRemainingDisplayType: .randomCase())
            
            // Playlist
            
            let playlistUI = PlaylistUIPersistentState(view: PlaylistType.randomCase().rawValue)
            
            // Visualizer
            
            let vizOptions = VisualizerOptionsPersistentState(lowAmplitudeColor: randomColor(),
                                                              highAmplitudeColor: randomColor())
            
            let visualizer = VisualizerUIPersistentState(type: .randomCase(),
                                                         options: vizOptions)
            
            // Window appearance
            
            let windowAppearance = WindowUIPersistentState(cornerRadius: CGFloat.random(in: 0...25))
            
            // Menu Bar Player
            
            let menuBarPlayer = MenuBarPlayerUIPersistentState(showAlbumArt: .random(),
                                                               showArtist: .random(),
                                                               showAlbum: .random(),
                                                               showCurrentChapter: .random())
            
            // Control Bar Player
            
            let controlBarPlayer = ControlBarPlayerUIPersistentState(windowFrame: NSRectPersistentState(rect: randomControlBarPlayerWindowFrame()),
                                                                     cornerRadius: CGFloat.random(in: 0...20),
                                                                     trackInfoScrollingEnabled: .random(),
                                                                     showSeekPosition: .random(),
                                                                     seekPositionDisplayType: .randomCase())
            
            let ui = UIPersistentState(appMode: .randomCase(),
                                          windowLayout: windowLayouts,
                                          themes: themes,
                                          fontSchemes: fontSchemes,
                                          colorSchemes: colorSchemes,
                                          player: player,
                                          playlist: playlistUI,
                                          visualizer: visualizer,
                                          windowAppearance: windowAppearance,
                                          menuBarPlayer: menuBarPlayer,
                                          controlBarPlayer: controlBarPlayer)
            
            // Playlist
            
            let newTracks = createNTracks(numTracks: Int.random(in: 1...1000))
            
            let trackPaths: [URLPath] = newTracks.tracks.map {$0.file.path}
            
            var artistGroups: [GroupPersistentState] = []
            for (artist, tracks) in newTracks.artistGroups {
                artistGroups.append(GroupPersistentState(name: artist, tracks: tracks.map {$0.file.path}))
            }
            
            var albumGroups: [GroupPersistentState] = []
            for (album, tracks) in newTracks.albumGroups {
                albumGroups.append(GroupPersistentState(name: album, tracks: tracks.map {$0.file.path}))
            }
            
            var genreGroups: [GroupPersistentState] = []
            for (genre, tracks) in newTracks.genreGroups {
                genreGroups.append(GroupPersistentState(name: genre, tracks: tracks.map {$0.file.path}))
            }
            
            let groupingPlaylists: [String: GroupingPlaylistPersistentState] = [
            
                "artists": GroupingPlaylistPersistentState(type: .artists, groups: artistGroups),
                "albums": GroupingPlaylistPersistentState(type: .albums, groups: albumGroups),
                "genres": GroupingPlaylistPersistentState(type: .genres, groups: genreGroups),
            ]
            
            let playlist = PlaylistPersistentState(tracks: trackPaths, groupingPlaylists: groupingPlaylists)
            
            // Audio Graph
            
            let outputDevice = AudioDevicePersistentState(name: randomDeviceName(),
                                                          uid: randomDeviceUID())
            
            let volume: Float? = randomVolume()
            let muted: Bool? = .random()
            let balance: Float? = randomBalance()
            
            let masterUnit: MasterUnitPersistentState? = MasterUnitPersistentState(state: randomUnitState(),
                                                                                   userPresets: randomMasterPresets())
            
            let eqType: EQType = randomEQType()
            let eqUnit: EQUnitPersistentState? = EQUnitPersistentState(state: randomUnitState(),
                                                                       userPresets: randomEQPresets(),
                                                                       type: eqType,
                                                                       globalGain: randomEQGlobalGain(),
                                                                       bands: eqType == .tenBand ? randomEQ10Bands() : randomEQ15Bands())
            
            let pitchUnit: PitchShiftUnitPersistentState? = PitchShiftUnitPersistentState(state: randomUnitState(),
                                                                                          userPresets: randomPitchShiftPresets(),
                                                                                          pitch: randomPitch(),
                                                                                          overlap: randomOverlap())
            
            let timeUnit: TimeStretchUnitPersistentState? = TimeStretchUnitPersistentState(state: randomUnitState(),
                                                                                           userPresets: randomTimeStretchPresets(),
                                                                                           rate: randomTimeStretchRate(),
                                                                                           shiftPitch: randomTimeStretchShiftPitch(),
                                                                                           overlap: randomOverlap())
            
            let reverbUnit: ReverbUnitPersistentState? = ReverbUnitPersistentState(state: randomUnitState(),
                                                                                   userPresets: randomReverbPresets(),
                                                                                   space: randomReverbSpace(),
                                                                                   amount: randomReverbAmount())
            
            let delayUnit: DelayUnitPersistentState? = DelayUnitPersistentState(state: randomUnitState(),
                                                                                userPresets: randomDelayPresets(),
                                                                                amount: randomDelayAmount(),
                                                                                time: randomDelayTime(),
                                                                                feedback: randomDelayFeedback(),
                                                                                lowPassCutoff: randomDelayLowPassCutoff())
            
            let filterUnit: FilterUnitPersistentState? = FilterUnitPersistentState(state: randomUnitState(),
                                                                                   userPresets: randomFilterPresets(),
                                                                                   bands: randomFilterBands())
            
            let numAU = Int.random(in: 0..<5)
            let audioUnits: [AudioUnitPersistentState]? = numAU == 0 ? [] : (0..<numAU).map {_ in
                
                AudioUnitPersistentState(state: randomUnitState(),
                                         userPresets: randomAUPresets(),
                                         componentType: randomAUOSType(),
                                         componentSubType: randomAUOSType(),
                                         params: randomAUParams())
            }
            
            let numProfiles = Int.random(in: 0..<20)
            let soundProfiles: [SoundProfilePersistentState]? = numProfiles == 0 ? [] : (0..<numProfiles).map {_ in
                
                SoundProfilePersistentState(file: randomAudioFile(), volume: randomVolume(), balance: randomBalance(),
                                            effects: randomMasterPresets(count: 1)[0])
            }
            
            let audioGraph = AudioGraphPersistentState(outputDevice: outputDevice,
                                                            volume: volume,
                                                            muted: muted,
                                                            balance: balance,
                                                            masterUnit: masterUnit,
                                                            eqUnit: eqUnit,
                                                            pitchUnit: pitchUnit,
                                                            timeUnit: timeUnit,
                                                            reverbUnit: reverbUnit,
                                                            delayUnit: delayUnit,
                                                            filterUnit: filterUnit,
                                                            audioUnits: audioUnits,
                                                            soundProfiles: soundProfiles)
            
            // Playback Sequence
            
            let playbackSequence = PlaybackSequencePersistentState(repeatMode: .randomCase(),
                                                        shuffleMode: .randomCase())
            
            // Playback Profiles
            
            let numPlaybackProfiles = Int.random(in: 10...100)
            
            let profiles = (1...numPlaybackProfiles).map {_ in
                
                PlaybackProfilePersistentState(file: randomAudioFile(),
                                               lastPosition: randomPlaybackPosition())
            }
            
            // History
            
            let history = HistoryPersistentState(recentlyAdded: randomRecentlyAddedItems(),
                                               recentlyPlayed: randomRecentlyPlayedItems())
            
            // Favorites
            
            let numFavorites = Int.random(in: 10...100)
            
            let favorites = (1...numFavorites).map {_ in
                
                FavoritePersistentState(file: randomAudioFile(),
                                        name: randomString(length: Int.random(in: 10...50)))
            }
            
            let numBookmarks = Int.random(in: 3...100)
            
            let bookmarks: [BookmarkPersistentState] = (1...numBookmarks).map {_ in
                
                // 20% probability.
                let hasEndPosition: Bool = Int.random(in: 1...10) > 8
                
                let startPosition = randomPlaybackPosition()
                let endPosition = hasEndPosition ? startPosition + (Double.random(in: 60...600)) : nil
                
                return BookmarkPersistentState(name: randomString(length: Int.random(in: 10...50)),
                                               file: randomAudioFile(),
                                               startPosition: startPosition,
                                               endPosition: endPosition)
            }
            
            // MusicBrainz Cache
            
            let numReleases = Int.random(in: 5...500)
            let numRecordings = Int.random(in: 5...500)
            
            let releases: [MusicBrainzCacheEntryPersistentState] = (1...numReleases).map {_ in
                
                MusicBrainzCacheEntryPersistentState(artist: randomArtist(),
                                                     title: randomTitle(),
                                                     file: randomImageFile())
            }
            
            let recordings: [MusicBrainzCacheEntryPersistentState] = (1...numRecordings).map {_ in
                
                MusicBrainzCacheEntryPersistentState(artist: randomArtist(),
                                                     title: randomTitle(),
                                                     file: randomImageFile())
            }
            
            let musicBrainzCache = MusicBrainzCachePersistentState(releases: releases, recordings: recordings)
            
            let appState = PersistentAppState(appVersion: appVersion,
                                              ui: ui,
                                              playlist: playlist,
                                              audioGraph: audioGraph,
                                              playbackSequence: playbackSequence,
                                              playbackProfiles: profiles,
                                              history: history,
                                              favorites: favorites,
                                              bookmarks: bookmarks,
                                              musicBrainzCache: musicBrainzCache)
            
            doTestPersistence(serializedState: appState)
        }
    }
    
    private func randomAppVersion() -> String {
        
        let majorVersion: Int = Int.random(in: 1...10)
        let minorVersion: Int = Int.random(in: 0...25)
        let patchVersion: Int = Int.random(in: 0...10)
        
        return "\(majorVersion).\(minorVersion).\(patchVersion)"
    }
    
    private func createNTracks(numTracks: Int) -> (tracks: [Track], artistGroups: [String: [Track]],
                                                   albumGroups: [String: [Track]],
                                                   genreGroups: [String: [Track]]) {

        var tracks: [Track] = []
        var artistGroups: [String: [Track]] = [:]
        var albumGroups: [String: [Track]] = [:]
        var genreGroups: [String: [Track]] = [:]

        for counter in 1...numTracks {

            let title = "Track-" + String(counter)
            let artist = randomArtist()
            let album = randomAlbum()
            let genre = randomGenre()

            let track = Track(URL(fileURLWithPath: String(format: "/Users/auralPlayerUser/Music/%@/%@.mp3", artist, title)))
            
            if artistGroups[artist] == nil {
                artistGroups[artist] = []
            }
            
            artistGroups[artist]!.append(track)
            
            if albumGroups[album] == nil {
                albumGroups[album] = []
            }
            
            albumGroups[album]!.append(track)
            
            if genreGroups[genre] == nil {
                genreGroups[genre] = []
            }
            
            genreGroups[genre]!.append(track)
            
            let fileMetadata: FileMetadata = FileMetadata()
            var playlistMetadata: PlaylistMetadata = PlaylistMetadata()
            
            playlistMetadata.artist = artist
            playlistMetadata.album = album
            playlistMetadata.genre = genre
            playlistMetadata.duration = 300
            
            fileMetadata.playlist = playlistMetadata
            track.setPlaylistMetadata(from: fileMetadata)

            tracks.append(track)
        }

        return (tracks, artistGroups, albumGroups, genreGroups)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension PersistentAppState: Equatable {
    
    init(appVersion: String? = nil, ui: UIPersistentState? = nil, playlist: PlaylistPersistentState? = nil, audioGraph: AudioGraphPersistentState? = nil, playbackSequence: PlaybackSequencePersistentState? = nil, playbackProfiles: [PlaybackProfilePersistentState]? = nil, history: HistoryPersistentState? = nil, favorites: [FavoritePersistentState]? = nil, bookmarks: [BookmarkPersistentState]? = nil, musicBrainzCache: MusicBrainzCachePersistentState? = nil) {
        
        self.appVersion = appVersion
        self.ui = ui
        self.playlist = playlist
        self.audioGraph = audioGraph
        self.playbackSequence = playbackSequence
        self.playbackProfiles = playbackProfiles
        self.history = history
        self.favorites = favorites
        self.bookmarks = bookmarks
        self.musicBrainzCache = musicBrainzCache
    }
    
    static func == (lhs: PersistentAppState, rhs: PersistentAppState) -> Bool {
        
        lhs.appVersion == rhs.appVersion &&
            lhs.audioGraph == rhs.audioGraph &&
            lhs.bookmarks == rhs.bookmarks &&
            lhs.favorites == rhs.favorites &&
            lhs.history == rhs.history &&
            lhs.musicBrainzCache == rhs.musicBrainzCache &&
            lhs.playbackProfiles == rhs.playbackProfiles &&
            lhs.playbackSequence == rhs.playbackSequence &&
            lhs.playlist == rhs.playlist &&
            lhs.ui == rhs.ui
    }
}
