//
//  PreferencesTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class PreferencesTests: PreferencesTestCase {
    
    private typealias PlaylistDefaults = PreferencesDefaults.Playlist
    private typealias PlaybackDefaults = PreferencesDefaults.Playback
    private typealias SoundDefaults = PreferencesDefaults.Sound
    private typealias HistoryDefaults = PreferencesDefaults.History
    private typealias ViewDefaults = PreferencesDefaults.View
    private typealias MediaKeysDefaults = PreferencesDefaults.Controls.MediaKeys
    private typealias GesturesDefaults = PreferencesDefaults.Controls.Gestures
    private typealias RemoteControlDefaults = PreferencesDefaults.Controls.RemoteControl
    private typealias MusicBrainzDefaults = PreferencesDefaults.Metadata.MusicBrainz
    
    // MARK: init() tests ------------------------------
    
    func testInit_noValues() {

        doTestInit(userDefs: UserDefaults(),
                   playlistOnStartup: nil,
                   playlistFile: nil,
                   tracksFolder: nil,
                   viewOnStartup: nil,
                   showNewTrackInPlaylist: nil,
                   showChaptersList: nil,
                   primarySeekLengthOption: nil,
                   primarySeekLengthConstant: nil,
                   primarySeekLengthPercentage: nil,
                   secondarySeekLengthOption: nil,
                   secondarySeekLengthConstant: nil,
                   secondarySeekLengthPercentage: nil,
                   autoplayOnStartup: nil,
                   autoplayAfterAddingTracks: nil,
                   autoplayAfterAddingOption: nil,
                   rememberLastPositionOption: nil,
                   outputDeviceOnStartup: nil,
                   volumeDelta: nil,
                   volumeOnStartupOption: nil,
                   startupVolumeValue: nil,
                   panDelta: nil,
                   eqDelta: nil,
                   pitchDelta: nil,
                   timeDelta: nil,
                   effectsSettingsOnStartupOption: nil,
                   masterPresetOnStartup_name: nil,
                   rememberEffectsSettingsOption: nil,
                   recentlyAddedListSize: nil,
                   recentlyPlayedListSize: nil,
                   appModeOnStartup: nil,
                   layoutOnStartup: nil,
                   snapToWindows: nil,
                   snapToScreen: nil,
                   windowGap: nil,
                   mediaKeysEnabled: nil,
                   skipKeyBehavior: nil,
                   repeatSpeed: nil,
                   allowVolumeControl: nil,
                   allowSeeking: nil,
                   allowTrackChange: nil,
                   allowPlaylistNavigation: nil,
                   allowPlaylistTabToggle: nil,
                   volumeControlSensitivity: nil,
                   seekSensitivity: nil,
                   remoteControlEnabled: nil,
                   trackChangeOrSeekingOption: nil,
                   httpTimeout: nil,
                   enableCoverArtSearch: nil,
                   enableOnDiskCoverArtCache: nil)
    }
    
    func testInit() {

        for _ in 1...100 {

            let playlistStartupOptions = randomPlaylistStartupOptions()

            doTestInit(userDefs: UserDefaults(),
                       playlistOnStartup: playlistStartupOptions.option,
                       playlistFile: playlistStartupOptions.playlistFile,
                       tracksFolder: playlistStartupOptions.tracksFolder,
                       viewOnStartup: randomPlaylistViewOnStartup(),
                       showNewTrackInPlaylist: .random(),
                       showChaptersList: .random(),
                       primarySeekLengthOption: randomSeekLengthOption(),
                       primarySeekLengthConstant: randomSeekLengthConstant(),
                       primarySeekLengthPercentage: randomPercentage(),
                       secondarySeekLengthOption: randomSeekLengthOption(),
                       secondarySeekLengthConstant: randomSeekLengthConstant(),
                       secondarySeekLengthPercentage: randomPercentage(),
                       autoplayOnStartup: .random(),
                       autoplayAfterAddingTracks: .random(),
                       autoplayAfterAddingOption: randomAutoplayAfterAddingOption(),
                       rememberLastPositionOption: randomRememberLastPositionOption(),
                       outputDeviceOnStartup: randomOutputDevice(),
                       volumeDelta: randomVolumeDelta(),
                       volumeOnStartupOption: .randomCase(),
                       startupVolumeValue: randomStartupVolumeValue(),
                       panDelta: randomPanDelta(),
                       eqDelta: randomEQDelta(),
                       pitchDelta: randomPitchDelta(),
                       timeDelta: randomTimeDelta(),
                       effectsSettingsOnStartupOption: .randomCase(),
                       masterPresetOnStartup_name: randomMasterPresetName(),
                       rememberEffectsSettingsOption: .randomCase(),
                       recentlyAddedListSize: randomHistoryListSize(),
                       recentlyPlayedListSize: randomHistoryListSize(),
                       appModeOnStartup: randomNillableAppModeOnStartup(),
                       layoutOnStartup: randomNillableLayoutOnStartup(),
                       snapToWindows: randomNillableBool(),
                       snapToScreen: randomNillableBool(),
                       windowGap: randomNillableWindowGap(),
                       mediaKeysEnabled: .random(),
                       skipKeyBehavior: randomSkipKeyBehavior(),
                       repeatSpeed: randomRepeatSpeed(),
                       allowVolumeControl: .random(),
                       allowSeeking: .random(),
                       allowTrackChange: .random(),
                       allowPlaylistNavigation: .random(),
                       allowPlaylistTabToggle: .random(),
                       volumeControlSensitivity: .randomCase(),
                       seekSensitivity: .randomCase(),
                       remoteControlEnabled: .random(),
                       trackChangeOrSeekingOption: randomTrackChangeOrSeekingOption(),
                       httpTimeout: randomHTTPTimeout(),
                       enableCoverArtSearch: .random(),
                       enableOnDiskCoverArtCache: .random())
        }
    }
    
    private func doTestInit(userDefs: UserDefaults,
                            playlistOnStartup: PlaylistStartupOptions?,
                            playlistFile: URL?,
                            tracksFolder: URL?,
                            viewOnStartup: PlaylistViewOnStartup?,
                            showNewTrackInPlaylist: Bool?,
                            showChaptersList: Bool?,
                            primarySeekLengthOption: SeekLengthOptions?,
                            primarySeekLengthConstant: Int?,
                            primarySeekLengthPercentage: Int?,
                            secondarySeekLengthOption: SeekLengthOptions?,
                            secondarySeekLengthConstant: Int?,
                            secondarySeekLengthPercentage: Int?,
                            autoplayOnStartup: Bool?,
                            autoplayAfterAddingTracks: Bool?,
                            autoplayAfterAddingOption: AutoplayAfterAddingOptions?,
                            rememberLastPositionOption: RememberSettingsForTrackOptions?,
                            outputDeviceOnStartup: OutputDeviceOnStartup?,
                            volumeDelta: Float?,
                            volumeOnStartupOption: VolumeStartupOptions?,
                            startupVolumeValue: Float?,
                            panDelta: Float?,
                            eqDelta: Float?,
                            pitchDelta: Int?,
                            timeDelta: Float?,
                            effectsSettingsOnStartupOption: EffectsSettingsStartupOptions?,
                            masterPresetOnStartup_name: String?,
                            rememberEffectsSettingsOption: RememberSettingsForTrackOptions?,
                            recentlyAddedListSize: Int?,
                            recentlyPlayedListSize: Int?,
                            appModeOnStartup: AppModeOnStartup?,
                            layoutOnStartup: LayoutOnStartup?,
                            snapToWindows: Bool?,
                            snapToScreen: Bool?,
                            windowGap: Float?,
                            mediaKeysEnabled: Bool?,
                            skipKeyBehavior: SkipKeyBehavior?,
                            repeatSpeed: SkipKeyRepeatSpeed?,
                            allowVolumeControl: Bool?,
                            allowSeeking: Bool?,
                            allowTrackChange: Bool?,
                            allowPlaylistNavigation: Bool?,
                            allowPlaylistTabToggle: Bool?,
                            volumeControlSensitivity: ScrollSensitivity?,
                            seekSensitivity: ScrollSensitivity?,
                            remoteControlEnabled: Bool?,
                            trackChangeOrSeekingOption: TrackChangeOrSeekingOptions?,
                            httpTimeout: Int?,
                            enableCoverArtSearch: Bool?,
                            enableOnDiskCoverArtCache: Bool?) {
        
        userDefs[PlaylistPreferences.key_viewOnStartupOption] = viewOnStartup?.option.rawValue
        userDefs[PlaylistPreferences.key_viewOnStartupViewName] = viewOnStartup?.viewName
        
        userDefs[PlaylistPreferences.key_playlistOnStartup] = playlistOnStartup?.rawValue
        userDefs[PlaylistPreferences.key_playlistFile] = playlistFile?.path
        userDefs[PlaylistPreferences.key_tracksFolder] = tracksFolder?.path
        
        userDefs[PlaylistPreferences.key_showNewTrackInPlaylist] = showNewTrackInPlaylist
        userDefs[PlaylistPreferences.key_showChaptersList] = showChaptersList
        
        userDefs[PlaybackPreferences.key_primarySeekLengthOption] = primarySeekLengthOption?.rawValue
        userDefs[PlaybackPreferences.key_primarySeekLengthConstant] = primarySeekLengthConstant
        userDefs[PlaybackPreferences.key_primarySeekLengthPercentage] = primarySeekLengthPercentage
        
        userDefs[PlaybackPreferences.key_secondarySeekLengthOption] = secondarySeekLengthOption?.rawValue
        userDefs[PlaybackPreferences.key_secondarySeekLengthConstant] = secondarySeekLengthConstant
        userDefs[PlaybackPreferences.key_secondarySeekLengthPercentage] = secondarySeekLengthPercentage
        
        userDefs[PlaybackPreferences.key_autoplayOnStartup] = autoplayOnStartup
        userDefs[PlaybackPreferences.key_autoplayAfterAddingTracks] = autoplayAfterAddingTracks
        userDefs[PlaybackPreferences.key_autoplayAfterAddingOption] = autoplayAfterAddingOption?.rawValue
        
        userDefs[PlaybackPreferences.key_rememberLastPositionOption] = rememberLastPositionOption?.rawValue
        
        userDefs[SoundPreferences.key_outputDeviceOnStartup_option] = outputDeviceOnStartup?.option.rawValue
        userDefs[SoundPreferences.key_outputDeviceOnStartup_preferredDeviceName] = outputDeviceOnStartup?.preferredDeviceName
        userDefs[SoundPreferences.key_outputDeviceOnStartup_preferredDeviceUID] = outputDeviceOnStartup?.preferredDeviceUID
        
        userDefs[SoundPreferences.key_volumeDelta] = volumeDelta
        userDefs[SoundPreferences.key_volumeOnStartup_option] = volumeOnStartupOption?.rawValue
        userDefs[SoundPreferences.key_volumeOnStartup_value] = startupVolumeValue
        
        userDefs[SoundPreferences.key_panDelta] = panDelta
        
        userDefs[SoundPreferences.key_eqDelta] = eqDelta
        userDefs[SoundPreferences.key_pitchDelta] = pitchDelta
        userDefs[SoundPreferences.key_timeDelta] = timeDelta
        
        userDefs[SoundPreferences.key_effectsSettingsOnStartup_option] = effectsSettingsOnStartupOption?.rawValue
        userDefs[SoundPreferences.key_effectsSettingsOnStartup_masterPreset] = masterPresetOnStartup_name
        userDefs[SoundPreferences.key_rememberEffectsSettingsOption] = rememberEffectsSettingsOption?.rawValue
        
        userDefs[HistoryPreferences.key_recentlyAddedListSize] = recentlyAddedListSize
        userDefs[HistoryPreferences.key_recentlyPlayedListSize] = recentlyPlayedListSize
        
        userDefs[ViewPreferences.key_appModeOnStartup_option] = appModeOnStartup?.option.rawValue
        userDefs[ViewPreferences.key_appModeOnStartup_modeName] = appModeOnStartup?.modeName
        
        userDefs[ViewPreferences.key_layoutOnStartup_option] = layoutOnStartup?.option.rawValue
        userDefs[ViewPreferences.key_layoutOnStartup_layoutName] = layoutOnStartup?.layoutName
        
        userDefs[ViewPreferences.key_snapToWindows] = snapToWindows
        userDefs[ViewPreferences.key_snapToScreen] = snapToScreen
        userDefs[ViewPreferences.key_windowGap] = windowGap
        
        userDefs[MediaKeysControlsPreferences.key_enabled] = mediaKeysEnabled
        userDefs[MediaKeysControlsPreferences.key_skipKeyBehavior] = skipKeyBehavior?.rawValue
        userDefs[MediaKeysControlsPreferences.key_repeatSpeed] = repeatSpeed?.rawValue
        
        userDefs[GesturesControlsPreferences.key_allowPlaylistNavigation] = allowPlaylistNavigation
        userDefs[GesturesControlsPreferences.key_allowPlaylistTabToggle] = allowPlaylistTabToggle
        
        userDefs[GesturesControlsPreferences.key_allowSeeking] = allowSeeking
        userDefs[GesturesControlsPreferences.key_allowTrackChange] = allowTrackChange
        userDefs[GesturesControlsPreferences.key_allowVolumeControl] = allowVolumeControl
        
        userDefs[GesturesControlsPreferences.key_seekSensitivity] = seekSensitivity?.rawValue
        userDefs[GesturesControlsPreferences.key_volumeControlSensitivity] = volumeControlSensitivity?.rawValue
        
        userDefs[RemoteControlPreferences.key_enabled] = remoteControlEnabled
        userDefs[RemoteControlPreferences.key_trackChangeOrSeekingOption] = trackChangeOrSeekingOption?.rawValue
        
        userDefs[MusicBrainzPreferences.key_httpTimeout] = httpTimeout
        userDefs[MusicBrainzPreferences.key_enableCoverArtSearch] = enableCoverArtSearch
        userDefs[MusicBrainzPreferences.key_enableOnDiskCoverArtCache] = enableOnDiskCoverArtCache
        
        let prefs = Preferences(defaults: userDefs)
        
        XCTAssertEqual(prefs.playlistPreferences.viewOnStartup.option,
                       viewOnStartup?.option ?? PlaylistDefaults.viewOnStartup.option)
        
        XCTAssertEqual(prefs.playlistPreferences.viewOnStartup.viewName,
                       viewOnStartup?.viewName ?? PlaylistDefaults.viewOnStartup.viewName)
        
        var expectedPlaylistOnStartup: PlaylistStartupOptions = playlistOnStartup ?? PlaylistDefaults.playlistOnStartup
        var expectedPlaylistFile: URL? = playlistFile ?? PlaylistDefaults.playlistFile
        var expectedTracksFolder: URL? = tracksFolder ?? PlaylistDefaults.tracksFolder
        
        if let thePlaylistOnStartup = playlistOnStartup {
            
            if thePlaylistOnStartup == .loadFile, playlistFile == nil {
                
                expectedPlaylistOnStartup = PlaylistDefaults.playlistOnStartup
                expectedPlaylistFile = PlaylistDefaults.playlistFile
                
            } else if thePlaylistOnStartup == .loadFolder, tracksFolder == nil {
                
                expectedPlaylistOnStartup = PlaylistDefaults.playlistOnStartup
                expectedTracksFolder = PlaylistDefaults.tracksFolder
            }
        }
        
        XCTAssertEqual(prefs.playlistPreferences.playlistOnStartup, expectedPlaylistOnStartup)
        XCTAssertEqual(prefs.playlistPreferences.playlistFile, expectedPlaylistFile)
        XCTAssertEqual(prefs.playlistPreferences.tracksFolder, expectedTracksFolder)
        
        XCTAssertEqual(prefs.playlistPreferences.showNewTrackInPlaylist, showNewTrackInPlaylist ?? PlaylistDefaults.showNewTrackInPlaylist)
        XCTAssertEqual(prefs.playlistPreferences.showChaptersList, showChaptersList ?? PlaylistDefaults.showChaptersList)
        
        XCTAssertEqual(prefs.playbackPreferences.primarySeekLengthOption, primarySeekLengthOption ?? PlaybackDefaults.primarySeekLengthOption)
        XCTAssertEqual(prefs.playbackPreferences.primarySeekLengthConstant, primarySeekLengthConstant ?? PlaybackDefaults.primarySeekLengthConstant)
        XCTAssertEqual(prefs.playbackPreferences.primarySeekLengthPercentage, primarySeekLengthPercentage ?? PlaybackDefaults.primarySeekLengthPercentage)
        
        XCTAssertEqual(prefs.playbackPreferences.secondarySeekLengthOption, secondarySeekLengthOption ?? PlaybackDefaults.secondarySeekLengthOption)
        XCTAssertEqual(prefs.playbackPreferences.secondarySeekLengthConstant, secondarySeekLengthConstant ?? PlaybackDefaults.secondarySeekLengthConstant)
        XCTAssertEqual(prefs.playbackPreferences.secondarySeekLengthPercentage, secondarySeekLengthPercentage ?? PlaybackDefaults.secondarySeekLengthPercentage)
        
        XCTAssertEqual(prefs.playbackPreferences.autoplayOnStartup, autoplayOnStartup ?? PlaybackDefaults.autoplayOnStartup)
        XCTAssertEqual(prefs.playbackPreferences.autoplayAfterAddingTracks, autoplayAfterAddingTracks ?? PlaybackDefaults.autoplayAfterAddingTracks)
        XCTAssertEqual(prefs.playbackPreferences.autoplayAfterAddingOption, autoplayAfterAddingOption ?? PlaybackDefaults.autoplayAfterAddingOption)
        
        XCTAssertEqual(prefs.playbackPreferences.rememberLastPositionOption, rememberLastPositionOption ?? PlaybackDefaults.rememberLastPositionOption)
        
        var expectedOutputDeviceOnStartupOption = outputDeviceOnStartup?.option ?? SoundDefaults.outputDeviceOnStartup.option
        
        if outputDeviceOnStartup?.option == .specific &&
            (outputDeviceOnStartup?.preferredDeviceName == nil || outputDeviceOnStartup?.preferredDeviceUID == nil) {
            
            expectedOutputDeviceOnStartupOption = SoundDefaults.outputDeviceOnStartup.option
        }
        
        XCTAssertEqual(prefs.soundPreferences.outputDeviceOnStartup.option, expectedOutputDeviceOnStartupOption)
        
        XCTAssertEqual(prefs.soundPreferences.outputDeviceOnStartup.preferredDeviceName,
                       outputDeviceOnStartup?.preferredDeviceName ?? SoundDefaults.outputDeviceOnStartup.preferredDeviceName)
        
        XCTAssertEqual(prefs.soundPreferences.outputDeviceOnStartup.preferredDeviceUID,
                       outputDeviceOnStartup?.preferredDeviceUID ?? SoundDefaults.outputDeviceOnStartup.preferredDeviceUID)
        
        XCTAssertEqual(prefs.soundPreferences.volumeDelta, volumeDelta ?? SoundDefaults.volumeDelta)
        XCTAssertEqual(prefs.soundPreferences.volumeOnStartupOption, volumeOnStartupOption ?? SoundDefaults.volumeOnStartupOption)
        XCTAssertEqual(prefs.soundPreferences.startupVolumeValue, startupVolumeValue ?? SoundDefaults.startupVolumeValue)
        
        XCTAssertEqual(prefs.soundPreferences.panDelta, panDelta ?? SoundDefaults.panDelta)
        
        XCTAssertEqual(prefs.soundPreferences.eqDelta, eqDelta ?? SoundDefaults.eqDelta)
        XCTAssertEqual(prefs.soundPreferences.pitchDelta, pitchDelta ?? SoundDefaults.pitchDelta)
        XCTAssertEqual(prefs.soundPreferences.timeDelta, timeDelta ?? SoundDefaults.timeDelta)
        
        var expectedEffectsSettingsOnStartupOption = effectsSettingsOnStartupOption ?? SoundDefaults.effectsSettingsOnStartupOption
        
        if effectsSettingsOnStartupOption == .applyMasterPreset && masterPresetOnStartup_name == nil {
            expectedEffectsSettingsOnStartupOption = SoundDefaults.effectsSettingsOnStartupOption
        }
        
        XCTAssertEqual(prefs.soundPreferences.effectsSettingsOnStartupOption, expectedEffectsSettingsOnStartupOption)
        
        XCTAssertEqual(prefs.soundPreferences.masterPresetOnStartup_name,
                       masterPresetOnStartup_name ?? SoundDefaults.masterPresetOnStartup_name)
        
        XCTAssertEqual(prefs.soundPreferences.rememberEffectsSettingsOption,
                       rememberEffectsSettingsOption ?? SoundDefaults.rememberEffectsSettingsOption)
        
        XCTAssertEqual(prefs.historyPreferences.recentlyAddedListSize, recentlyAddedListSize ?? HistoryDefaults.recentlyAddedListSize)
        XCTAssertEqual(prefs.historyPreferences.recentlyPlayedListSize, recentlyPlayedListSize ?? HistoryDefaults.recentlyPlayedListSize)
        
        var expectedAppModeOnStartup = appModeOnStartup?.option ?? ViewDefaults.appModeOnStartup.option
        
        if expectedAppModeOnStartup == .specific && appModeOnStartup?.modeName == nil {
            expectedAppModeOnStartup = ViewDefaults.appModeOnStartup.option
        }
        
        XCTAssertEqual(prefs.viewPreferences.appModeOnStartup.option, expectedAppModeOnStartup)
        
        XCTAssertEqual(prefs.viewPreferences.appModeOnStartup.modeName,
                       appModeOnStartup?.modeName ?? ViewDefaults.appModeOnStartup.modeName)
        
        var expectedLayoutOnStartup = layoutOnStartup?.option ?? ViewDefaults.layoutOnStartup.option
        
        if expectedLayoutOnStartup == .specific && layoutOnStartup?.layoutName == nil {
            expectedLayoutOnStartup = ViewDefaults.layoutOnStartup.option
        }
        
        XCTAssertEqual(prefs.viewPreferences.layoutOnStartup.option,
                       expectedLayoutOnStartup)
        
        XCTAssertEqual(prefs.viewPreferences.layoutOnStartup.layoutName,
                       layoutOnStartup?.layoutName ?? ViewDefaults.layoutOnStartup.layoutName)
        
        XCTAssertEqual(prefs.viewPreferences.snapToWindows, snapToWindows ?? ViewDefaults.snapToWindows)
        XCTAssertEqual(prefs.viewPreferences.snapToScreen, snapToScreen ?? ViewDefaults.snapToScreen)
        XCTAssertEqual(prefs.viewPreferences.windowGap, windowGap ?? ViewDefaults.windowGap)
        
        XCTAssertEqual(prefs.controlsPreferences.mediaKeys.enabled,
                       mediaKeysEnabled ?? MediaKeysDefaults.enabled)
        
        XCTAssertEqual(prefs.controlsPreferences.mediaKeys.skipKeyBehavior,
                       skipKeyBehavior ?? MediaKeysDefaults.skipKeyBehavior)
        
        XCTAssertEqual(prefs.controlsPreferences.mediaKeys.repeatSpeed,
                       repeatSpeed ?? MediaKeysDefaults.repeatSpeed)
        
        XCTAssertEqual(prefs.controlsPreferences.gestures.allowPlaylistNavigation,
                       allowPlaylistNavigation ?? GesturesDefaults.allowPlaylistNavigation)
        
        XCTAssertEqual(prefs.controlsPreferences.gestures.allowPlaylistTabToggle,
                       allowPlaylistTabToggle ?? GesturesDefaults.allowPlaylistTabToggle)
        
        XCTAssertEqual(prefs.controlsPreferences.gestures.allowSeeking,
                       allowSeeking ?? GesturesDefaults.allowSeeking)
        
        XCTAssertEqual(prefs.controlsPreferences.gestures.allowTrackChange,
                       allowTrackChange ?? GesturesDefaults.allowTrackChange)
        
        XCTAssertEqual(prefs.controlsPreferences.gestures.allowVolumeControl,
                       allowVolumeControl ?? GesturesDefaults.allowVolumeControl)
        
        XCTAssertEqual(prefs.controlsPreferences.gestures.seekSensitivity,
                       seekSensitivity ?? GesturesDefaults.seekSensitivity)
        
        XCTAssertEqual(prefs.controlsPreferences.gestures.volumeControlSensitivity,
                       volumeControlSensitivity ?? GesturesDefaults.volumeControlSensitivity)
        
        XCTAssertEqual(prefs.controlsPreferences.remoteControl.enabled,
                       remoteControlEnabled ?? RemoteControlDefaults.enabled)
        
        XCTAssertEqual(prefs.controlsPreferences.remoteControl.trackChangeOrSeekingOption,
                       trackChangeOrSeekingOption ?? RemoteControlDefaults.trackChangeOrSeekingOption)
        
        XCTAssertEqual(prefs.metadataPreferences.musicBrainz.httpTimeout, httpTimeout ?? MusicBrainzDefaults.httpTimeout)
        XCTAssertEqual(prefs.metadataPreferences.musicBrainz.enableCoverArtSearch, enableCoverArtSearch ?? MusicBrainzDefaults.enableCoverArtSearch)
        XCTAssertEqual(prefs.metadataPreferences.musicBrainz.enableOnDiskCoverArtCache, enableOnDiskCoverArtCache ?? MusicBrainzDefaults.enableOnDiskCoverArtCache)
    }
    
    // MARK: persist() tests ------------------------------
    
    func testPersist() {

        for _ in 1...100 {

            let defaults = UserDefaults()
            doTestPersist(prefs: randomPreferences(defaults: defaults), userDefs: defaults)
        }
    }

    func testPersist_serializeAndDeserialize() {
        
        for _ in 1...100 {
            
            let userDefs: UserDefaults = UserDefaults()
            let serializedPrefs = randomPreferences(defaults: userDefs)
            doTestPersist(prefs: serializedPrefs, userDefs: userDefs)
            
            let deserializedPrefs = Preferences(defaults: userDefs)
            compare(prefs: deserializedPrefs, userDefs: userDefs)
        }
    }
    
    private func doTestPersist(prefs: Preferences, userDefs: UserDefaults) {
        
        prefs.persist()
        compare(prefs: prefs, userDefs: userDefs)
    }
    
    private func compare(prefs: Preferences, userDefs: UserDefaults) {
        
        compare(prefs: prefs.playlistPreferences, userDefs: userDefs)
        compare(prefs: prefs.playbackPreferences, userDefs: userDefs)
        compare(prefs: prefs.soundPreferences, userDefs: userDefs)
        compare(prefs: prefs.viewPreferences, userDefs: userDefs)
        compare(prefs: prefs.historyPreferences, userDefs: userDefs)
        compare(prefs: prefs.controlsPreferences, userDefs: userDefs)
        compare(prefs: prefs.metadataPreferences, userDefs: userDefs)
    }
    
    private func randomPreferences(defaults: UserDefaults) -> Preferences {
        
        let prefs = Preferences(defaults: defaults)
        
        prefs.playlistPreferences = randomPlaylistPreferences()
        prefs.playbackPreferences = randomPlaybackPreferences()
        prefs.soundPreferences = randomSoundPreferences()
        prefs.historyPreferences = randomHistoryPreferences()
        prefs.viewPreferences = randomViewPreferences()
        prefs.controlsPreferences = randomControlsPreferences()
        prefs.metadataPreferences = randomMetadataPreferences()
        
        return prefs
    }
}
