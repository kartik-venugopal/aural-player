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
    static let playTrack = Notification.Name("playTrack")
    static let chapterPlayback = Notification.Name("chapterPlayback")
    static let trackNotPlayed = Notification.Name("trackNotPlayed")
    static let preTrackChange = Notification.Name("preTrackChange")
    
    static let transcodingProgress = Notification.Name("transcodingProgress")
    
    static let startedAddingTracks = Notification.Name("startedAddingTracks")
    static let doneAddingTracks = Notification.Name("doneAddingTracks")
    static let tracksNotAdded = Notification.Name("tracksNotAdded")
    
    static let playlistTypeChanged = Notification.Name("playlistTypeChanged")
    
    static let selectSearchResult = Notification.Name("selectSearchResult")
    static let searchTextChanged = Notification.Name("searchTextChanged")
    
    static let trackAdded = Notification.Name("trackAdded")
    static let tracksRemoved = Notification.Name("tracksRemoved")
    static let gapUpdated = Notification.Name("gapUpdated")
    
    static let trackTransition = Notification.Name("trackTransition")
    static let trackInfoUpdated = Notification.Name("trackInfoUpdated")
    static let trackNotTranscoded = Notification.Name("trackNotTranscoded")
    static let audioOutputChanged = Notification.Name("audioOutputChanged")
    static let transcodingFinished = Notification.Name("transcodingFinished")
    static let sequenceChanged = Notification.Name("sequenceChanged")
    static let playingTrackInfoUpdated = Notification.Name("playingTrackInfoUpdated")
    static let playbackLoopChanged = Notification.Name("playbackLoopChanged")
    static let editorSelectionChanged = Notification.Name("editorSelectionChanged")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Playback commands
    
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
    

    static let playlist_selectedTrackInfo = Notification.Name("playlist_selectedTrackInfo")

    static let playlist_viewChapters = Notification.Name("playlist_viewChapters")
    
    
    // Invoke the search dialog
    static let playlist_search = Notification.Name("playlist_search")

    // Invoke the sort dialog
    static let playlist_sort = Notification.Name("playlist_sort")

    
    static let playSelectedChapter = Notification.Name("playSelectedChapter")
    
    static let previousChapter = Notification.Name("previousChapter")

    static let nextChapter = Notification.Name("nextChapter")

    static let replayChapter = Notification.Name("replayChapter")

    static let toggleChapterLoop = Notification.Name("toggleChapterLoop")

    // ----------------------------------------------------------------------------------------
    
    // MARK: FX commands
    
    // Switches the Effects panel tab group to a specfic tab
    static let fx_showFXUnitTab = Notification.Name("fx_showFXUnitTab")

    static let fx_updateFXUnitView = Notification.Name("fx_updateFXUnitView")
    
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

    

    static let saveSoundProfile = Notification.Name("saveSoundProfile")

    static let deleteSoundProfile = Notification.Name("deleteSoundProfile")
    

    static let savePlaybackProfile = Notification.Name("savePlaybackProfile")

    static let deletePlaybackProfile = Notification.Name("deletePlaybackProfile")
    

    // Show/hide the playlist window
    static let windowLayout_togglePlaylistWindow = Notification.Name("windowLayout_togglePlaylistWindow")

    // Show/hide the effects window
    static let windowLayout_toggleEffectsWindow = Notification.Name("windowLayout_toggleEffectsWindow")

    static let windowLayout = Notification.Name("windowLayout")

    static let reloadPresets = Notification.Name("reloadPresets")

    static let renameEffectsPreset = Notification.Name("renameEffectsPreset")

    static let deleteEffectsPresets = Notification.Name("deleteEffectsPresets")

    static let applyEffectsPreset = Notification.Name("applyEffectsPreset")
    

    static let changePlayerTextSize = Notification.Name("changePlayerTextSize")

    static let changeFXTextSize = Notification.Name("changeFXTextSize")

    static let changePlaylistTextSize = Notification.Name("changePlaylistTextSize")

    static let applyColorScheme = Notification.Name("applyColorScheme")

    static let changeAppLogoColor = Notification.Name("changeAppLogoColor")

    static let changeBackgroundColor = Notification.Name("changeBackgroundColor")

    static let changeViewControlButtonColor = Notification.Name("changeViewControlButtonColor")

    static let changeFunctionButtonColor = Notification.Name("changeFunctionButtonColor")

    static let changeTextButtonMenuColor = Notification.Name("changeTextButtonMenuColor")

    static let changeToggleButtonOffStateColor = Notification.Name("changeToggleButtonOffStateColor")

    static let changeSelectedTabButtonColor = Notification.Name("changeSelectedTabButtonColor")

    static let changeMainCaptionTextColor = Notification.Name("changeMainCaptionTextColor")

    static let changeTabButtonTextColor = Notification.Name("changeTabButtonTextColor")

    static let changeSelectedTabButtonTextColor = Notification.Name("changeSelectedTabButtonTextColor")

    static let changeButtonMenuTextColor = Notification.Name("changeButtonMenuTextColor")

    static let changePlayerTrackInfoPrimaryTextColor = Notification.Name("changePlayerTrackInfoPrimaryTextColor")

    static let changePlayerTrackInfoSecondaryTextColor = Notification.Name("changePlayerTrackInfoSecondaryTextColor")

    static let changePlayerTrackInfoTertiaryTextColor = Notification.Name("changePlayerTrackInfoTertiaryTextColor")

    static let changePlayerSliderValueTextColor = Notification.Name("changePlayerSliderValueTextColor")

    static let changePlayerSliderColors = Notification.Name("changePlayerSliderColors")

    static let changePlaylistTrackNameTextColor = Notification.Name("changePlaylistTrackNameTextColor")

    static let changePlaylistGroupNameTextColor = Notification.Name("changePlaylistGroupNameTextColor")

    static let changePlaylistIndexDurationTextColor = Notification.Name("changePlaylistIndexDurationTextColor")

    static let changePlaylistTrackNameSelectedTextColor = Notification.Name("changePlaylistTrackNameSelectedTextColor")

    static let changePlaylistGroupNameSelectedTextColor = Notification.Name("changePlaylistGroupNameSelectedTextColor")

    static let changePlaylistIndexDurationSelectedTextColor = Notification.Name("changePlaylistIndexDurationSelectedTextColor")

    static let changePlaylistSummaryInfoColor = Notification.Name("changePlaylistSummaryInfoColor")

    static let changePlaylistGroupIconColor = Notification.Name("changePlaylistGroupIconColor")

    static let changePlaylistGroupDisclosureTriangleColor = Notification.Name("changePlaylistGroupDisclosureTriangleColor")

    static let changePlaylistSelectionBoxColor = Notification.Name("changePlaylistSelectionBoxColor")

    static let changePlaylistPlayingTrackIconColor = Notification.Name("changePlaylistPlayingTrackIconColor")

    static let changeEffectsFunctionCaptionTextColor = Notification.Name("changeEffectsFunctionCaptionTextColor")

    static let changeEffectsFunctionValueTextColor = Notification.Name("changeEffectsFunctionValueTextColor")

    static let changeEffectsSliderColors = Notification.Name("changeEffectsSliderColors")

    static let changeEffectsActiveUnitStateColor = Notification.Name("changeEffectsActiveUnitStateColor")

    static let changeEffectsBypassedUnitStateColor = Notification.Name("changeEffectsBypassedUnitStateColor")

    static let changeEffectsSuppressedUnitStateColor = Notification.Name("changeEffectsSuppressedUnitStateColor")
}
