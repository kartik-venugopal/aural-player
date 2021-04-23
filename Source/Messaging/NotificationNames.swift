import Foundation

extension Notification.Name {
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Notifications published by the application (i.e. app delegate). They represent different lifecycle stages/events.
    
    // Signifies that the application has finished launching
    static let application_launched = Notification.Name("application_launched")
    
    // Signifies that the application has been reopened after being launched previously.
    static let application_reopened = Notification.Name("application_reopened")
    
    // Signifies that the application is about to exit/terminate, and asks observers for
    // responses indicating whether they accept (are ok with) the termination request.
    static let application_exitRequest = Notification.Name("application_exitRequest")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Notifications published by the window manager.
    
    // Signifies that the window layout has just been changed, i.e. windows have been shown/hidden and/or rearranged.
    static let windowManager_layoutChanged = Notification.Name("windowManager_layoutChanged")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Notifications/commands related to the Favorites list.
    
    // Signifies that a track has been added to the favorites list.
    static let favoritesList_trackAdded = Notification.Name("favoritesList_trackAdded")
    
    // Signifies that a track has been removed from the favorites list.
    static let favoritesList_trackRemoved = Notification.Name("favoritesList_trackRemoved")
    
    // Commands the Favorites list to add/remove the currently playing track to/from the list.
    // Functions as a toggle: add/remove.
    static let favoritesList_addOrRemove = Notification.Name("favoritesList_addOrRemove")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Notifications related to the History lists (recently added / recently played).
    
    // Signifies that new items have been added to the playlist (ie. new items to be added to the recently added history list).
    static let history_itemsAdded = Notification.Name("history_itemsAdded")
    
    // Signifies that the history lists have been updated.
    static let history_updated = Notification.Name("history_updated")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Notifications published by FX (effects processing) components.
    
    // Signifies that an fx unit has just been activated
    static let fx_unitActivated = Notification.Name("fx_unitActivated")
    
    // Signifies that the bypass state of an fx unit has changed
    static let fx_unitStateChanged = Notification.Name("fx_unitStateChanged")
    
    // Signifies that the playback rate (of the time stretch fx unit) has changed.
    static let fx_playbackRateChanged = Notification.Name("fx_playbackRateChanged")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Notifications published by the Audio Units FX unit.
    
    static let auFXUnit_audioUnitsAddedOrRemoved = Notification.Name("auFXUnit_audioUnitsAddedOrRemoved")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Notifications published by the player.
    
    // Signifies that the currently playing track chapter has changed.
    static let player_chapterChanged = Notification.Name("player_chapterChanged")
    
    // Signifies that the currently playing track has completed playback.
    static let player_trackPlaybackCompleted = Notification.Name("player_trackPlaybackCompleted")
    
    // Signifies that an error occurred and the player was unable to play the requested track.
    static let player_trackNotPlayed = Notification.Name("player_trackNotPlayed")
    
    // Signifies that the current track is about to change in response to a request.
    static let player_preTrackChange = Notification.Name("player_preTrackChange")
    
    // Signifies that a track / playback state transition has occurred.
    // eg. when changing tracks or stopping playback
    static let player_trackTransitioned = Notification.Name("player_trackTransitioned")
    
    // Signifies that a track's info/metadata has been updated (eg. duration / album art)
    static let player_trackInfoUpdated = Notification.Name("player_trackInfoUpdated")
    
    // Signifies that the playback loop for the currently playing track has changed.
    // Either a new loop point has been defined, or an existing loop has been removed.
    static let player_playbackLoopChanged = Notification.Name("player_playbackLoopChanged")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Notifications published by the playlist.

    // Signifies that the playlist has begun adding a set of tracks.
    static let playlist_startedAddingTracks = Notification.Name("playlist_startedAddingTracks")
    
    // Signifies that the playlist has finished adding a set of tracks.
    static let playlist_doneAddingTracks = Notification.Name("playlist_doneAddingTracks")
    
    // Signifies that some chosen tracks could not be added to the playlist (i.e. an error condition).
    static let playlist_tracksNotAdded = Notification.Name("playlist_tracksNotAdded")
    
    // Signifies that the playlist view/tab has changed (tracks / artist / albums / genres).
    static let playlist_viewChanged = Notification.Name("playlist_viewChanged")
    
    // Signifies that, within the search dialog, the search query text has changed.
    static let playlist_searchTextChanged = Notification.Name("playlist_searchTextChanged")
    
    // Signifies that a new track has been added to the playlist.
    static let playlist_trackAdded = Notification.Name("playlist_trackAdded")
    
    // Signifies that some tracks have been removed from the playlist.
    static let playlist_tracksRemoved = Notification.Name("playlist_tracksRemoved")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Notifications published by the audio graph (i.e. audio engine).
    
    // Signifies that the audio output device for the audio engine has changed.
    // eg. when the user plugs headphones in or out of the system, or connects to
    // a new set of speakers.
    static let audioGraph_outputDeviceChanged = Notification.Name("audioGraph_outputDeviceChanged")
    
    static let audioGraph_preGraphChange = Notification.Name("audioGraph_preGraphChange")
    
    static let audioGraph_graphChanged = Notification.Name("audioGraph_graphChanged")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Notifications published by the presets editor.
    
    // Signifies that the number of rows selected in a NSTableView within the presets editor has changed.
    static let presetsEditor_selectionChanged = Notification.Name("presetsEditor_selectionChanged")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Playback commands (sent to the player)
    
    // Commands the player to play a specific track
    static let player_playTrack = Notification.Name("player_playTrack")
    
    // Commands the player to perform "autoplay"
    static let player_autoplay = Notification.Name("player_autoplay")
    
    // Commands the player to play, pause, or resume playback
    static let player_playOrPause = Notification.Name("player_playOrPause")

    // Commands the player to stop playback
    static let player_stop = Notification.Name("player_stop")

    // Commands the player to play the previous track in the current playback sequence
    static let player_previousTrack = Notification.Name("player_previousTrack")

    // Commands the player to play the next track in the current playback sequence
    static let player_nextTrack = Notification.Name("player_nextTrack")

    // Commands the player to replay the currently playing track from the beginning, if there is one
    static let player_replayTrack = Notification.Name("player_replayTrack")

    // Commands the player to seek backward within the currently playing track
    static let player_seekBackward = Notification.Name("player_seekBackward")

    // Commands the player to seek forward within the currently playing track
    static let player_seekForward = Notification.Name("player_seekForward")

    // Commands the player to seek backward within the currently playing track (secondary seek function - allows a different seek interval)
    static let player_seekBackward_secondary = Notification.Name("player_seekBackward_secondary")

    // Commands the player to seek forward within the currently playing track (secondary seek function - allows a different seek interval)
    static let player_seekForward_secondary = Notification.Name("player_seekForward_secondary")

    // Commands the player to seek to a specific position within the currently playing track
    static let player_jumpToTime = Notification.Name("player_jumpToTime")
    
    // Commands the player to toggle A->B segment playback loop
    static let player_toggleLoop = Notification.Name("player_toggleLoop")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Chapter playback commands (sent to the player)
    
    // Commands the player to play a specific chapter within the currently playing track.
    static let player_playChapter = Notification.Name("player_playChapter")
    
    // Commands the player to play the previous available chapter
    static let player_previousChapter = Notification.Name("player_previousChapter")
    
    // Commands the player to play the next available chapter
    static let player_nextChapter = Notification.Name("player_nextChapter")
    
    // Commands the player to replay the currently playing chapter from the beginning, if there is one
    static let player_replayChapter = Notification.Name("player_replayChapter")
    
    // Commands the player to toggle the current chapter playback loop
    static let player_toggleChapterLoop = Notification.Name("player_toggleChapterLoop")
    
    
    
    // MARK: Other player commands
    
    // Commands the player to save a playback profile (i.e. playback settings) for the current track.
    static let player_savePlaybackProfile = Notification.Name("player_savePlaybackProfile")

    // Commands the player to delete the playback profile (i.e. playback settings) for the current track.
    static let player_deletePlaybackProfile = Notification.Name("player_deletePlaybackProfile")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Player sound commands
    
    // Command to mute or unmute the player
    static let player_muteOrUnmute = Notification.Name("player_muteOrUnmute")
    
    // Command to decrease the volume by a certain preset decrement
    static let player_decreaseVolume = Notification.Name("player_decreaseVolume")

    // Command to increase the volume by a certain preset increment
    static let player_increaseVolume = Notification.Name("player_increaseVolume")

    // Command to pan the sound towards the left channel, by a certain preset value
    static let player_panLeft = Notification.Name("player_panLeft")

    // Command to pan the sound towards the right channel, by a certain preset value
    static let player_panRight = Notification.Name("player_panRight")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Player sequencing commands
    
    // Commands the player to set the repeat mode (to a specific value)
    static let player_setRepeatMode = Notification.Name("player_setRepeatMode")
    
    // Commands the player to set the shuffle mode (to a specific value)
    static let player_setShuffleMode = Notification.Name("player_setShuffleMode")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Player view commands
    
    // Commands the player to switch between the 2 views - Default and Expanded Art
    static let player_changeView = Notification.Name("player_changeView")

    // Commands the player to show or hide album art for the current track.
    static let player_showOrHideAlbumArt = Notification.Name("player_showOrHideAlbumArt")

    // Commands the player to show or hide artist info for the current track.
    static let player_showOrHideArtist = Notification.Name("player_showOrHideArtist")

    // Commands the player to show or hide album info for the current track.
    static let player_showOrHideAlbum = Notification.Name("player_showOrHideAlbum")

    // Commands the player to show or hide the current chapter title for the current track.
    static let player_showOrHideCurrentChapter = Notification.Name("player_showOrHideCurrentChapter")

    // Commands the player to show or hide all track info for the current track.
    static let player_showOrHidePlayingTrackInfo = Notification.Name("player_showOrHidePlayingTrackInfo")

    // Commands the player to show or hide the functions toolbar (ie. favorite/bookmark) for the current track.
    static let player_showOrHidePlayingTrackFunctions = Notification.Name("player_showOrHidePlayingTrackFunctions")

    // Commands the player to show or hide the main playback controls (i.e. seek bar, play/pause/seek)
    static let player_showOrHideMainControls = Notification.Name("player_showOrHideMainControls")
    
    // Commands the player to show or hide the seek time elapsed/remaining displays.
    static let player_showOrHideTimeElapsedRemaining = Notification.Name("player_showOrHideTimeElapsedRemaining")

    // Commands the player to set the format of the seek time elapsed display to a specific format.
    static let player_setTimeElapsedDisplayFormat = Notification.Name("player_setTimeElapsedDisplayFormat")

    // Commands the player to set the format of the seek time remaining display to a specific format.
    static let player_setTimeRemainingDisplayFormat = Notification.Name("player_setTimeRemainingDisplayFormat")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Playing track function commands
    
    // Commands the player to show detailed info for the currently playing track
    static let player_moreInfo = Notification.Name("player_moreInfo")
    
    // Commands the player to bookmark the current seek position for the currently playing track
    static let player_bookmarkPosition = Notification.Name("player_bookmarkPosition")

    // Commands the player to bookmark the current playback loop (if there is one) for the currently playing track
    static let player_bookmarkLoop = Notification.Name("player_bookmarkLoop")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Playlist commands

    // Commands a playlist to refresh its list view (eg. in response to tracks being added/removed/updated).
    static let playlist_refresh = Notification.Name("playlist_refresh")

    // Invokes the file dialog to add tracks to the playlist
    static let playlist_addTracks = Notification.Name("playlist_addTracks")

    // Commands the playlist to remove any selected tracks selected in the current playlist view.
    static let playlist_removeTracks = Notification.Name("playlist_removeTracks")

    // Commands the playlist to save the tracks in the playlist to a file
    static let playlist_savePlaylist = Notification.Name("playlist_savePlaylist")

    // Command to clear the playlist of all tracks
    static let playlist_clearPlaylist = Notification.Name("playlist_clearPlaylist")
    
    // Commands the playlist to initiate playback of a selected item.
    static let playlist_playSelectedItem = Notification.Name("playlist_playSelectedItem")

    // Commands the playlist to move selected tracks up one row.
    static let playlist_moveTracksUp = Notification.Name("playlist_moveTracksUp")

    // Commands the playlist to move selected tracks to the top.
    static let playlist_moveTracksToTop = Notification.Name("playlist_moveTracksToTop")

    // Commands the playlist to move selected tracks down one row.
    static let playlist_moveTracksDown = Notification.Name("playlist_moveTracksDown")

    // Commands the playlist to move selected tracks to the bottom.
    static let playlist_moveTracksToBottom = Notification.Name("playlist_moveTracksToBottom")
    
    // Commands the playlist to clear its current selection.
    static let playlist_clearSelection = Notification.Name("playlist_clearSelection")

    // Commands the playlist to invert its current selection.
    static let playlist_invertSelection = Notification.Name("playlist_invertSelection")

    // Commands the playlist to crop the current selection. i.e. only selected tracks will
    // remain, with all other tracks being removed.
    static let playlist_cropSelection = Notification.Name("playlist_cropSelection")
    
    // Commands the playlist to expand all selected groups to reveal their children (i.e. tracks)
    static let playlist_expandSelectedGroups = Notification.Name("playlist_expandSelectedGroups")

    // Commands the playlist to collapse all selected groups to hide their children (i.e. tracks)
    static let playlist_collapseSelectedItems = Notification.Name("playlist_collapseSelectedItems")

    // Commands the playlist to expand all groups to reveal their children (i.e. tracks)
    static let playlist_expandAllGroups = Notification.Name("playlist_expandAllGroups")

    // Commands the playlist to collapse all groups to hide their children (i.e. tracks)
    static let playlist_collapseAllGroups = Notification.Name("playlist_collapseAllGroups")
    
    // Commands the playlist to reveal (i.e. scroll to and select) the currently playing track.
    static let playlist_showPlayingTrack = Notification.Name("playlist_showPlayingTrack")

    // Commands the playlist to reveal the currently playing track in Finder.
    static let playlist_showTrackInFinder = Notification.Name("playlist_showTrackInFinder")
    
    // Commands the playlist to scroll to the top of its list view.
    static let playlist_scrollToTop = Notification.Name("playlist_scrollToTop")

    // Commands the playlist to scroll to the bottom of its list view.
    static let playlist_scrollToBottom = Notification.Name("playlist_scrollToBottom")

    // Commands the playlist to scroll one page up within its list view.
    static let playlist_pageUp = Notification.Name("playlist_pageUp")

    // Commands the playlist to scroll one page down within its list view.
    static let playlist_pageDown = Notification.Name("playlist_pageDown")
    
    // Commands the playlist to switch to the previous playlist view (in the tab group)
    static let playlist_previousView = Notification.Name("playlist_previousView")

    // Commands the playlist to switch to the next playlist view (in the tab group)
    static let playlist_nextView = Notification.Name("playlist_nextView")
    
    // Commands the playlist to show the chapters list window for the currently playing track
    static let playlist_viewChaptersList = Notification.Name("playlist_viewChaptersList")
    
    // Commands the playlist to invoke the search dialog
    static let playlist_search = Notification.Name("playlist_search")

    // Commands the playlist to invoke the sort dialog
    static let playlist_sort = Notification.Name("playlist_sort")
    
    // Commands the playlist to select a specific search result within the current list view.
    static let playlist_selectSearchResult = Notification.Name("playlist_selectSearchResult")

    // ----------------------------------------------------------------------------------------
    
    // MARK: Chapters List commands
    
    // Commands the chapters list to initiate playback of the selected chapter
    static let chaptersList_playSelectedChapter = Notification.Name("chaptersList_playSelectedChapter")

    // ----------------------------------------------------------------------------------------
    
    // MARK: FX commands
    
    // Commands the effects panel to switch the tab group to a specfic tab (to reveal a specific effects unit).
    static let fx_showFXUnitTab = Notification.Name("fx_showFXUnitTab")

    // Commands a particular effects unit to update its view
    static let fx_updateFXUnitView = Notification.Name("fx_updateFXUnitView")
    
    // Commands the audio graph to save the current sound settings (i.e. volume, pan, and effects) in a sound profile for the current track
    static let fx_saveSoundProfile = Notification.Name("fx_saveSoundProfile")

    // Commands the audio graph to delete the saved sound profile for the current track.
    static let fx_deleteSoundProfile = Notification.Name("fx_deleteSoundProfile")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Master FX unit commands

    // Commands the Master FX unit to toggle (i.e. disable/enable) all effects.
    static let masterFXUnit_toggleEffects = Notification.Name("masterFXUnit_toggleEffects")

    // ----------------------------------------------------------------------------------------
    
    // MARK: EQ FX unit commands
    
    // Commands the Equalizer FX unit to decrease gain for each of the bass bands by a certain preset decrement
    static let eqFXUnit_decreaseBass = Notification.Name("eqFXUnit_decreaseBass")

    // Commands the Equalizer FX unit to provide a "bass boost", i.e. increase gain for each of the bass bands by a certain preset increment.
    static let eqFXUnit_increaseBass = Notification.Name("eqFXUnit_increaseBass")

    // Commands the Equalizer FX unit to decrease gain for each of the mid-frequency bands by a certain preset decrement
    static let eqFXUnit_decreaseMids = Notification.Name("eqFXUnit_decreaseMids")
    
    // Commands the Equalizer FX unit to increase gain for each of the mid-frequency bands by a certain preset increment
    static let eqFXUnit_increaseMids = Notification.Name("eqFXUnit_increaseMids")

    // Commands the Equalizer FX unit to decrease gain for each of the treble bands by a certain preset decrement
    static let eqFXUnit_decreaseTreble = Notification.Name("eqFXUnit_decreaseTreble")
    
    // Commands the Equalizer FX unit to increase gain for each of the treble bands by a certain preset increment
    static let eqFXUnit_increaseTreble = Notification.Name("eqFXUnit_increaseTreble")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Pitch Shift FX unit commands
    
    // Commands the Pitch Shift FX unit to decrease the pitch by a certain preset decrement
    static let pitchFXUnit_decreasePitch = Notification.Name("pitchFXUnit_decreasePitch")

    // Commands the Pitch Shift FX unit to increase the pitch by a certain preset increment
    static let pitchFXUnit_increasePitch = Notification.Name("pitchFXUnit_increasePitch")

    // Commands the Pitch Shift FX unit to set the pitch to a specific value
    static let pitchFXUnit_setPitch = Notification.Name("pitchFXUnit_setPitch")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Time Stretch FX unit commands
    
    // Commands the Time Stretch FX unit to decrease the playback rate by a certain preset decrement
    static let timeFXUnit_decreaseRate = Notification.Name("timeFXUnit_decreaseRate")

    // Commands the Time Stretch FX unit to increase the playback rate by a certain preset increment
    static let timeFXUnit_increaseRate = Notification.Name("timeFXUnit_increaseRate")

    // Commands the Time Stretch FX unit to set the playback rate to a specific value
    static let timeFXUnit_setRate = Notification.Name("timeFXUnit_setRate")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Audio Units FX unit commands
    
    static let auFXUnit_showEditor = Notification.Name("auFXUnit_showEditor")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Window layout commands
    
    // Commands the window manager to show/hide the playlist window
    static let windowManager_togglePlaylistWindow = Notification.Name("windowManager_togglePlaylistWindow")

    // Commands the window manager to show/hide the effects window
    static let windowManager_toggleEffectsWindow = Notification.Name("windowManager_toggleEffectsWindow")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: FX presets editor commands

    // Commands the FX presets editor to reload all available FX presets for its currently selected tab
    static let fxPresetsEditor_reload = Notification.Name("fxPresetsEditor_reload")

    // Commands the FX presets editor to rename the single selected FX preset in its currently selected tab
    static let fxPresetsEditor_rename = Notification.Name("fxPresetsEditor_rename")

    // Commands the FX presets editor to delete all selected FX presets in its currently selected tab
    static let fxPresetsEditor_delete = Notification.Name("fxPresetsEditor_delete")

    // Commands the FX presets editor to apply the single selected FX preset in its currently selected tab
    static let fxPresetsEditor_apply = Notification.Name("fxPresetsEditor_apply")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Font scheme commands
    
    // Commands all UI components to apply a new specified font scheme.
    static let applyFontScheme = Notification.Name("applyFontScheme")

    // ----------------------------------------------------------------------------------------
    
    // MARK: Color scheme commands

    // Commands all UI components to apply a new specified color scheme.
    static let applyColorScheme = Notification.Name("applyColorScheme")
    
    // Commands the relevant UI components to change the color of the app's main logo.
    static let changeAppLogoColor = Notification.Name("changeAppLogoColor")

    // Commands all relevant UI components to change the color of their background.
    static let changeBackgroundColor = Notification.Name("changeBackgroundColor")

    // Commands all relevant UI components to change the color of their view control buttons (eg. close/settings buttons).
    static let changeViewControlButtonColor = Notification.Name("changeViewControlButtonColor")

    // Commands all relevant UI components to change the color of their function buttons (eg. play/seek buttons in the player).
    static let changeFunctionButtonColor = Notification.Name("changeFunctionButtonColor")

    // Commands all relevant UI components to change the color of their textual buttons/menus.
    static let changeTextButtonMenuColor = Notification.Name("changeTextButtonMenuColor")

    // Commands all relevant UI components to change the Off state color of their toggle buttons (eg. repeat/shuffle).
    static let changeToggleButtonOffStateColor = Notification.Name("changeToggleButtonOffStateColor")

    // Commands all relevant UI components to change the color of their selected tab buttons.
    static let changeSelectedTabButtonColor = Notification.Name("changeSelectedTabButtonColor")

    // Commands all relevant UI components to change the color of their main text captions.
    static let changeMainCaptionTextColor = Notification.Name("changeMainCaptionTextColor")

    // Commands all relevant UI components to change the color of their tab button text.
    static let changeTabButtonTextColor = Notification.Name("changeTabButtonTextColor")

    // Commands all relevant UI components to change the color of the text of their selected tab buttons.
    static let changeSelectedTabButtonTextColor = Notification.Name("changeSelectedTabButtonTextColor")

    // Commands all relevant UI components to change the color of the text within their textual buttons/menus.
    static let changeButtonMenuTextColor = Notification.Name("changeButtonMenuTextColor")
    
    
    
    // MARK: Color scheme commands sent to the player UI

    // Commands all relevant player UI components to change the color of their primary track info fields (eg. track name).
    static let player_changeTrackInfoPrimaryTextColor = Notification.Name("player_changeTrackInfoPrimaryTextColor")
    
    // Commands all relevant player UI components to change the color of their secondary track info fields (eg. artist name).
    static let player_changeTrackInfoSecondaryTextColor = Notification.Name("player_changeTrackInfoSecondaryTextColor")

    // Commands all relevant player UI components to change the color of their tertiary track info fields (eg. current chapter title).
    static let player_changeTrackInfoTertiaryTextColor = Notification.Name("player_changeTrackInfoTertiaryTextColor")

    // Commands all relevant player UI components to change the color of the feedback text associated with their sliders (eg. seek bar / volume).
    static let player_changeSliderValueTextColor = Notification.Name("player_changeSliderValueTextColor")

    // Commands all relevant player UI components to redraw their sliders.
    static let player_changeSliderColors = Notification.Name("player_changeSliderColors")
    
    
    
    // MARK: Color scheme commands sent to the playlist UI
    
    // Commands all playlist views to change the color of the text in their track name column.
    static let playlist_changeTrackNameTextColor = Notification.Name("playlist_changeTrackNameTextColor")

    // Commands all playlist views to change the color of the text in their group name column.
    static let playlist_changeGroupNameTextColor = Notification.Name("playlist_changeGroupNameTextColor")

    // Commands all playlist views to change the color of the text in their index/duration columns.
    static let playlist_changeIndexDurationTextColor = Notification.Name("playlist_changeIndexDurationTextColor")

    // Commands all playlist views to change the color of the text in selected rows, in the track name column.
    static let playlist_changeTrackNameSelectedTextColor = Notification.Name("playlist_changeTrackNameSelectedTextColor")

    // Commands all playlist views to change the color of the text in selected rows, in the group name column.
    static let playlist_changeGroupNameSelectedTextColor = Notification.Name("playlist_changeGroupNameSelectedTextColor")

    // Commands all playlist views to change the color of the text in selected rows, in the index/duration columns.
    static let playlist_changeIndexDurationSelectedTextColor = Notification.Name("playlist_changeIndexDurationSelectedTextColor")

    // Commands all playlist views to change the color of their summary info text.
    static let playlist_changeSummaryInfoColor = Notification.Name("playlist_changeSummaryInfoColor")

    // Commands all playlist views to change the color of their group icons.
    static let playlist_changeGroupIconColor = Notification.Name("playlist_changeGroupIconColor")
    
    // Commands all playlist views to change the color of their group disclosure triangles.
    static let playlist_changeGroupDisclosureTriangleColor = Notification.Name("playlist_changeGroupDisclosureTriangleColor")
    
    // Commands all playlist views to change the color of their selection boxes.
    static let playlist_changeSelectionBoxColor = Notification.Name("playlist_changeSelectionBoxColor")

    // Commands all playlist views to change the color of their playing track marker icons.
    static let playlist_changePlayingTrackIconColor = Notification.Name("playlist_changePlayingTrackIconColor")
    
    // MARK: Color scheme commands sent to the FX UI
    
    // Commands all FX views to change the text color of their function caption labels.
    static let fx_changeFunctionCaptionTextColor = Notification.Name("fx_changeFunctionCaptionTextColor")

    // Commands all FX views to change the text color of their function value labels.
    static let fx_changeFunctionValueTextColor = Notification.Name("fx_changeFunctionValueTextColor")

    // Commands all FX views to redraw their slider controls.
    static let fx_changeSliderColors = Notification.Name("fx_changeSliderColors")

    // Commands FX views corresponding to "active" FX units, to redraw all their controls.
    static let fx_changeActiveUnitStateColor = Notification.Name("fx_changeActiveUnitStateColor")

    // Commands FX views corresponding to "bypassed" FX units, to redraw all their controls.
    static let fx_changeBypassedUnitStateColor = Notification.Name("fx_changeBypassedUnitStateColor")

    // Commands FX views corresponding to "suppressed" FX units, to redraw all their controls.
    static let fx_changeSuppressedUnitStateColor = Notification.Name("fx_changeSuppressedUnitStateColor")
    
    // MARK: Window appearance commands sent to all app windows
    
    static let windowAppearance_changeCornerRadius = Notification.Name("windowAppearance_changeCornerRadius")
    
    static let applyTheme = Notification.Name("applyTheme")
    
    // MARK: Visualizer commands sent to all app windows
    
    static let visualizer_showOptions = Notification.Name("visualizer_showOptions")
    static let visualizer_hideOptions = Notification.Name("visualizer_hideOptions")
    
    // MARK: File system notifications sent to Tune Browser
    
    static let fileSystem_fileMetadataLoaded = Notification.Name("fileSystem_fileMetadataLoaded")
    
    // MARK: Tune Browser notifications
    
    static let tuneBrowser_sidebarSelectionChanged = Notification.Name("tuneBrowser_sidebarSelectionChanged")
}
