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
    
    // MARK: Player commands
    
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

    // Toggle A->B segment playback loop
    static let player_toggleLoop = Notification.Name("player_toggleLoop")
    
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
    
    // ----------
    
    
    static let refresh = Notification.Name("refresh")

    static let addTracks = Notification.Name("addTracks")

    static let removeTracks = Notification.Name("removeTracks")

    static let savePlaylist = Notification.Name("savePlaylist")

    static let clearPlaylist = Notification.Name("clearPlaylist")

    static let showPlayingTrack = Notification.Name("showPlayingTrack")

    static let playSelectedItem = Notification.Name("playSelectedItem")

    static let playSelectedItemWithDelay = Notification.Name("playSelectedItemWithDelay")

    static let playSelectedChapter = Notification.Name("playSelectedChapter")

    static let insertGaps = Notification.Name("insertGaps")

    static let removeGaps = Notification.Name("removeGaps")

    static let moveTracksUp = Notification.Name("moveTracksUp")

    static let moveTracksToTop = Notification.Name("moveTracksToTop")

    static let moveTracksDown = Notification.Name("moveTracksDown")

    static let moveTracksToBottom = Notification.Name("moveTracksToBottom")

    static let showTrackInFinder = Notification.Name("showTrackInFinder")

    static let search = Notification.Name("search")

    static let sort = Notification.Name("sort")

    static let clearSelection = Notification.Name("clearSelection")

    static let invertSelection = Notification.Name("invertSelection")

    static let cropSelection = Notification.Name("cropSelection")

    static let expandSelectedGroups = Notification.Name("expandSelectedGroups")

    static let collapseSelectedItems = Notification.Name("collapseSelectedItems")

    static let collapseParentGroup = Notification.Name("collapseParentGroup")

    static let expandAllGroups = Notification.Name("expandAllGroups")

    static let collapseAllGroups = Notification.Name("collapseAllGroups")

    static let scrollToTop = Notification.Name("scrollToTop")

    static let scrollToBottom = Notification.Name("scrollToBottom")

    static let pageUp = Notification.Name("pageUp")

    static let pageDown = Notification.Name("pageDown")

    static let previousPlaylistView = Notification.Name("previousPlaylistView")

    static let nextPlaylistView = Notification.Name("nextPlaylistView")

    static let selectedTrackInfo = Notification.Name("selectedTrackInfo")

    static let viewChapters = Notification.Name("viewChapters")

    

    static let previousChapter = Notification.Name("previousChapter")

    static let nextChapter = Notification.Name("nextChapter")

    static let replayChapter = Notification.Name("replayChapter")

    static let toggleChapterLoop = Notification.Name("toggleChapterLoop")

    

    static let repeatOff = Notification.Name("repeatOff")

    static let repeatOne = Notification.Name("repeatOne")

    static let repeatAll = Notification.Name("repeatAll")

    static let shuffleOff = Notification.Name("shuffleOff")

    static let shuffleOn = Notification.Name("shuffleOn")

    static let moreInfo = Notification.Name("moreInfo")

    static let enableEffects = Notification.Name("enableEffects")

    static let disableEffects = Notification.Name("disableEffects")

    static let muteOrUnmute = Notification.Name("muteOrUnmute")

    static let setVolume = Notification.Name("setVolume")

    static let increaseVolume = Notification.Name("increaseVolume")

    static let decreaseVolume = Notification.Name("decreaseVolume")

    static let setPan = Notification.Name("setPan")

    static let panLeft = Notification.Name("panLeft")

    static let panRight = Notification.Name("panRight")

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

    static let changeEffectsTextSize = Notification.Name("changeEffectsTextSize")

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
