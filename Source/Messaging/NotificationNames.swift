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
    
    // MARK: Playlist commands
    
    static let playlist_refresh = Notification.Name("playlist_refresh")

    static let playlist_addTracks = Notification.Name("playlist_addTracks")

    static let playlist_removeTracks = Notification.Name("playlist_removeTracks")

    static let playlist_savePlaylist = Notification.Name("playlist_savePlaylist")

    static let playlist_clearPlaylist = Notification.Name("playlist_clearPlaylist")

    static let playlist_showPlayingTrack = Notification.Name("playlist_showPlayingTrack")

    static let playlist_playSelectedItem = Notification.Name("playlist_playSelectedItem")

    static let playlist_playSelectedItemWithDelay = Notification.Name("playlist_playSelectedItemWithDelay")

    static let playlist_playSelectedChapter = Notification.Name("playlist_playSelectedChapter")

    static let playlist_insertGaps = Notification.Name("playlist_insertGaps")

    static let playlist_removeGaps = Notification.Name("playlist_removeGaps")

    static let playlist_moveTracksUp = Notification.Name("playlist_moveTracksUp")

    static let playlist_moveTracksToTop = Notification.Name("playlist_moveTracksToTop")

    static let playlist_moveTracksDown = Notification.Name("playlist_moveTracksDown")

    static let playlist_moveTracksToBottom = Notification.Name("playlist_moveTracksToBottom")

    static let playlist_showTrackInFinder = Notification.Name("playlist_showTrackInFinder")

    static let playlist_search = Notification.Name("playlist_search")

    static let playlist_sort = Notification.Name("playlist_sort")

    static let playlist_clearSelection = Notification.Name("playlist_clearSelection")

    static let playlist_invertSelection = Notification.Name("playlist_invertSelection")

    static let playlist_cropSelection = Notification.Name("playlist_cropSelection")

    static let playlist_expandSelectedGroups = Notification.Name("playlist_expandSelectedGroups")

    static let playlist_collapseSelectedItems = Notification.Name("playlist_collapseSelectedItems")

    static let playlist_collapseParentGroup = Notification.Name("playlist_collapseParentGroup")

    static let playlist_expandAllGroups = Notification.Name("playlist_expandAllGroups")

    static let playlist_collapseAllGroups = Notification.Name("playlist_collapseAllGroups")

    static let playlist_scrollToTop = Notification.Name("playlist_scrollToTop")

    static let playlist_scrollToBottom = Notification.Name("playlist_scrollToBottom")

    static let playlist_pageUp = Notification.Name("playlist_pageUp")

    static let playlist_pageDown = Notification.Name("playlist_pageDown")

    static let playlist_previousPlaylistView = Notification.Name("playlist_previousPlaylistView")

    static let playlist_nextPlaylistView = Notification.Name("playlist_nextPlaylistView")

    static let playlist_selectedTrackInfo = Notification.Name("playlist_selectedTrackInfo")

    static let playlist_viewChapters = Notification.Name("playlist_viewChapters")

    
    
    static let previousChapter = Notification.Name("previousChapter")

    static let nextChapter = Notification.Name("nextChapter")

    static let replayChapter = Notification.Name("replayChapter")

    static let toggleChapterLoop = Notification.Name("toggleChapterLoop")

    
    
    static let moreInfo = Notification.Name("moreInfo")

    static let enableEffects = Notification.Name("enableEffects")

    static let disableEffects = Notification.Name("disableEffects")

    

    static let increaseBass = Notification.Name("increaseBass")

    static let decreaseBass = Notification.Name("decreaseBass")

    static let increaseMids = Notification.Name("increaseMids")

    static let decreaseMids = Notification.Name("decreaseMids")

    static let increaseTreble = Notification.Name("increaseTreble")

    static let decreaseTreble = Notification.Name("decreaseTreble")

    static let increasePitch = Notification.Name("increasePitch")

    static let decreasePitch = Notification.Name("decreasePitch")

    static let setPitch = Notification.Name("setPitch")

    static let increaseRate = Notification.Name("increaseRate")

    static let decreaseRate = Notification.Name("decreaseRate")

    static let setRate = Notification.Name("setRate")

    static let saveSoundProfile = Notification.Name("saveSoundProfile")

    static let deleteSoundProfile = Notification.Name("deleteSoundProfile")

    static let savePlaybackProfile = Notification.Name("savePlaybackProfile")

    static let deletePlaybackProfile = Notification.Name("deletePlaybackProfile")

    static let showEffectsUnitTab = Notification.Name("showEffectsUnitTab")

    static let updateEffectsView = Notification.Name("updateEffectsView")

    static let editFilterBand = Notification.Name("editFilterBand")

    static let togglePlaylist = Notification.Name("togglePlaylist")

    static let toggleEffects = Notification.Name("toggleEffects")

    static let toggleChaptersList = Notification.Name("toggleChaptersList")

    static let bookmarkPosition = Notification.Name("bookmarkPosition")

    static let bookmarkLoop = Notification.Name("bookmarkLoop")

    static let windowLayout = Notification.Name("windowLayout")

    static let reloadPresets = Notification.Name("reloadPresets")

    static let renameEffectsPreset = Notification.Name("renameEffectsPreset")

    static let deleteEffectsPresets = Notification.Name("deleteEffectsPresets")

    static let applyEffectsPreset = Notification.Name("applyEffectsPreset")

    static let changePlayerView = Notification.Name("changePlayerView")

    static let showOrHideAlbumArt = Notification.Name("showOrHideAlbumArt")

    static let showOrHideArtist = Notification.Name("showOrHideArtist")

    static let showOrHideAlbum = Notification.Name("showOrHideAlbum")

    static let showOrHideCurrentChapter = Notification.Name("showOrHideCurrentChapter")

    static let showOrHidePlayingTrackInfo = Notification.Name("showOrHidePlayingTrackInfo")

    static let showOrHideSequenceInfo = Notification.Name("showOrHideSequenceInfo")

    static let showOrHidePlayingTrackFunctions = Notification.Name("showOrHidePlayingTrackFunctions")

    static let showOrHideMainControls = Notification.Name("showOrHideMainControls")

    static let setTimeElapsedDisplayFormat = Notification.Name("setTimeElapsedDisplayFormat")

    static let setTimeRemainingDisplayFormat = Notification.Name("setTimeRemainingDisplayFormat")

    static let showOrHideTimeElapsedRemaining = Notification.Name("showOrHideTimeElapsedRemaining")

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
