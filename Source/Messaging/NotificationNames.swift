import Foundation

extension Notification.Name {
    
    static let appLaunched = Notification.Name("appLaunched")
    static let appReopened = Notification.Name("appReopened")
    static let appExitRequest = Notification.Name("appExitRequest")
    
    static let windowLayoutChanged = Notification.Name("windowLayoutChanged")
    
    static let trackAddedToFavorites = Notification.Name("trackAddedToFavorites")
    static let trackRemovedFromFavorites = Notification.Name("trackRemovedFromFavorites")
    
    static let historyItemsAdded = Notification.Name("historyItemsAdded")
    static let historyUpdated = Notification.Name("historyUpdated")
    
    static let fxUnitActivated = Notification.Name("fxUnitActivated")
    static let fxUnitStateChanged = Notification.Name("fxUnitStateChanged")
    
    static let playbackRateChanged = Notification.Name("playbackRateChanged")
    static let chapterChanged = Notification.Name("chapterChanged")
    static let playbackCompleted = Notification.Name("playbackCompleted")
    static let trackNotPlayed = Notification.Name("trackNotPlayed")
    static let preTrackChange = Notification.Name("preTrackChange")
    
    static let transcodingProgress = Notification.Name("transcodingProgress")
    
    static let startedAddingTracks = Notification.Name("startedAddingTracks")
    static let doneAddingTracks = Notification.Name("doneAddingTracks")
    static let tracksNotAdded = Notification.Name("tracksNotAdded")
    
    static let playlistTypeChanged = Notification.Name("playlistTypeChanged")
    
    static let searchTextChanged = Notification.Name("searchTextChanged")
    
    static let trackAdded = Notification.Name("trackAdded")
    static let tracksRemoved = Notification.Name("tracksRemoved")
    static let gapUpdated = Notification.Name("gapUpdated")
    
    static let trackTransition = Notification.Name("trackTransition")
    static let trackInfoUpdated = Notification.Name("trackInfoUpdated")
    static let trackNotTranscoded = Notification.Name("trackNotTranscoded")
    static let transcodingFinished = Notification.Name("transcodingFinished")
    static let playingTrackInfoUpdated = Notification.Name("playingTrackInfoUpdated")
    static let playbackLoopChanged = Notification.Name("playbackLoopChanged")
    
    static let audioOutputChanged = Notification.Name("audioOutputChanged")
    
    static let editorSelectionChanged = Notification.Name("editorSelectionChanged")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Playback commands
    
    static let player_playTrack = Notification.Name("player_playTrack")
    
    // Play, pause, or resume playback
    static let player_playOrPause = Notification.Name("player_playOrPause")

    // Stop playback
    static let player_stop = Notification.Name("player_stop")

    // Play the previous track in the current playback sequence
    static let player_previousTrack = Notification.Name("player_previousTrack")

    // Play the next track in the current playback sequence
    static let player_nextTrack = Notification.Name("player_nextTrack")

    // Replay the currently playing track from the beginning, if there is one
    static let player_replayTrack = Notification.Name("player_replayTrack")

    // Seek backward within the currently playing track
    static let player_seekBackward = Notification.Name("player_seekBackward")

    // Seek forward within the currently playing track
    static let player_seekForward = Notification.Name("player_seekForward")

    // Seek backward within the currently playing track (secondary seek function - allows a different seek interval)
    static let player_seekBackward_secondary = Notification.Name("player_seekBackward_secondary")

    // Seek forward within the currently playing track (secondary seek function - allows a different seek interval)
    static let player_seekForward_secondary = Notification.Name("player_seekForward_secondary")

    // Seek to a specific position within the currently playing track
    static let player_jumpToTime = Notification.Name("player_jumpToTime")
    
    // Toggle A->B segment playback loop
    static let player_toggleLoop = Notification.Name("player_toggleLoop")
    
    
    // MARK: Chapter playback commands
    
    static let player_playChapter = Notification.Name("player_playChapter")
    
    // Play the previous available chapter
    static let player_previousChapter = Notification.Name("player_previousChapter")
    
    // Play the next available chapter
    static let player_nextChapter = Notification.Name("player_nextChapter")
    
    // Replay the currently playing chapter from the beginning, if there is one
    static let player_replayChapter = Notification.Name("player_replayChapter")
    
    // Toggle the current chapter playback loop
    static let player_toggleChapterLoop = Notification.Name("player_toggleChapterLoop")
    
    

    static let player_savePlaybackProfile = Notification.Name("player_savePlaybackProfile")

    static let player_deletePlaybackProfile = Notification.Name("player_deletePlaybackProfile")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Player sound commands
    
    // Mute or unmute the player
    static let player_muteOrUnmute = Notification.Name("player_muteOrUnmute")
    
    // Decreases the volume by a certain preset decrement
    static let player_decreaseVolume = Notification.Name("player_decreaseVolume")

    // Increases the volume by a certain preset increment
    static let player_increaseVolume = Notification.Name("player_increaseVolume")

    // Pans the sound towards the left channel, by a certain preset value
    static let player_panLeft = Notification.Name("player_panLeft")

    // Pans the sound towards the right channel, by a certain preset value
    static let player_panRight = Notification.Name("player_panRight")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Player sequencing commands
    
    // Set repeat mode (to a specific value)
    static let player_setRepeatMode = Notification.Name("player_setRepeatMode")
    
    // Set shuffle mode (to a specific value)
    static let player_setShuffleMode = Notification.Name("player_setShuffleMode")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Player view commands
    
    static let player_changeView = Notification.Name("player_changeView")

    static let player_showOrHideAlbumArt = Notification.Name("player_showOrHideAlbumArt")

    static let player_showOrHideArtist = Notification.Name("player_showOrHideArtist")

    static let player_showOrHideAlbum = Notification.Name("player_showOrHideAlbum")

    static let player_showOrHideCurrentChapter = Notification.Name("player_showOrHideCurrentChapter")

    static let player_showOrHidePlayingTrackInfo = Notification.Name("player_showOrHidePlayingTrackInfo")

    static let player_showOrHidePlayingTrackFunctions = Notification.Name("player_showOrHidePlayingTrackFunctions")

    static let player_showOrHideMainControls = Notification.Name("player_showOrHideMainControls")
    
    
    static let player_showOrHideTimeElapsedRemaining = Notification.Name("player_showOrHideTimeElapsedRemaining")

    static let player_setTimeElapsedDisplayFormat = Notification.Name("player_setTimeElapsedDisplayFormat")

    static let player_setTimeRemainingDisplayFormat = Notification.Name("player_setTimeRemainingDisplayFormat")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Playing track commands
    
    // Show detailed info for the currently playing track
    static let player_moreInfo = Notification.Name("player_moreInfo")
    
    static let player_bookmarkPosition = Notification.Name("player_bookmarkPosition")

    static let player_bookmarkLoop = Notification.Name("player_bookmarkLoop")
    
    static let player_addOrRemoveFavorite = Notification.Name("player_addOrRemoveFavorite")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Playlist commands
    
    static let playlist_refresh = Notification.Name("playlist_refresh")
    

    // Invoke the file dialog to add tracks to the playlist
    static let playlist_addTracks = Notification.Name("playlist_addTracks")

    static let playlist_removeTracks = Notification.Name("playlist_removeTracks")

    // Save playlist to file
    static let playlist_savePlaylist = Notification.Name("playlist_savePlaylist")

    // Clear the playlist of all tracks
    static let playlist_clearPlaylist = Notification.Name("playlist_clearPlaylist")
    

    static let playlist_playSelectedItem = Notification.Name("playlist_playSelectedItem")

    static let playlist_playSelectedItemWithDelay = Notification.Name("playlist_playSelectedItemWithDelay")
    

    static let playlist_insertGaps = Notification.Name("playlist_insertGaps")

    static let playlist_removeGaps = Notification.Name("playlist_removeGaps")
    

    static let playlist_moveTracksUp = Notification.Name("playlist_moveTracksUp")

    static let playlist_moveTracksToTop = Notification.Name("playlist_moveTracksToTop")

    static let playlist_moveTracksDown = Notification.Name("playlist_moveTracksDown")

    static let playlist_moveTracksToBottom = Notification.Name("playlist_moveTracksToBottom")
    
    
    static let playlist_clearSelection = Notification.Name("playlist_clearSelection")

    static let playlist_invertSelection = Notification.Name("playlist_invertSelection")

    static let playlist_cropSelection = Notification.Name("playlist_cropSelection")
    

    static let playlist_expandSelectedGroups = Notification.Name("playlist_expandSelectedGroups")

    static let playlist_collapseSelectedItems = Notification.Name("playlist_collapseSelectedItems")

    static let playlist_collapseParentGroup = Notification.Name("playlist_collapseParentGroup")

    static let playlist_expandAllGroups = Notification.Name("playlist_expandAllGroups")

    static let playlist_collapseAllGroups = Notification.Name("playlist_collapseAllGroups")
    
    
    static let playlist_showPlayingTrack = Notification.Name("playlist_showPlayingTrack")

    static let playlist_showTrackInFinder = Notification.Name("playlist_showTrackInFinder")
    

    static let playlist_scrollToTop = Notification.Name("playlist_scrollToTop")

    static let playlist_scrollToBottom = Notification.Name("playlist_scrollToBottom")

    static let playlist_pageUp = Notification.Name("playlist_pageUp")

    static let playlist_pageDown = Notification.Name("playlist_pageDown")
    
    
    // Switch to the previous playlist view (in the tab group)
    static let playlist_previousView = Notification.Name("playlist_previousView")

    // Switch to the next playlist view (in the tab group)
    static let playlist_nextView = Notification.Name("playlist_nextView")
    
    // Show chapters list window for currently playing track
    static let playlist_viewChaptersList = Notification.Name("playlist_viewChaptersList")
    
    
    // Invoke the search dialog
    static let playlist_search = Notification.Name("playlist_search")

    // Invoke the sort dialog
    static let playlist_sort = Notification.Name("playlist_sort")
    
    static let playlist_selectSearchResult = Notification.Name("playlist_selectSearchResult")

    // ----------------------------------------------------------------------------------------
    
    // MARK: Chapters List commands
    
    // Play the chapter selected within the chapters list
    static let chaptersList_playSelectedChapter = Notification.Name("chaptersList_playSelectedChapter")

    // ----------------------------------------------------------------------------------------
    
    // MARK: FX commands
    
    // Switches the Effects panel tab group to a specfic tab
    static let fx_showFXUnitTab = Notification.Name("fx_showFXUnitTab")

    static let fx_updateFXUnitView = Notification.Name("fx_updateFXUnitView")
    
    // Saves the current settings in a sound profile for the current track
    static let fx_saveSoundProfile = Notification.Name("fx_saveSoundProfile")

    static let fx_deleteSoundProfile = Notification.Name("fx_deleteSoundProfile")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Master FX unit commands

    static let masterFXUnit_toggleEffects = Notification.Name("masterFXUnit_toggleEffects")

    // ----------------------------------------------------------------------------------------
    
    // MARK: EQ FX unit commands
    
    // Decreases each of the EQ bass bands by a certain preset decrement
    static let eqFXUnit_decreaseBass = Notification.Name("eqFXUnit_decreaseBass")

    // Provides a "bass boost". Increases each of the EQ bass bands by a certain preset increment.
    static let eqFXUnit_increaseBass = Notification.Name("eqFXUnit_increaseBass")

    // Decreases each of the EQ mid-frequency bands by a certain preset decrement
    static let eqFXUnit_decreaseMids = Notification.Name("eqFXUnit_decreaseMids")
    
    // Increases each of the EQ mid-frequency bands by a certain preset increment
    static let eqFXUnit_increaseMids = Notification.Name("eqFXUnit_increaseMids")

    // Decreases each of the EQ treble bands by a certain preset decrement
    static let eqFXUnit_decreaseTreble = Notification.Name("eqFXUnit_decreaseTreble")
    
    // Decreases each of the EQ treble bands by a certain preset increment
    static let eqFXUnit_increaseTreble = Notification.Name("eqFXUnit_increaseTreble")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Pitch FX unit commands
    
    // Decreases the pitch by a certain preset decrement
    static let pitchFXUnit_decreasePitch = Notification.Name("pitchFXUnit_decreasePitch")

    // Increases the pitch by a certain preset increment
    static let pitchFXUnit_increasePitch = Notification.Name("pitchFXUnit_increasePitch")

    // Sets the pitch to a specific value
    static let pitchFXUnit_setPitch = Notification.Name("pitchFXUnit_setPitch")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Time FX unit commands
    
    // Decreases the playback rate by a certain preset decrement
    static let timeFXUnit_decreaseRate = Notification.Name("timeFXUnit_decreaseRate")

    // Increases the playback rate by a certain preset increment
    static let timeFXUnit_increaseRate = Notification.Name("timeFXUnit_increaseRate")

    // Sets the playback rate to a specific value
    static let timeFXUnit_setRate = Notification.Name("timeFXUnit_setRate")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Window layout commands
    
    // Show/hide the playlist window
    static let windowLayout_togglePlaylistWindow = Notification.Name("windowLayout_togglePlaylistWindow")

    // Show/hide the effects window
    static let windowLayout_toggleEffectsWindow = Notification.Name("windowLayout_toggleEffectsWindow")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: FX presets editor commands

    static let fxPresetsEditor_reloadPresets = Notification.Name("fxPresetsEditor_reloadPresets")

    static let fxPresetsEditor_renameEffectsPreset = Notification.Name("fxPresetsEditor_renameEffectsPreset")

    static let fxPresetsEditor_deleteEffectsPresets = Notification.Name("fxPresetsEditor_deleteEffectsPresets")

    static let fxPresetsEditor_applyEffectsPreset = Notification.Name("fxPresetsEditor_applyEffectsPreset")
    
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Text size commands
    
    static let changePlayerTextSize = Notification.Name("changePlayerTextSize")

    static let changeFXTextSize = Notification.Name("changeFXTextSize")

    static let changePlaylistTextSize = Notification.Name("changePlaylistTextSize")
    
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Color scheme commands

    static let colorScheme_applyColorScheme = Notification.Name("colorScheme_applyColorScheme")

    static let colorScheme_changeAppLogoColor = Notification.Name("colorScheme_changeAppLogoColor")

    static let colorScheme_changeBackgroundColor = Notification.Name("colorScheme_changeBackgroundColor")

    static let colorScheme_changeViewControlButtonColor = Notification.Name("colorScheme_changeViewControlButtonColor")

    static let colorScheme_changeFunctionButtonColor = Notification.Name("colorScheme_changeFunctionButtonColor")

    static let colorScheme_changeTextButtonMenuColor = Notification.Name("colorScheme_changeTextButtonMenuColor")

    static let colorScheme_changeToggleButtonOffStateColor = Notification.Name("colorScheme_changeToggleButtonOffStateColor")

    static let colorScheme_changeSelectedTabButtonColor = Notification.Name("colorScheme_changeSelectedTabButtonColor")

    static let colorScheme_changeMainCaptionTextColor = Notification.Name("colorScheme_changeMainCaptionTextColor")

    static let colorScheme_changeTabButtonTextColor = Notification.Name("colorScheme_changeTabButtonTextColor")

    static let colorScheme_changeSelectedTabButtonTextColor = Notification.Name("colorScheme_changeSelectedTabButtonTextColor")

    static let colorScheme_changeButtonMenuTextColor = Notification.Name("colorScheme_changeButtonMenuTextColor")

    static let colorScheme_changePlayerTrackInfoPrimaryTextColor = Notification.Name("colorScheme_changePlayerTrackInfoPrimaryTextColor")

    static let colorScheme_changePlayerTrackInfoSecondaryTextColor = Notification.Name("colorScheme_changePlayerTrackInfoSecondaryTextColor")

    static let colorScheme_changePlayerTrackInfoTertiaryTextColor = Notification.Name("colorScheme_changePlayerTrackInfoTertiaryTextColor")

    static let colorScheme_changePlayerSliderValueTextColor = Notification.Name("colorScheme_changePlayerSliderValueTextColor")

    static let colorScheme_changePlayerSliderColors = Notification.Name("colorScheme_changePlayerSliderColors")

    static let colorScheme_changePlaylistTrackNameTextColor = Notification.Name("colorScheme_changePlaylistTrackNameTextColor")

    static let colorScheme_changePlaylistGroupNameTextColor = Notification.Name("colorScheme_changePlaylistGroupNameTextColor")

    static let colorScheme_changePlaylistIndexDurationTextColor = Notification.Name("colorScheme_changePlaylistIndexDurationTextColor")

    static let colorScheme_changePlaylistTrackNameSelectedTextColor = Notification.Name("colorScheme_changePlaylistTrackNameSelectedTextColor")

    static let colorScheme_changePlaylistGroupNameSelectedTextColor = Notification.Name("colorScheme_changePlaylistGroupNameSelectedTextColor")

    static let colorScheme_changePlaylistIndexDurationSelectedTextColor = Notification.Name("colorScheme_changePlaylistIndexDurationSelectedTextColor")

    static let colorScheme_changePlaylistSummaryInfoColor = Notification.Name("colorScheme_changePlaylistSummaryInfoColor")

    static let colorScheme_changePlaylistGroupIconColor = Notification.Name("colorScheme_changePlaylistGroupIconColor")

    static let colorScheme_changePlaylistGroupDisclosureTriangleColor = Notification.Name("colorScheme_changePlaylistGroupDisclosureTriangleColor")

    static let colorScheme_changePlaylistSelectionBoxColor = Notification.Name("colorScheme_changePlaylistSelectionBoxColor")

    static let colorScheme_changePlaylistPlayingTrackIconColor = Notification.Name("colorScheme_changePlaylistPlayingTrackIconColor")

    static let colorScheme_changeFXFunctionCaptionTextColor = Notification.Name("colorScheme_changeFXFunctionCaptionTextColor")

    static let colorScheme_changeFXFunctionValueTextColor = Notification.Name("colorScheme_changeFXFunctionValueTextColor")

    static let colorScheme_changeFXSliderColors = Notification.Name("colorScheme_changeFXSliderColors")

    static let colorScheme_changeFXActiveUnitStateColor = Notification.Name("colorScheme_changeFXActiveUnitStateColor")

    static let colorScheme_changeFXBypassedUnitStateColor = Notification.Name("colorScheme_changeFXBypassedUnitStateColor")

    static let colorScheme_changeFXSuppressedUnitStateColor = Notification.Name("colorScheme_changeFXSuppressedUnitStateColor")
}
