//
//  PlaybackMenuController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Provides actions for the Playback menu that affect the playing track and playback sequence (repeat/shuffle modes).
 
    NOTE - No actions are directly handled by this class. Command notifications are published to another app component that is responsible for these functions.
 */
class PlaybackMenuController: NSObject, NSMenuDelegate {
    
    // Menu items whose states are toggled when they (or others) are clicked
    
    @IBOutlet weak var playOrPauseMenuItem: NSMenuItem!     // Needs to be toggled
    @IBOutlet weak var gaplessPlaybackMenuItem: NSMenuItem!
    @IBOutlet weak var stopMenuItem: NSMenuItem!

    @IBOutlet weak var previousTrackMenuItem: NSMenuItem!
    @IBOutlet weak var nextTrackMenuItem: NSMenuItem!
    @IBOutlet weak var replayTrackMenuItem: NSMenuItem!
    @IBOutlet weak var loopMenuItem: NSMenuItem!
    
    @IBOutlet weak var previousChapterMenuItem: NSMenuItem!
    @IBOutlet weak var nextChapterMenuItem: NSMenuItem!
    @IBOutlet weak var replayChapterMenuItem: NSMenuItem!
    @IBOutlet weak var loopChapterMenuItem: NSMenuItem!
    
    @IBOutlet weak var seekForwardMenuItem: NSMenuItem!
    @IBOutlet weak var seekBackwardMenuItem: NSMenuItem!
    @IBOutlet weak var seekForwardSecondaryMenuItem: NSMenuItem!
    @IBOutlet weak var seekBackwardSecondaryMenuItem: NSMenuItem!
    @IBOutlet weak var jumpToTimeMenuItem: NSMenuItem!
    
    @IBOutlet weak var detailedInfoMenuItem: NSMenuItem!
    @IBOutlet weak var showInPlayQueueMenuItem: NSMenuItem!
    
    // Playback repeat modes
    @IBOutlet weak var repeatOffMenuItem: NSMenuItem!
    @IBOutlet weak var repeatOneMenuItem: NSMenuItem!
    @IBOutlet weak var repeatAllMenuItem: NSMenuItem!
    
    // Playback shuffle modes
    @IBOutlet weak var shuffleOffMenuItem: NSMenuItem!
    @IBOutlet weak var shuffleOnMenuItem: NSMenuItem!
    @IBOutlet weak var toggleShuffleModeMenuItem: NSMenuItem!
    @IBOutlet weak var shuffleModeSubMenuItem: NSMenuItem!
    
    @IBOutlet weak var rememberLastPositionMenuItem: ToggleMenuItem!
    
    private let playbackPreferences: PlaybackPreferences = preferences.playbackPreferences
    
    private lazy var jumpToTimeDialogLoader: LazyWindowLoader<JumpToTimeEditorWindowController> = LazyWindowLoader()
    
    // One-time setup
    override func awakeFromNib() {
        playOrPauseMenuItem.off()
    }
    
    // When the menu is about to open, update the menu item states
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        let playbackState = player.state
        let isPlayingOrPaused = playbackState.isPlayingOrPaused
        let isShowingPlayQueue = appModeManager.isShowingPlayQueue
        let noTrack = playbackState == .stopped
        
        let notInGaplessMode = !player.isInGaplessPlaybackMode
        let hasChapters = player.chapterCount > 0
        
        // Play/pause enabled if at least one track available
        playOrPauseMenuItem.enableIf(playQueueDelegate.size > 0 && !NSApp.isReceivingTextInput)
        
        gaplessPlaybackMenuItem.enableIf(noTrack && playQueueDelegate.size > 1 && (!playQueueDelegate.isBeingModified))
        
        stopMenuItem.enableIf(!noTrack)
        jumpToTimeMenuItem?.enableIf(isPlayingOrPaused)
        
        // Enabled only if playing/paused
        let isReceivingTextInput: Bool = NSApp.isReceivingTextInput
        
        if appModeManager.currentMode == .modular {
            showInPlayQueueMenuItem.enableIf(isPlayingOrPaused && isShowingPlayQueue)
        } else {
            showInPlayQueueMenuItem.enableIf(isPlayingOrPaused)
        }
        
        [replayTrackMenuItem, detailedInfoMenuItem].forEach {$0?.enableIf(isPlayingOrPaused)}
        loopMenuItem.enableIf(isPlayingOrPaused && notInGaplessMode)
        
        // Should not invoke these items when a popover is being displayed (because of the keyboard shortcuts which conflict with the CMD arrow and Alt arrow functions when editing text within a popover)

        [previousTrackMenuItem, nextTrackMenuItem].forEach {$0.enableIf(!(noTrack || isReceivingTextInput))}
        
        // These items should be enabled only if there is a playing track and it has chapter markings
        [previousChapterMenuItem, nextChapterMenuItem, replayChapterMenuItem].forEach {$0?.enableIf(hasChapters)}
        loopChapterMenuItem.enableIf(hasChapters && notInGaplessMode)
        
        [seekForwardMenuItem, seekBackwardMenuItem, seekForwardSecondaryMenuItem, seekBackwardSecondaryMenuItem].forEach {
            $0?.enableIf(isPlayingOrPaused && (!isReceivingTextInput))
        }
        
        [repeatOneMenuItem, shuffleOnMenuItem, toggleShuffleModeMenuItem, shuffleModeSubMenuItem].forEach {
            $0.enableIf(notInGaplessMode)
        }
        
        rememberLastPositionMenuItem.enableIf(isPlayingOrPaused && notInGaplessMode)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        updateRepeatAndShuffleMenuItemStates()
        
        // Play/pause enabled if at least one track available
        playOrPauseMenuItem.onIf(player.isPlaying)
        rememberLastPositionMenuItem.showIf(!playbackPreferences.rememberLastPositionForAllTracks)
        
        if let playingTrack = player.playingTrack {
            rememberLastPositionMenuItem.onIf(playbackProfiles.hasFor(playingTrack))
        }
    }
    
    // MARK: Basic playback functions (tracks)
    
    // Plays, pauses or resumes playback
    @IBAction func playOrPauseAction(_ sender: AnyObject) {
        Messenger.publish(.Player.playOrPause)
    }
    
    @IBAction func beginGaplessPlaybackAction(_ sender: AnyObject) {
        Messenger.publish(.Player.beginGaplessPlayback)
    }
    
    @IBAction func stopAction(_ sender: AnyObject) {
        Messenger.publish(.Player.stop)
    }
    
    // Plays the previous track in the current playback sequence
    @IBAction func previousTrackAction(_ sender: AnyObject) {
        Messenger.publish(.Player.previousTrack)
    }
    
    // Plays the next track in the current playback sequence
    @IBAction func nextTrackAction(_ sender: AnyObject) {
        Messenger.publish(.Player.nextTrack)
    }
    
    // Replays the currently playing track from the beginning, if there is one
    @IBAction func replayTrackAction(_ sender: AnyObject) {
        Messenger.publish(.Player.replayTrack)
    }
    
    // Toggles A ⇋ B playback loop
    @IBAction func toggleLoopAction(_ sender: AnyObject) {
        Messenger.publish(.Player.toggleLoop)
    }
    
    // MARK: Basic playback functions (chapters)
    
    // Plays the previous available chapter
    @IBAction func previousChapterAction(_ sender: AnyObject) {
        Messenger.publish(.Player.previousChapter)
    }
    
    // Plays the next available chapter
    @IBAction func nextChapterAction(_ sender: AnyObject) {
        Messenger.publish(.Player.nextChapter)
    }
    
    // Replays the currently playing chapter from the beginning, if there is one
    @IBAction func replayChapterAction(_ sender: AnyObject) {
        Messenger.publish(.Player.replayChapter)
    }
    
    // Toggles current chapter playback loop
    @IBAction func toggleChapterLoopAction(_ sender: AnyObject) {
        Messenger.publish(.Player.toggleChapterLoop)
    }
    
    // MARK: Seeking functions
    
    // Seeks backward within the currently playing track
    @IBAction func seekBackwardAction(_ sender: AnyObject) {
        Messenger.publish(.Player.seekBackward, payload: UserInputMode.discrete)
    }
    
    // Seeks forward within the currently playing track
    @IBAction func seekForwardAction(_ sender: AnyObject) {
        Messenger.publish(.Player.seekForward, payload: UserInputMode.discrete)
    }
    
    // Seeks backward within the currently playing track
    @IBAction func seekBackwardSecondaryAction(_ sender: AnyObject) {
        Messenger.publish(.Player.seekBackward_secondary)
    }
    
    // Seeks forward within the currently playing track
    @IBAction func seekForwardSecondaryAction(_ sender: AnyObject) {
        Messenger.publish(.Player.seekForward_secondary)
    }
    
    @IBAction func jumpToTimeAction(_ sender: AnyObject) {
        _ = jumpToTimeDialogLoader.controller.showDialog()
    }
    
    // MARK: Repeat and Shuffle
    
    // Sets the repeat mode to "Off"
    @IBAction func repeatOffAction(_ sender: AnyObject) {
        Messenger.publish(.Player.setRepeatMode, payload: RepeatMode.off)
    }
    
    // Sets the repeat mode to "Repeat One"
    @IBAction func repeatOneAction(_ sender: AnyObject) {
        Messenger.publish(.Player.setRepeatMode, payload: RepeatMode.one)
    }
    
    // Sets the repeat mode to "Repeat All"
    @IBAction func repeatAllAction(_ sender: AnyObject) {
        Messenger.publish(.Player.setRepeatMode, payload: RepeatMode.all)
    }
    
    // Toggles the repeat mode.
    @IBAction func toggleRepeatModeAction(_ sender: AnyObject) {
        Messenger.publish(.Player.toggleRepeatMode)
    }
    
    // Sets the shuffle mode to "Off"
    @IBAction func shuffleOffAction(_ sender: AnyObject) {
        Messenger.publish(.Player.setShuffleMode, payload: ShuffleMode.off)
    }
    
    // Sets the shuffle mode to "On"
    @IBAction func shuffleOnAction(_ sender: AnyObject) {
        Messenger.publish(.Player.setShuffleMode, payload: ShuffleMode.on)
    }
    
    // Toggles the shuffle mode.
    @IBAction func toggleShuffleModeAction(_ sender: AnyObject) {
        Messenger.publish(.Player.toggleShuffleMode)
    }
    
    // MARK: Miscellaneous playing track functions
    
    @IBAction func moreInfoAction(_ sender: AnyObject) {
        Messenger.publish(.Player.trackInfo)
    }
    
    // Shows (selects) the currently playing track, within the playlist, if there is one
    @IBAction func showPlayingTrackAction(_ sender: Any) {
        Messenger.publish(.PlayQueue.showPlayingTrack)
    }
    
    @IBAction func rememberLastPositionAction(_ sender: ToggleMenuItem) {
        Messenger.publish(!rememberLastPositionMenuItem.isOn ? .Player.savePlaybackProfile : .Player.deletePlaybackProfile)
    }
    
    // Updates the menu item states per the current playback modes
    private func updateRepeatAndShuffleMenuItemStates() {
        
        let modes = playQueueDelegate.repeatAndShuffleModes
        
        shuffleOffMenuItem.onIf(modes.shuffleMode == .off)
        shuffleOnMenuItem.onIf(modes.shuffleMode == .on)
        
        [repeatOffMenuItem, repeatOneMenuItem, repeatAllMenuItem].forEach {$0?.off()}
        
        switch modes.repeatMode {
            
        case .off:
            repeatOffMenuItem.on()
            
        case .all:
            repeatAllMenuItem.on()
            
        case .one:
            repeatOneMenuItem.on()
        }
    }
    
    deinit {
        jumpToTimeDialogLoader.destroy()
    }
}
