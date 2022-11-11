//
//  PreferencesTestCase.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class PreferencesTestCase: AuralTestCase {
    
    // MARK: Playlist preferences ------------------------------
    
    func compare(prefs: PlaylistPreferences, userDefs: UserDefaults) {
        
        XCTAssertEqual(userDefs.string(forKey: PlaylistPreferences.key_playlistOnStartup), prefs.playlistOnStartup.rawValue)
        XCTAssertEqual(userDefs.string(forKey: PlaylistPreferences.key_playlistFile), prefs.playlistFile?.path)
        XCTAssertEqual(userDefs.string(forKey: PlaylistPreferences.key_tracksFolder), prefs.tracksFolder?.path)
        
        XCTAssertEqual(userDefs.string(forKey: PlaylistPreferences.key_viewOnStartupOption), prefs.viewOnStartup.option.rawValue)
        XCTAssertEqual(userDefs.string(forKey: PlaylistPreferences.key_viewOnStartupViewName), prefs.viewOnStartup.viewName)
        
        XCTAssertEqual(userDefs.bool(forKey: PlaylistPreferences.key_showNewTrackInPlaylist), prefs.showNewTrackInPlaylist)
        XCTAssertEqual(userDefs.bool(forKey: PlaylistPreferences.key_showChaptersList), prefs.showChaptersList)
    }
    
    func randomPlaylistPreferences() -> PlaylistPreferences {
        
        let prefs = PlaylistPreferences([:])
        
        let playlistStartupOptions = randomPlaylistStartupOptions()
        
        prefs.playlistOnStartup = playlistStartupOptions.option
        prefs.playlistFile = playlistStartupOptions.playlistFile
        prefs.tracksFolder = playlistStartupOptions.tracksFolder
        
        prefs.viewOnStartup = randomPlaylistViewOnStartup()
        
        prefs.showNewTrackInPlaylist = .random()
        prefs.showChaptersList = .random()
        
        return prefs
    }
    
    func randomPlaylistStartupOptions() -> (option: PlaylistStartupOptions, playlistFile: URL?, tracksFolder: URL?) {
        
        let playlistOnStartup: PlaylistStartupOptions = .randomCase()
        
        var playlistFile: URL? = nil
        var tracksFolder: URL? = nil
        
        switch playlistOnStartup {
        
        case .loadFile:
            
            playlistFile = URL(fileURLWithPath: randomPlaylistFile())
            
        case .loadFolder:
            
            tracksFolder = URL(fileURLWithPath: randomFolder())
            
        default:
            
            playlistFile = nil
            tracksFolder = nil
        }
        
        return (playlistOnStartup, playlistFile, tracksFolder)
    }
    
    func randomNillablePlaylistStartupOptions() -> PlaylistStartupOptions? {
        randomNillableValue {.randomCase()}
    }
    
    func randomNillablePlaylistFile() -> URL? {
        randomNillableValue {URL(fileURLWithPath: randomPlaylistFile())}
    }
    
    func randomNillableTracksFolder() -> URL? {
        randomNillableValue {URL(fileURLWithPath: randomFolder())}
    }
    
    static let playlistViewNames: [String] = ["Tracks", "Artists", "Albums", "Genres"]
    
    func randomPlaylistViewOnStartup() -> PlaylistViewOnStartup {
        
        let viewOnStartup = PlaylistViewOnStartup()
        
        viewOnStartup.option = .randomCase()
        viewOnStartup.viewName = Self.playlistViewNames.randomElement()
        
        return viewOnStartup
    }
    
    func randomNillablePlaylistViewOnStartup() -> PlaylistViewOnStartup? {
        randomNillableValue {self.randomPlaylistViewOnStartup()}
    }
    
    // MARK: Playback preferences ------------------------------
    
    func compare(prefs: PlaybackPreferences, userDefs: UserDefaults) {
        
        XCTAssertEqual(userDefs.string(forKey: PlaybackPreferences.key_primarySeekLengthOption), prefs.primarySeekLengthOption.rawValue)
        XCTAssertEqual(userDefs.integer(forKey: PlaybackPreferences.key_primarySeekLengthConstant), prefs.primarySeekLengthConstant)
        XCTAssertEqual(userDefs.integer(forKey: PlaybackPreferences.key_primarySeekLengthPercentage), prefs.primarySeekLengthPercentage)
        
        XCTAssertEqual(userDefs.string(forKey: PlaybackPreferences.key_secondarySeekLengthOption), prefs.secondarySeekLengthOption.rawValue)
        XCTAssertEqual(userDefs.integer(forKey: PlaybackPreferences.key_secondarySeekLengthConstant), prefs.secondarySeekLengthConstant)
        XCTAssertEqual(userDefs.integer(forKey: PlaybackPreferences.key_secondarySeekLengthPercentage), prefs.secondarySeekLengthPercentage)
        
        XCTAssertEqual(userDefs.bool(forKey: PlaybackPreferences.key_autoplayOnStartup), prefs.autoplayOnStartup)
        XCTAssertEqual(userDefs.bool(forKey: PlaybackPreferences.key_autoplayAfterAddingTracks), prefs.autoplayAfterAddingTracks)
        XCTAssertEqual(userDefs.string(forKey: PlaybackPreferences.key_autoplayAfterAddingOption), prefs.autoplayAfterAddingOption.rawValue)
        
        XCTAssertEqual(userDefs.string(forKey: PlaybackPreferences.key_rememberLastPositionOption), prefs.rememberLastPositionOption.rawValue)
    }
    
    func randomPlaybackPreferences() -> PlaybackPreferences {
        
        let prefs = PlaybackPreferences([:])
        
        prefs.primarySeekLengthOption = randomSeekLengthOption()
        prefs.primarySeekLengthConstant = randomSeekLengthConstant()
        prefs.primarySeekLengthPercentage = randomPercentage()
        prefs.secondarySeekLengthOption = randomSeekLengthOption()
        prefs.secondarySeekLengthConstant = randomSeekLengthConstant()
        prefs.secondarySeekLengthPercentage = randomPercentage()
        prefs.autoplayOnStartup = .random()
        prefs.autoplayAfterAddingTracks = .random()
        prefs.autoplayAfterAddingOption = randomAutoplayAfterAddingOption()
        prefs.rememberLastPositionOption = randomRememberLastPositionOption()
        
        return prefs
    }
    
    func randomNillableSeekLengthConstant() -> Int? {
        randomNillableValue {self.randomSeekLengthConstant()}
    }
    
    func randomSeekLengthConstant() -> Int {Int.random(in: 1...3600)}
    
    func randomPercentage() -> Int {Int.random(in: 1...100)}
    
    func randomNillablePercentage() -> Int? {
        randomNillableValue {self.randomPercentage()}
    }
    
    func randomSeekLengthOption() -> SeekLengthOptions {SeekLengthOptions.randomCase()}
    
    func randomNillableSeekLengthOption() -> SeekLengthOptions? {
        randomNillableValue {self.randomSeekLengthOption()}
    }
    
    func randomAutoplayAfterAddingOption() -> AutoplayAfterAddingOptions {AutoplayAfterAddingOptions.randomCase()}
    
    func randomNillableAutoplayAfterAddingOption() -> AutoplayAfterAddingOptions? {
        randomNillableValue {self.randomAutoplayAfterAddingOption()}
    }
    
    func randomRememberLastPositionOption() -> RememberSettingsForTrackOptions {RememberSettingsForTrackOptions.randomCase()}
    
    func randomNillableRememberLastPositionOption() -> RememberSettingsForTrackOptions? {
        randomNillableValue {self.randomRememberLastPositionOption()}
    }
    
    // MARK: Sound preferences ------------------------------
    
    func compare(prefs: SoundPreferences, userDefs: UserDefaults) {
        
        XCTAssertEqual(userDefs.string(forKey: SoundPreferences.key_outputDeviceOnStartup_option),
                       prefs.outputDeviceOnStartup.option.rawValue)
        
        XCTAssertEqual(userDefs.string(forKey: SoundPreferences.key_outputDeviceOnStartup_preferredDeviceName),
                       prefs.outputDeviceOnStartup.preferredDeviceName)
        
        XCTAssertEqual(userDefs.string(forKey: SoundPreferences.key_outputDeviceOnStartup_preferredDeviceUID),
                       prefs.outputDeviceOnStartup.preferredDeviceUID)
        
        XCTAssertEqual(userDefs.float(forKey: SoundPreferences.key_volumeDelta), prefs.volumeDelta)
        
        XCTAssertEqual(userDefs.string(forKey: SoundPreferences.key_volumeOnStartup_option),
                       prefs.volumeOnStartupOption.rawValue)
        
        XCTAssertEqual(userDefs.float(forKey: SoundPreferences.key_volumeOnStartup_value),
                       prefs.startupVolumeValue)
        
        XCTAssertEqual(userDefs.float(forKey: SoundPreferences.key_panDelta), prefs.panDelta)
        
        XCTAssertEqual(userDefs.float(forKey: SoundPreferences.key_eqDelta), prefs.eqDelta)
        XCTAssertEqual(userDefs.integer(forKey: SoundPreferences.key_pitchDelta), prefs.pitchDelta)
        XCTAssertEqual(userDefs.float(forKey: SoundPreferences.key_timeDelta), prefs.timeDelta)
        
        XCTAssertEqual(userDefs.string(forKey: SoundPreferences.key_effectsSettingsOnStartup_option),
                       prefs.effectsSettingsOnStartupOption.rawValue)
        
        XCTAssertEqual(userDefs.string(forKey: SoundPreferences.key_effectsSettingsOnStartup_masterPreset),
                       prefs.masterPresetOnStartup_name)
        
        XCTAssertEqual(userDefs.string(forKey: SoundPreferences.key_rememberEffectsSettingsOption),
                       prefs.rememberEffectsSettingsOption.rawValue)
    }
    
    func randomSoundPreferences() -> SoundPreferences {
        
        let prefs = SoundPreferences([:])
        
        prefs.outputDeviceOnStartup = randomOutputDevice()
        
        prefs.volumeDelta = randomVolumeDelta()
        prefs.volumeOnStartupOption = .randomCase()
        prefs.startupVolumeValue = randomStartupVolumeValue()
        
        prefs.panDelta = randomPanDelta()
        
        prefs.eqDelta = randomEQDelta()
        prefs.pitchDelta = randomPitchDelta()
        prefs.timeDelta = randomTimeDelta()
        
        prefs.effectsSettingsOnStartupOption = .randomCase()
        prefs.masterPresetOnStartup_name = randomMasterPresetName()
        
        prefs.rememberEffectsSettingsOption = .randomCase()
        
        return prefs
    }
    
    func randomOutputDevice() -> OutputDeviceOnStartup {
        
        let device = OutputDeviceOnStartup()
        
        device.option = .randomCase()
        device.preferredDeviceName = randomDeviceName()
        device.preferredDeviceUID = randomDeviceUID()
        
        return device
    }
    
    func randomDeviceName() -> String {
        randomString(length: Int.random(in: 10...30))
    }
    
    func randomDeviceUID() -> String {
        UUID().uuidString
    }
    
    func randomNillableOutputDevice() -> OutputDeviceOnStartup? {
        randomNillableValue {self.randomOutputDevice()}
    }
    
    func randomNillableVolumeStartupOptions() -> VolumeStartupOptions? {
        randomNillableValue {.randomCase()}
    }
    
    func randomNillableEffectsSettingsStartupOptions() -> EffectsSettingsStartupOptions? {
        randomNillableValue {.randomCase()}
    }
    
    func randomNillableRememberSettingsForTrackOptions() -> RememberSettingsForTrackOptions? {
        randomNillableValue {.randomCase()}
    }

    func randomVolumeDelta() -> Float {
        Float.random(in: 1...25) * ValueConversions.volume_UIToAudioGraph
    }
    
    func randomNillableVolumeDelta() -> Float? {
        randomNillableValue {self.randomVolumeDelta()}
    }
    
    func randomStartupVolumeValue() -> Float {
        Float.random(in: 0...1)
    }
    
    func randomNillableStartupVolumeValue() -> Float? {
        randomNillableValue {self.randomStartupVolumeValue()}
    }
    
    func randomPanDelta() -> Float {
        Float.random(in: 1...25) * ValueConversions.pan_UIToAudioGraph
    }
    
    func randomNillablePanDelta() -> Float? {
        randomNillableValue {self.randomPanDelta()}
    }
    
    func randomEQDelta() -> Float {
        Float.random(in: 0.1...5)
    }
    
    func randomNillableEQDelta() -> Float? {
        randomNillableValue {self.randomEQDelta()}
    }
    
    func randomPitchDelta() -> Int {
        Int.random(in: 5...2400)
    }
    
    func randomNillablePitchDelta() -> Int? {
        randomNillableValue {self.randomPitchDelta()}
    }
    
    func randomTimeDelta() -> Float {
        Float.random(in: 0.01...1)
    }
    
    func randomNillableTimeDelta() -> Float? {
        randomNillableValue {self.randomTimeDelta()}
    }
    
    func randomMasterPresetName() -> String {
        randomString(length: Int.random(in: 5...25))
    }
    
    func randomNillableMasterPresetName() -> String? {
        randomNillableValue {self.randomMasterPresetName()}
    }
    
    // MARK: History preferences ------------------------------
    
    func compare(prefs: HistoryPreferences, userDefs: UserDefaults) {
        
        XCTAssertEqual(userDefs.integer(forKey: HistoryPreferences.key_recentlyAddedListSize), prefs.recentlyAddedListSize)
        XCTAssertEqual(userDefs.integer(forKey: HistoryPreferences.key_recentlyPlayedListSize), prefs.recentlyPlayedListSize)
    }
    
    func randomHistoryPreferences() -> HistoryPreferences {
        
        let prefs = HistoryPreferences([:])
        
        prefs.recentlyAddedListSize = randomHistoryListSize()
        prefs.recentlyPlayedListSize = randomHistoryListSize()
        
        return prefs
    }
    
    func randomNillableHistoryListSize() -> Int? {
        randomNillableValue {self.randomHistoryListSize()}
    }
    
    func randomHistoryListSize() -> Int {Int.random(in: 10...100)}
    
    // MARK: View preferences ------------------------------
    
    func compare(prefs: ViewPreferences, userDefs: UserDefaults) {
        
        XCTAssertEqual(userDefs.string(forKey: ViewPreferences.key_appModeOnStartup_option),
                       prefs.appModeOnStartup.option.rawValue)
        
        XCTAssertEqual(userDefs.string(forKey: ViewPreferences.key_appModeOnStartup_modeName),
                       prefs.appModeOnStartup.modeName)
        
        XCTAssertEqual(userDefs.string(forKey: ViewPreferences.key_layoutOnStartup_option),
                       prefs.layoutOnStartup.option.rawValue)
        
        XCTAssertEqual(userDefs.string(forKey: ViewPreferences.key_layoutOnStartup_layoutName),
                       prefs.layoutOnStartup.layoutName)
        
        XCTAssertEqual(userDefs.bool(forKey: ViewPreferences.key_snapToWindows), prefs.snapToWindows)
        XCTAssertEqual(userDefs.bool(forKey: ViewPreferences.key_snapToScreen), prefs.snapToScreen)
        XCTAssertEqual(userDefs.float(forKey: ViewPreferences.key_windowGap), prefs.windowGap)
    }
    
    func randomViewPreferences() -> ViewPreferences {
        
        let prefs = ViewPreferences([:])
        
        prefs.appModeOnStartup = randomAppModeOnStartup()
        prefs.layoutOnStartup = randomLayoutOnStartup()
        
        prefs.snapToWindows = .random()
        prefs.snapToScreen = .random()
        prefs.windowGap = randomWindowGap()
        
        return prefs
    }
    
    func randomAppModeOnStartup() -> AppModeOnStartup {
        
        let appMode = AppModeOnStartup()
        
        appMode.option = .randomCase()
        appMode.modeName = randomAppModeName()
        
        return appMode
    }
    
    func randomLayoutOnStartup() -> LayoutOnStartup {
        
        let layout = LayoutOnStartup()
        
        layout.option = .randomCase()
        layout.layoutName = randomLayoutName()
        
        return layout
    }
    
    func randomAppModeName() -> String {
        randomString(length: Int.random(in: 10...30))
    }
    
    func randomLayoutName() -> String {
        randomString(length: Int.random(in: 10...30))
    }
    
    func randomNillableAppModeOnStartup() -> AppModeOnStartup? {
        randomNillableValue {self.randomAppModeOnStartup()}
    }
    
    func randomNillableLayoutOnStartup() -> LayoutOnStartup? {
        randomNillableValue {self.randomLayoutOnStartup()}
    }
    
    func randomWindowGap() -> Float {
        Float.random(in: 0...25)
    }
    
    func randomNillableWindowGap() -> Float? {
        randomNillableValue {self.randomWindowGap()}
    }
    
    // MARK: Metadata preferences ------------------------
    
    func compare(prefs: MetadataPreferences, userDefs: UserDefaults) {
        compare(prefs: prefs.musicBrainz, userDefs: userDefs)
    }
    
    func randomMetadataPreferences() -> MetadataPreferences {
        
        let prefs = MetadataPreferences([:])
        prefs.musicBrainz = randomMusicBrainzPreferences()
        
        return prefs
    }
    
    // MARK: MusicBrainz preferences ------------------------
    
    func compare(prefs: MusicBrainzPreferences, userDefs: UserDefaults) {
        
        XCTAssertEqual(userDefs.integer(forKey: MusicBrainzPreferences.key_httpTimeout), prefs.httpTimeout)
        XCTAssertEqual(userDefs.bool(forKey: MusicBrainzPreferences.key_enableCoverArtSearch), prefs.enableCoverArtSearch)
        XCTAssertEqual(userDefs.bool(forKey: MusicBrainzPreferences.key_enableOnDiskCoverArtCache), prefs.enableOnDiskCoverArtCache)
    }
    
    func randomMusicBrainzPreferences() -> MusicBrainzPreferences {
        
        let prefs = MusicBrainzPreferences([:])
        
        prefs.httpTimeout = randomHTTPTimeout()
        prefs.enableCoverArtSearch = .random()
        prefs.enableOnDiskCoverArtCache = .random()
        
        return prefs
    }
    
    func randomNillableHTTPTimeout() -> Int? {
        randomNillableValue {self.randomHTTPTimeout()}
    }
    
    func randomHTTPTimeout() -> Int {Int.random(in: 1...60)}
    
    // MARK: Controls preferences ---------------------------------
    
    func compare(prefs: ControlsPreferences, userDefs: UserDefaults) {
        
        compare(prefs: prefs.mediaKeys, userDefs: userDefs)
        compare(prefs: prefs.gestures, userDefs: userDefs)
        compare(prefs: prefs.remoteControl, userDefs: userDefs)
    }
    
    func randomControlsPreferences() -> ControlsPreferences {
        
        let prefs = ControlsPreferences([:])
        
        prefs.mediaKeys = randomMediaKeysPreferences()
        prefs.gestures = randomGesturesPreferences()
        prefs.remoteControl = randomRemoteControlPreferences()
        
        return prefs
    }
    
    // MARK: Media Keys preferences -------------------------------
    
    func compare(prefs: MediaKeysControlsPreferences, userDefs: UserDefaults) {
        
        XCTAssertEqual(userDefs.bool(forKey: MediaKeysControlsPreferences.key_enabled), prefs.enabled)
        XCTAssertEqual(userDefs.string(forKey: MediaKeysControlsPreferences.key_skipKeyBehavior), prefs.skipKeyBehavior.rawValue)
        XCTAssertEqual(userDefs.string(forKey: MediaKeysControlsPreferences.key_repeatSpeed), prefs.repeatSpeed.rawValue)
    }
    
    func randomMediaKeysPreferences() -> MediaKeysControlsPreferences {
        
        let prefs = MediaKeysControlsPreferences([:])
        
        prefs.enabled = .random()
        prefs.skipKeyBehavior = randomSkipKeyBehavior()
        prefs.repeatSpeed = randomRepeatSpeed()
        
        return prefs
    }
    
    func randomSkipKeyBehavior() -> SkipKeyBehavior {SkipKeyBehavior.randomCase()}
    
    func randomNillableSkipKeyBehavior() -> SkipKeyBehavior? {
        randomNillableValue {self.randomSkipKeyBehavior()}
    }
    
    func randomRepeatSpeed() -> SkipKeyRepeatSpeed {SkipKeyRepeatSpeed.randomCase()}
    
    func randomNillableRepeatSpeed() -> SkipKeyRepeatSpeed? {
        randomNillableValue {self.randomRepeatSpeed()}
    }
    
    // MARK: Remote Control preferences ------------------------------
    
    func compare(prefs: RemoteControlPreferences, userDefs: UserDefaults) {
        
        XCTAssertEqual(userDefs.bool(forKey: RemoteControlPreferences.key_enabled), prefs.enabled)
        XCTAssertEqual(userDefs.string(forKey: RemoteControlPreferences.key_trackChangeOrSeekingOption), prefs.trackChangeOrSeekingOption.rawValue)
    }
    
    func randomRemoteControlPreferences() -> RemoteControlPreferences {
        
        let prefs = RemoteControlPreferences([:])
        
        prefs.enabled = .random()
        prefs.trackChangeOrSeekingOption = randomTrackChangeOrSeekingOption()
        
        return prefs
    }
    
    func randomTrackChangeOrSeekingOption() -> TrackChangeOrSeekingOptions {TrackChangeOrSeekingOptions.randomCase()}
    
    func randomNillableTrackChangeOrSeekingOption() -> TrackChangeOrSeekingOptions? {
        randomNillableValue {self.randomTrackChangeOrSeekingOption()}
    }
    
    // MARK: Gestures preferences ------------------------------
    
    func randomGesturesPreferences() -> GesturesControlsPreferences {
        
        let prefs = GesturesControlsPreferences([:])
        
        prefs.allowPlaylistNavigation = .random()
        prefs.allowPlaylistTabToggle = .random()
        prefs.allowSeeking = .random()
        prefs.allowTrackChange = .random()
        prefs.allowVolumeControl = .random()
        
        prefs.seekSensitivity = .randomCase()
        prefs.volumeControlSensitivity = .randomCase()
        
        return prefs
    }
    
    func randomNillableScrollSensitivity() -> ScrollSensitivity? {
        randomNillableValue {.randomCase()}
    }
    
    func compare(prefs: GesturesControlsPreferences, userDefs: UserDefaults) {
        
        XCTAssertEqual(userDefs.bool(forKey: GesturesControlsPreferences.key_allowPlaylistNavigation),
                       prefs.allowPlaylistNavigation)
        
        XCTAssertEqual(userDefs.bool(forKey: GesturesControlsPreferences.key_allowPlaylistTabToggle),
                       prefs.allowPlaylistTabToggle)
        
        XCTAssertEqual(userDefs.bool(forKey: GesturesControlsPreferences.key_allowSeeking),
                       prefs.allowSeeking)
        
        XCTAssertEqual(userDefs.bool(forKey: GesturesControlsPreferences.key_allowTrackChange),
                       prefs.allowTrackChange)
        
        XCTAssertEqual(userDefs.bool(forKey: GesturesControlsPreferences.key_allowVolumeControl),
                       prefs.allowVolumeControl)
        
        XCTAssertEqual(userDefs.string(forKey: GesturesControlsPreferences.key_seekSensitivity),
                       prefs.seekSensitivity.rawValue)
        
        XCTAssertEqual(userDefs.string(forKey: GesturesControlsPreferences.key_volumeControlSensitivity),
                       prefs.volumeControlSensitivity.rawValue)
    }
}
