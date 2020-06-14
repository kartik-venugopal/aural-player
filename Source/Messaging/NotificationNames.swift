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
    
    // ----------------------------------------------------------------------------------------
    
    static let trackTransition: Notification.Name = Notification.Name("trackTransition")

    static let trackInfoUpdated: Notification.Name = Notification.Name("trackInfoUpdated")

    static let trackNotTranscoded: Notification.Name = Notification.Name("trackNotTranscoded")

    static let audioOutputChanged: Notification.Name = Notification.Name("audioOutputChanged")

    static let transcodingCancelled: Notification.Name = Notification.Name("transcodingCancelled")

    static let transcodingFinished: Notification.Name = Notification.Name("transcodingFinished")

    static let sequenceChanged: Notification.Name = Notification.Name("sequenceChanged")

    static let playingTrackInfoUpdated: Notification.Name = Notification.Name("playingTrackInfoUpdated")

    static let playbackLoopChanged: Notification.Name = Notification.Name("playbackLoopChanged")

    static let editorSelectionChanged: Notification.Name = Notification.Name("editorSelectionChanged")

    static let emptyResponse: Notification.Name = Notification.Name("emptyResponse")

    static let refresh: Notification.Name = Notification.Name("refresh")

    static let addTracks: Notification.Name = Notification.Name("addTracks")

    static let removeTracks: Notification.Name = Notification.Name("removeTracks")

    static let savePlaylist: Notification.Name = Notification.Name("savePlaylist")

    static let clearPlaylist: Notification.Name = Notification.Name("clearPlaylist")

    static let showPlayingTrack: Notification.Name = Notification.Name("showPlayingTrack")

    static let playSelectedItem: Notification.Name = Notification.Name("playSelectedItem")

    static let playSelectedItemWithDelay: Notification.Name = Notification.Name("playSelectedItemWithDelay")

    static let playSelectedChapter: Notification.Name = Notification.Name("playSelectedChapter")

    static let insertGaps: Notification.Name = Notification.Name("insertGaps")

    static let removeGaps: Notification.Name = Notification.Name("removeGaps")

    static let moveTracksUp: Notification.Name = Notification.Name("moveTracksUp")

    static let moveTracksToTop: Notification.Name = Notification.Name("moveTracksToTop")

    static let moveTracksDown: Notification.Name = Notification.Name("moveTracksDown")

    static let moveTracksToBottom: Notification.Name = Notification.Name("moveTracksToBottom")

    static let showTrackInFinder: Notification.Name = Notification.Name("showTrackInFinder")

    static let search: Notification.Name = Notification.Name("search")

    static let sort: Notification.Name = Notification.Name("sort")

    static let clearSelection: Notification.Name = Notification.Name("clearSelection")

    static let invertSelection: Notification.Name = Notification.Name("invertSelection")

    static let cropSelection: Notification.Name = Notification.Name("cropSelection")

    static let expandSelectedGroups: Notification.Name = Notification.Name("expandSelectedGroups")

    static let collapseSelectedItems: Notification.Name = Notification.Name("collapseSelectedItems")

    static let collapseParentGroup: Notification.Name = Notification.Name("collapseParentGroup")

    static let expandAllGroups: Notification.Name = Notification.Name("expandAllGroups")

    static let collapseAllGroups: Notification.Name = Notification.Name("collapseAllGroups")

    static let scrollToTop: Notification.Name = Notification.Name("scrollToTop")

    static let scrollToBottom: Notification.Name = Notification.Name("scrollToBottom")

    static let pageUp: Notification.Name = Notification.Name("pageUp")

    static let pageDown: Notification.Name = Notification.Name("pageDown")

    static let previousPlaylistView: Notification.Name = Notification.Name("previousPlaylistView")

    static let nextPlaylistView: Notification.Name = Notification.Name("nextPlaylistView")

    static let selectedTrackInfo: Notification.Name = Notification.Name("selectedTrackInfo")

    static let dockLeft: Notification.Name = Notification.Name("dockLeft")

    static let dockRight: Notification.Name = Notification.Name("dockRight")

    static let dockBottom: Notification.Name = Notification.Name("dockBottom")

    static let maximize: Notification.Name = Notification.Name("maximize")

    static let maximizeHorizontal: Notification.Name = Notification.Name("maximizeHorizontal")

    static let maximizeVertical: Notification.Name = Notification.Name("maximizeVertical")

    static let viewChapters: Notification.Name = Notification.Name("viewChapters")

    static let playOrPause: Notification.Name = Notification.Name("playOrPause")

    static let stop: Notification.Name = Notification.Name("stop")

    static let previousTrack: Notification.Name = Notification.Name("previousTrack")

    static let nextTrack: Notification.Name = Notification.Name("nextTrack")

    static let replayTrack: Notification.Name = Notification.Name("replayTrack")

    static let toggleLoop: Notification.Name = Notification.Name("toggleLoop")

    static let previousChapter: Notification.Name = Notification.Name("previousChapter")

    static let nextChapter: Notification.Name = Notification.Name("nextChapter")

    static let replayChapter: Notification.Name = Notification.Name("replayChapter")

    static let toggleChapterLoop: Notification.Name = Notification.Name("toggleChapterLoop")

    static let seekBackward: Notification.Name = Notification.Name("seekBackward")

    static let seekForward: Notification.Name = Notification.Name("seekForward")

    static let seekBackward_secondary: Notification.Name = Notification.Name("seekBackward_secondary")

    static let seekForward_secondary: Notification.Name = Notification.Name("seekForward_secondary")

    static let jumpToTime: Notification.Name = Notification.Name("jumpToTime")

    static let repeatOff: Notification.Name = Notification.Name("repeatOff")

    static let repeatOne: Notification.Name = Notification.Name("repeatOne")

    static let repeatAll: Notification.Name = Notification.Name("repeatAll")

    static let shuffleOff: Notification.Name = Notification.Name("shuffleOff")

    static let shuffleOn: Notification.Name = Notification.Name("shuffleOn")

    static let moreInfo: Notification.Name = Notification.Name("moreInfo")

    static let enableEffects: Notification.Name = Notification.Name("enableEffects")

    static let disableEffects: Notification.Name = Notification.Name("disableEffects")

    static let muteOrUnmute: Notification.Name = Notification.Name("muteOrUnmute")

    static let setVolume: Notification.Name = Notification.Name("setVolume")

    static let increaseVolume: Notification.Name = Notification.Name("increaseVolume")

    static let decreaseVolume: Notification.Name = Notification.Name("decreaseVolume")

    static let setPan: Notification.Name = Notification.Name("setPan")

    static let panLeft: Notification.Name = Notification.Name("panLeft")

    static let panRight: Notification.Name = Notification.Name("panRight")

    static let increaseBass: Notification.Name = Notification.Name("increaseBass")

    static let decreaseBass: Notification.Name = Notification.Name("decreaseBass")

    static let increaseMids: Notification.Name = Notification.Name("increaseMids")

    static let decreaseMids: Notification.Name = Notification.Name("decreaseMids")

    static let increaseTreble: Notification.Name = Notification.Name("increaseTreble")

    static let decreaseTreble: Notification.Name = Notification.Name("decreaseTreble")

    static let increasePitch: Notification.Name = Notification.Name("increasePitch")

    static let decreasePitch: Notification.Name = Notification.Name("decreasePitch")

    static let setPitch: Notification.Name = Notification.Name("setPitch")

    static let increaseRate: Notification.Name = Notification.Name("increaseRate")

    static let decreaseRate: Notification.Name = Notification.Name("decreaseRate")

    static let setRate: Notification.Name = Notification.Name("setRate")

    static let saveSoundProfile: Notification.Name = Notification.Name("saveSoundProfile")

    static let deleteSoundProfile: Notification.Name = Notification.Name("deleteSoundProfile")

    static let savePlaybackProfile: Notification.Name = Notification.Name("savePlaybackProfile")

    static let deletePlaybackProfile: Notification.Name = Notification.Name("deletePlaybackProfile")

    static let showEffectsUnitTab: Notification.Name = Notification.Name("showEffectsUnitTab")

    static let updateEffectsView: Notification.Name = Notification.Name("updateEffectsView")

    static let editFilterBand: Notification.Name = Notification.Name("editFilterBand")

    static let togglePlaylist: Notification.Name = Notification.Name("togglePlaylist")

    static let toggleEffects: Notification.Name = Notification.Name("toggleEffects")

    static let toggleChaptersList: Notification.Name = Notification.Name("toggleChaptersList")

    static let bookmarkPosition: Notification.Name = Notification.Name("bookmarkPosition")

    static let bookmarkLoop: Notification.Name = Notification.Name("bookmarkLoop")

    static let windowLayout: Notification.Name = Notification.Name("windowLayout")

    static let reloadPresets: Notification.Name = Notification.Name("reloadPresets")

    static let renameEffectsPreset: Notification.Name = Notification.Name("renameEffectsPreset")

    static let deleteEffectsPresets: Notification.Name = Notification.Name("deleteEffectsPresets")

    static let applyEffectsPreset: Notification.Name = Notification.Name("applyEffectsPreset")

    static let dockTopLeft: Notification.Name = Notification.Name("dockTopLeft")

    static let dockTopRight: Notification.Name = Notification.Name("dockTopRight")

    static let dockBottomLeft: Notification.Name = Notification.Name("dockBottomLeft")

    static let dockBottomRight: Notification.Name = Notification.Name("dockBottomRight")

    static let changePlayerView: Notification.Name = Notification.Name("changePlayerView")

    static let showOrHideAlbumArt: Notification.Name = Notification.Name("showOrHideAlbumArt")

    static let showOrHideArtist: Notification.Name = Notification.Name("showOrHideArtist")

    static let showOrHideAlbum: Notification.Name = Notification.Name("showOrHideAlbum")

    static let showOrHideCurrentChapter: Notification.Name = Notification.Name("showOrHideCurrentChapter")

    static let showOrHidePlayingTrackInfo: Notification.Name = Notification.Name("showOrHidePlayingTrackInfo")

    static let showOrHideSequenceInfo: Notification.Name = Notification.Name("showOrHideSequenceInfo")

    static let showOrHidePlayingTrackFunctions: Notification.Name = Notification.Name("showOrHidePlayingTrackFunctions")

    static let showOrHideMainControls: Notification.Name = Notification.Name("showOrHideMainControls")

    static let setTimeElapsedDisplayFormat: Notification.Name = Notification.Name("setTimeElapsedDisplayFormat")

    static let setTimeRemainingDisplayFormat: Notification.Name = Notification.Name("setTimeRemainingDisplayFormat")

    static let showOrHideTimeElapsedRemaining: Notification.Name = Notification.Name("showOrHideTimeElapsedRemaining")

    static let changePlayerTextSize: Notification.Name = Notification.Name("changePlayerTextSize")

    static let changeEffectsTextSize: Notification.Name = Notification.Name("changeEffectsTextSize")

    static let changePlaylistTextSize: Notification.Name = Notification.Name("changePlaylistTextSize")

    static let applyColorScheme: Notification.Name = Notification.Name("applyColorScheme")

    static let changeAppLogoColor: Notification.Name = Notification.Name("changeAppLogoColor")

    static let changeBackgroundColor: Notification.Name = Notification.Name("changeBackgroundColor")

    static let changeViewControlButtonColor: Notification.Name = Notification.Name("changeViewControlButtonColor")

    static let changeFunctionButtonColor: Notification.Name = Notification.Name("changeFunctionButtonColor")

    static let changeTextButtonMenuColor: Notification.Name = Notification.Name("changeTextButtonMenuColor")

    static let changeToggleButtonOffStateColor: Notification.Name = Notification.Name("changeToggleButtonOffStateColor")

    static let changeSelectedTabButtonColor: Notification.Name = Notification.Name("changeSelectedTabButtonColor")

    static let changeMainCaptionTextColor: Notification.Name = Notification.Name("changeMainCaptionTextColor")

    static let changeTabButtonTextColor: Notification.Name = Notification.Name("changeTabButtonTextColor")

    static let changeSelectedTabButtonTextColor: Notification.Name = Notification.Name("changeSelectedTabButtonTextColor")

    static let changeButtonMenuTextColor: Notification.Name = Notification.Name("changeButtonMenuTextColor")

    static let changePlayerTrackInfoPrimaryTextColor: Notification.Name = Notification.Name("changePlayerTrackInfoPrimaryTextColor")

    static let changePlayerTrackInfoSecondaryTextColor: Notification.Name = Notification.Name("changePlayerTrackInfoSecondaryTextColor")

    static let changePlayerTrackInfoTertiaryTextColor: Notification.Name = Notification.Name("changePlayerTrackInfoTertiaryTextColor")

    static let changePlayerSliderValueTextColor: Notification.Name = Notification.Name("changePlayerSliderValueTextColor")

    static let changePlayerSliderColors: Notification.Name = Notification.Name("changePlayerSliderColors")

    static let changePlaylistTrackNameTextColor: Notification.Name = Notification.Name("changePlaylistTrackNameTextColor")

    static let changePlaylistGroupNameTextColor: Notification.Name = Notification.Name("changePlaylistGroupNameTextColor")

    static let changePlaylistIndexDurationTextColor: Notification.Name = Notification.Name("changePlaylistIndexDurationTextColor")

    static let changePlaylistTrackNameSelectedTextColor: Notification.Name = Notification.Name("changePlaylistTrackNameSelectedTextColor")

    static let changePlaylistGroupNameSelectedTextColor: Notification.Name = Notification.Name("changePlaylistGroupNameSelectedTextColor")

    static let changePlaylistIndexDurationSelectedTextColor: Notification.Name = Notification.Name("changePlaylistIndexDurationSelectedTextColor")

    static let changePlaylistSummaryInfoColor: Notification.Name = Notification.Name("changePlaylistSummaryInfoColor")

    static let changePlaylistGroupIconColor: Notification.Name = Notification.Name("changePlaylistGroupIconColor")

    static let changePlaylistGroupDisclosureTriangleColor: Notification.Name = Notification.Name("changePlaylistGroupDisclosureTriangleColor")

    static let changePlaylistSelectionBoxColor: Notification.Name = Notification.Name("changePlaylistSelectionBoxColor")

    static let changePlaylistPlayingTrackIconColor: Notification.Name = Notification.Name("changePlaylistPlayingTrackIconColor")

    static let changeEffectsFunctionCaptionTextColor: Notification.Name = Notification.Name("changeEffectsFunctionCaptionTextColor")

    static let changeEffectsFunctionValueTextColor: Notification.Name = Notification.Name("changeEffectsFunctionValueTextColor")

    static let changeEffectsSliderColors: Notification.Name = Notification.Name("changeEffectsSliderColors")

    static let changeEffectsActiveUnitStateColor: Notification.Name = Notification.Name("changeEffectsActiveUnitStateColor")

    static let changeEffectsBypassedUnitStateColor: Notification.Name = Notification.Name("changeEffectsBypassedUnitStateColor")

    static let changeEffectsSuppressedUnitStateColor: Notification.Name = Notification.Name("changeEffectsSuppressedUnitStateColor")
}
