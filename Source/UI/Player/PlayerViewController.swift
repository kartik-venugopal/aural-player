//
//  PlayerViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class PlayerViewController: NSViewController {
    
    @IBOutlet weak var artView: NSImageView!
    
    @IBOutlet weak var multilineTrackTextView: MultilineTrackTextView!
    var textScrollView: NSScrollView! {
        multilineTrackTextView.clipView.enclosingScrollView
    }
    
    @IBOutlet weak var scrollingTrackTextView: ScrollingTrackTextView!
    
    @IBOutlet weak var lblPlaybackPosition: NSTextField!
    
    // Toggle buttons (their images change)
    @IBOutlet weak var btnPlayPause: NSButton!
    
    // Buttons whose tool tips may change
    @IBOutlet weak var btnPreviousTrack: NSButton!
    @IBOutlet weak var btnNextTrack: NSButton!
    
    @IBOutlet weak var btnRepeat: NSButton!
    @IBOutlet weak var btnShuffle: NSButton!
    @IBOutlet weak var btnLoop: NSButton!
    
    @IBOutlet weak var scrollingTextViewContainerBox: NSBox!
    
    lazy var btnPlayPauseStateMachine: ButtonStateMachine<PlaybackState> =
    
    ButtonStateMachine(initialState: playbackDelegate.state,
                       mappings: [
                        ButtonStateMachine.StateMapping(state: .stopped, image: .imgPlay, colorProperty: \.buttonColor, toolTip: "Play"),
                        ButtonStateMachine.StateMapping(state: .playing, image: .imgPause, colorProperty: \.buttonColor, toolTip: "Pause"),
                        ButtonStateMachine.StateMapping(state: .paused, image: .imgPlay, colorProperty: \.buttonColor, toolTip: "Play")
                       ],
                       button: btnPlayPause)
    
    lazy var btnRepeatStateMachine: ButtonStateMachine<RepeatMode> = ButtonStateMachine(initialState: playQueueDelegate.repeatAndShuffleModes.repeatMode,
                                                                                                mappings: [
                                                                                                    ButtonStateMachine.StateMapping(state: .off, image: .imgRepeat, colorProperty: \.inactiveControlColor, toolTip: "Repeat"),
                                                                                                    ButtonStateMachine.StateMapping(state: .all, image: .imgRepeat, colorProperty: \.activeControlColor, toolTip: "Repeat"),
                                                                                                    ButtonStateMachine.StateMapping(state: .one, image: .imgRepeatOne, colorProperty: \.activeControlColor, toolTip: "Repeat")
                                                                                                ],
                                                                                                button: btnRepeat)
    
    lazy var btnShuffleStateMachine: ButtonStateMachine<ShuffleMode> = ButtonStateMachine(initialState: playQueueDelegate.repeatAndShuffleModes.shuffleMode,
                                                                                                  mappings: [
                                                                                                    ButtonStateMachine.StateMapping(state: .off, image: .imgShuffle, colorProperty: \.inactiveControlColor, toolTip: "Shuffle"),
                                                                                                    ButtonStateMachine.StateMapping(state: .on, image: .imgShuffle, colorProperty: \.activeControlColor, toolTip: "Shuffle")
                                                                                                  ],
                                                                                                  button: btnShuffle)
    
    lazy var btnLoopStateMachine: ButtonStateMachine<PlaybackLoopState> = ButtonStateMachine(initialState: playbackDelegate.playbackLoopState,
                                                                                                     mappings: [
                                                                                                        ButtonStateMachine.StateMapping(state: .none, image: .imgLoop, colorProperty: \.inactiveControlColor, toolTip: "Initiate a segment loop"),
                                                                                                        ButtonStateMachine.StateMapping(state: .started, image: .imgLoopStarted, colorProperty: \.activeControlColor, toolTip: "Complete the segment loop"),
                                                                                                        ButtonStateMachine.StateMapping(state: .complete, image: .imgLoop, colorProperty: \.activeControlColor, toolTip: "Remove the segment loop")
                                                                                                     ],
                                                                                                     button: btnLoop)
    
    @IBOutlet weak var btnSeekBackward: NSButton!
    @IBOutlet weak var btnSeekForward: NSButton!
    
    // Shows the time elapsed for the currently playing track, and allows arbitrary seeking within the track
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var seekSliderCell: SeekSliderCell!
    
    // Volume/pan controls
    @IBOutlet weak var btnVolume: NSButton!
    @IBOutlet weak var volumeSlider: NSSlider!
    
    @IBOutlet weak var lblVolume: VALabel!
    
    // Wrappers around the feedback labels that automatically hide them after showing them for a brief interval
    lazy var autoHidingVolumeLabel: AutoHidingView = AutoHidingView(lblVolume, Self.feedbackLabelAutoHideIntervalSeconds)
    
    // Timer that periodically updates the seek position slider and label
    lazy var seekTimer: RepeatingTaskExecutor = RepeatingTaskExecutor(intervalMillis: (1000 / (2 * audioGraph.timeStretchUnit.effectiveRate)).roundedInt,
                                                                      task: {[weak self] in
                                                                        self?.updateSeekPosition()},
                                                                      queue: .main)
    
    let seekTimerTaskQueue: SeekTimerTaskQueue = .instance
    
    // Keeps track of the last known value of the current chapter (used to detect chapter changes)
    var curChapter: IndexedChapter? = nil
    
    lazy var messenger = Messenger(for: self)
    
    // Numerical ranges
    let highVolumeRange: ClosedRange<Float> = 200.0/3...100
    let mediumVolumeRange: Range<Float> = 100.0/3..<200.0/3
    let lowVolumeRange: Range<Float> = 1..<100.0/3
    
    // Time intervals for which feedback labels or views that are to be auto-hidden are displayed, before being hidden.
    static let feedbackLabelAutoHideIntervalSeconds: TimeInterval = 1
    
    private var artViewConstraints: LayoutConstraintsManager!
    private var textViewConstraints: LayoutConstraintsManager!
    private var lblPlaybackPositionConstraints: LayoutConstraintsManager!
    private var seekSliderConstraints: LayoutConstraintsManager!
    
    private static let chapterChangePollingTaskId: String = "ChapterChangePollingTask"
    
    var showPlaybackPosition: Bool {
        playerUIState.showPlaybackPosition
    }
    
    var displaysChapterIndicator: Bool {
        true
    }
    
    var playbackPositionFont: NSFont {
        systemFontScheme.normalFont
    }
    
    var playbackPositionColor: NSColor {
        systemColorScheme.primaryTextColor
    }
    
    var volumeLevelFont: NSFont {
        systemFontScheme.smallFont
    }
    
    var volumeLevelColor: NSColor {
        systemColorScheme.secondaryTextColor
    }
    
    var multilineTrackTextTitleFont: NSFont {
        systemFontScheme.prominentFont
    }
    
    var multilineTrackTextTitleColor: NSColor {
        systemColorScheme.primaryTextColor
    }
    
    var multilineTrackTextArtistAlbumFont: NSFont {
        systemFontScheme.normalFont
    }
    
    var multilineTrackTextArtistAlbumColor: NSColor {
        systemColorScheme.secondaryTextColor
    }
    
    var multilineTrackTextChapterTitleFont: NSFont {
        systemFontScheme.smallFont
    }
    
    var multilineTrackTextChapterTitleColor: NSColor {
        systemColorScheme.tertiaryTextColor
    }
    
    var scrollingTrackTextFont: NSFont {
        systemFontScheme.normalFont
    }
    
    var scrollingTrackTextTitleColor: NSColor {
        systemColorScheme.primaryTextColor
    }
    
    var scrollingTrackTextArtistColor: NSColor {
        systemColorScheme.secondaryTextColor
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setUpTrackInfoView()
        setUpPlaybackControls()
        setUpTheming()
        
        trackChanged(to: playbackDelegate.playingTrack)
        
        setUpNotificationHandling()
        setUpCommandHandling()
    }
    
    func setUpTrackInfoView() {
        showOrHideAlbumArt()
    }
    
    func setUpScrollingTrackInfoView() {
        
        scrollingTrackTextView.anchorToSuperview()
        
        artViewConstraints = LayoutConstraintsManager(for: artView)
        artViewConstraints.setWidth(48)
        artViewConstraints.setHeight(48)
        
        // Constraint managers
        lblPlaybackPositionConstraints = LayoutConstraintsManager(for: lblPlaybackPosition)
        seekSliderConstraints = LayoutConstraintsManager(for: seekSlider)
        textViewConstraints = LayoutConstraintsManager(for: scrollingTextViewContainerBox)
        
        // Seek slider
        seekSliderConstraints.setLeading(relatedToLeadingOf: scrollingTrackTextView, offset: -1)
        seekSliderConstraints.setTrailing(relatedToLeadingOf: btnRepeat, offset: -Self.distanceBetweenControlsAndInfo)
        
        lblPlaybackPositionConstraints.setHeight(scrollingTrackTextView.height)
        lblPlaybackPositionConstraints.centerVerticallyInSuperview(offset: 0)
        
        layoutScrollingTrackTextView()
        scrollingTrackTextView.scrollingEnabled = widgetPlayerUIState.trackInfoScrollingEnabled
    }
    
    private static let distanceBetweenControlsAndInfo: CGFloat = 31
    
    ///
    /// Computes the maximum required width for the seek position label, given
    /// 1. the duration of the track currently playing, and
    /// 2. the current font scheme.
    ///
    var widthForSeekPosLabel: CGFloat {
        
        guard let track = playbackDelegate.playingTrack else {return 0}
        
        let widthOfWidestNumber = String.widthOfWidestNumber(forFont: playbackPositionFont)
        let duration = track.duration
        
        let playbackPositions = ValueFormatter.formatPlaybackPositions(0, duration, 0)
        let widthOfTimeRemainingString = CGFloat(playbackPositions.remaining.count)

        return widthOfTimeRemainingString * widthOfWidestNumber
    }
    
    func layoutScrollingTrackTextView() {
        
        var labelWidth: CGFloat = 0
        
        if showPlaybackPosition {
            
            lblPlaybackPositionConstraints.removeAll(withAttributes: [.width, .trailing])
            labelWidth = widthForSeekPosLabel + 5 // Compute the required width and add some padding.
            
            lblPlaybackPositionConstraints.setWidth(labelWidth)
            lblPlaybackPositionConstraints.setTrailing(relatedToLeadingOf: btnRepeat, offset: -Self.distanceBetweenControlsAndInfo)
        }
        
        // Text view
        textViewConstraints.removeAll(withAttributes: [.trailing])
        textViewConstraints.setTrailing(relatedToLeadingOf: btnRepeat,
                                        offset: -(Self.distanceBetweenControlsAndInfo + (showPlaybackPosition ? labelWidth : 1)))
    }
    
    func setUpPlaybackControls() {
        
        lblPlaybackPosition.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(self.togglePlaybackPositionDisplayTypeAction(_:))))
        
        if var peekingPreviousTrackButton = btnPreviousTrack as? TrackPeekingButtonProtocol {
            
            peekingPreviousTrackButton.toolTipFunction = {
                
                if let prevTrack = playQueueDelegate.peekPrevious() {
                    return String(format: "Previous track: '%@'", prevTrack.displayName)
                }
                
                return nil
            }
        }
        
        if var peekingNextTrackButton = btnNextTrack as? TrackPeekingButtonProtocol {
            
            peekingNextTrackButton.toolTipFunction = {
                
                if let nextTrack = playQueueDelegate.peekNext() {
                    return String(format: "Next track: '%@'", nextTrack.displayName)
                }

                return nil
            }
        }
        
        showOrHideMainControls()
    }
    
    func trackChanged(to newTrack: Track?) {
        
        updateTrackInfo(for: newTrack, playingChapterTitle: playbackDelegate.playingChapter?.chapter.title)
        updatePlaybackControls(for: newTrack)
    }
    
    func updateTrackInfo(for track: Track?, playingChapterTitle: String? = nil) {
        
        updateTrackTextView(for: track, playingChapterTitle: playingChapterTitle)
        updateCoverArt(for: track)
    }
    
    func updateTrackTextView(for track: Track?, playingChapterTitle: String? = nil) {
        // To be overriden!
    }
    
    func updateMultilineTrackTextView(for track: Track?, playingChapterTitle: String? = nil) {
        
        if let theTrack = track {
            multilineTrackTextView.trackInfo = PlayingTrackInfo(track: theTrack, playingChapterTitle: playingChapterTitle)
            
        } else {
            multilineTrackTextView.trackInfo = nil
        }
    }
    
    func updateScrollingTrackTextView(for track: Track?) {
        
        layoutScrollingTrackTextView()
        
        if let theTrack = track {
            scrollingTrackTextView.update(artist: theTrack.artist, title: theTrack.title ?? theTrack.defaultDisplayName)
            
        } else {
            scrollingTrackTextView.clear()
        }
    }
    
    func updateCoverArt(for track: Track?) {
        
        if let trackArt = track?.art {
            
            artView.image = trackArt.originalOrDownscaledImage
            artView.contentTintColor = nil
            artView.image?.isTemplate = false
            
        } else {

            artView.image = .imgPlayingArt
            artView.contentTintColor = systemColorScheme.secondaryTextColor
            artView.image?.isTemplate = true
        }
    }
    
    func updateDuration(for track: Track?) {
        updateSeekPosition()
    }
    
    func updatePlaybackControls(for track: Track?) {
        
        // Button state
        
        btnPlayPauseStateMachine.setState(playbackDelegate.state)
        updateRepeatAndShuffleControls(modes: playQueueDelegate.repeatAndShuffleModes)
        
        // Seek controls state
        
        let isPlayingTrack = track != nil
        seekSlider.enableIf(isPlayingTrack)
        seekSlider.showIf(isPlayingTrack)
        lblPlaybackPosition.showIf(isPlayingTrack && showPlaybackPosition)
        playbackLoopChanged()
        
        // Seek timer tasks
        
        if displaysChapterIndicator {
            
            if track?.hasChapters ?? false {
                beginPollingForChapterChange()
            } else {
                stopPollingForChapterChange()
            }
        }
        
        updateSeekTimerState()
        
        // Volume controls
        
        // Volume may have changed because of sound profiles
        volumeChanged(volume: audioGraph.scaledVolume, muted: audioGraph.muted)
    }
    
    // Creates a recurring task that polls the player to detect a change in the currently playing track chapter.
    // This only occurs when the currently playing track actually has chapters.
    func beginPollingForChapterChange() {
        
        seekTimerTaskQueue.enqueueTask(Self.chapterChangePollingTaskId, {
            
            let playingChapter: IndexedChapter? = playbackDelegate.playingChapter
            
            // Compare the current chapter with the last known value of current chapter.
            if self.curChapter != playingChapter {
                
                // There has been a change ... notify observers and update the variable.
                self.messenger.publish(ChapterChangedNotification(oldChapter: self.curChapter, newChapter: playingChapter))
                self.curChapter = playingChapter
            }
        })
    }
    
    // Disables the chapter change polling task
    func stopPollingForChapterChange() {
        seekTimerTaskQueue.dequeueTask(Self.chapterChangePollingTaskId)
    }
    
    func setUpCommandHandling() {
        
        messenger.subscribeAsync(to: .Player.playTrack, handler: performTrackPlayback(_:))
        
        messenger.subscribe(to: .Player.muteOrUnmute, handler: muteOrUnmute)
        messenger.subscribe(to: .Player.decreaseVolume, handler: decreaseVolume(inputMode:))
        messenger.subscribe(to: .Player.increaseVolume, handler: increaseVolume(inputMode:))
        
        messenger.subscribe(to: .Player.playOrPause, handler: playOrPause)
        messenger.subscribe(to: .Player.beginGaplessPlayback, handler: beginGaplessPlayback)
        messenger.subscribe(to: .Player.stop, handler: stop)
        messenger.subscribe(to: .Player.replayTrack, handler: replayTrack)
        messenger.subscribe(to: .Player.previousTrack, handler: previousTrack)
        messenger.subscribe(to: .Player.nextTrack, handler: nextTrack)
        messenger.subscribe(to: .Player.seekBackward, handler: seekBackward(inputMode:))
        messenger.subscribe(to: .Player.seekForward, handler: seekForward(inputMode:))
        messenger.subscribe(to: .Player.seekBackward_secondary, handler: seekBackward_secondary)
        messenger.subscribe(to: .Player.seekForward_secondary, handler: seekForward_secondary)
        messenger.subscribe(to: .Player.seekToPercentage, handler: seekToPercentage(_:))
        messenger.subscribe(to: .Player.jumpToTime, handler: jumpToTime(_:))
        messenger.subscribe(to: .Player.toggleLoop, handler: toggleLoop)
        
        messenger.subscribe(to: .Player.setRepeatMode, handler: setRepeatMode(to:))
        messenger.subscribe(to: .Player.toggleRepeatMode, handler: toggleRepeatMode)
        messenger.subscribe(to: .Player.setShuffleMode, handler: setShuffleMode(to:))
        messenger.subscribe(to: .Player.toggleShuffleMode, handler: toggleShuffleMode)
        messenger.subscribe(to: .Player.setRepeatAndShuffleModes, handler: setRepeatAndShuffleModes(_:))
        
        messenger.subscribe(to: .Player.playChapter, handler: playChapter(index:))
        messenger.subscribe(to: .Player.previousChapter, handler: previousChapter)
        messenger.subscribe(to: .Player.nextChapter, handler: nextChapter)
        messenger.subscribe(to: .Player.replayChapter, handler: replayChapter)
        messenger.subscribe(to: .Player.toggleChapterLoop, handler: toggleChapterLoop)
        
        messenger.subscribe(to: .Player.showOrHideAlbumArt, handler: showOrHideAlbumArt)
        messenger.subscribe(to: .Player.showOrHideArtist, handler: showOrHideArtist)
        messenger.subscribe(to: .Player.showOrHideAlbum, handler: showOrHideAlbum)
        messenger.subscribe(to: .Player.showOrHideCurrentChapter, handler: showOrHideCurrentChapter)
        messenger.subscribe(to: .Player.showOrHideMainControls, handler: showOrHideMainControls)
        messenger.subscribe(to: .Player.showOrHidePlaybackPosition, handler: showOrHidePlaybackPosition)
        messenger.subscribe(to: .Player.setPlaybackPositionDisplayType, handler: setPlaybackPositionDisplayType(to:))
        
        messenger.subscribe(to: .Player.trackInfo, handler: showTrackInfo(for:))
        
        messenger.subscribe(to: .Lyrics.addLyricsFile, handler: addLyricsFile)
        messenger.subscribe(to: .Lyrics.searchForLyricsOnline, handler: searchForLyricsOnline)
        messenger.subscribe(to: .Lyrics.removeDownloadedLyrics, handler: removeDownloadedLyrics)
    }
    
    func previousTrack() {
        playbackDelegate.previousTrack()
    }
    
    func nextTrack() {
        playbackDelegate.nextTrack()
    }
    
    func playOrPause() {
        
        let priorState = playbackDelegate.state
        playbackDelegate.togglePlayPause()
        
        // If a track change occurred, we don't need to do these updates. A notif will take care of it.
        if priorState.isPlayingOrPaused {
            
            btnPlayPauseStateMachine.setState(playbackDelegate.state)
            updateSeekTimerState()
        }
    }
    
    func beginGaplessPlayback() {
        
        do {
            try playbackDelegate.beginGaplessPlayback()
            
        } catch {
            
            let errorMsg = (error as? DisplayableError)?.message ?? "Unknown Error"
            
            NSAlert.showError(withTitle: "Gapless Playback not possible",
                              andText: "Error: \(errorMsg)")
        }
    }
    
    func performTrackPlayback(_ command: TrackPlaybackCommandNotification) {
        
        switch command.type {
            
        case .index:
            
            if let index = command.index {
                playbackDelegate.play(trackAtIndex: index, .defaultParams())
            }
            
        case .track:
            
            if let track = command.track {
                playbackDelegate.play(track: track, .defaultParams())
            }
        }
    }
    
    func stop() {
        playbackDelegate.stop()
    }
    
    // Replays the currently playing track, from the beginning, if there is one
    func replayTrack() {
        
        let wasPaused: Bool = playbackDelegate.state == .paused
        
        playbackDelegate.replay()
        updateSeekPosition()
        
        if wasPaused {
            
            btnPlayPauseStateMachine.setState(playbackDelegate.state)
            updateSeekTimerState()
        }
    }
    
    func seekBackward(inputMode: UserInputMode) {
        
        playbackDelegate.seekBackward(inputMode)
        updateSeekPosition()
    }
    
    func seekForward(inputMode: UserInputMode) {
        
        playbackDelegate.seekForward(inputMode)
        updateSeekPosition()
    }
    
    func seekBackward_secondary() {
        
        playbackDelegate.seekBackwardSecondary()
        updateSeekPosition()
    }
    
    func seekForward_secondary() {
        
        playbackDelegate.seekForwardSecondary()
        updateSeekPosition()
    }
    
    func jumpToTime(_ time: Double) {
        
        playbackDelegate.seekToTime(time)
        updateSeekPosition()
    }
    
    func showTrackInfo(for track: Track?) {
        
        // If there is a track currently playing, load detailed track info and toggle the popover view
        guard let theTrack = track ?? playbackInfoDelegate.playingTrack else {return}
                
        trackReader.loadAuxiliaryMetadata(for: theTrack)
        TrackInfoViewContext.displayedTrack = theTrack
        
        showTrackInfoView()
    }
    
    func addLyricsFile() {
        
        let fileOpenDialog: NSOpenPanel = DialogsAndAlerts.openLyricsFileDialog
        
        if fileOpenDialog.runModal() == .OK, let lyricsFile = fileOpenDialog.url {
            
            guard let track = playbackInfoDelegate.playingTrack, trackReader.loadTimedLyricsFromFile(at: lyricsFile, for: track) else {
                
                NSAlert.showError(withTitle: "Lyrics not loaded", andText: "Failed to load synced lyrics from file: '\(lyricsFile.lastPathComponent)'")
                return
            }
            
            Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .lyrics))
        }
    }
    
    func searchForLyricsOnline() {
        
        if !appModeManager.isShowingLyrics {
            
            Messenger.publish(.View.toggleLyrics)
            Messenger.publish(.Lyrics.searchForLyricsOnline)
        }
    }
    
    func removeDownloadedLyrics() {
        
        if let playingTrack = playbackInfoDelegate.playingTrack {
            trackReader.removeDownloadedLyrics(for: playingTrack)
        }
    }
    
    // Override this in subclasses!
    func showTrackInfoView() {}
    
    func toggleLoop() {
        
        guard playbackDelegate.state.isPlayingOrPaused else {return}
        
        playbackDelegate.toggleLoop()
        messenger.publish(.Player.playbackLoopChanged)
    }
    
    func updateSeekPosition() {
        
        let seekPosn = playbackDelegate.seekPosition
        seekSlider.doubleValue = seekPosn.percentageElapsed
        
        lblPlaybackPosition.stringValue = ValueFormatter.formatPlaybackPosition(elapsedSeconds: seekPosn.timeElapsed, duration: seekPosn.trackDuration,
                                                                  percentageElapsed: seekPosn.percentageElapsed, playbackPositionDisplayType: playerUIState.playbackPositionDisplayType)
        
        for task in seekTimerTaskQueue.tasks {
            task()
        }
    }
    
    var shouldEnableSeekTimer: Bool {
        playbackDelegate.state == .playing
    }
    
    func updateSeekTimerState() {
        setSeekTimerState(to: shouldEnableSeekTimer)
    }
    
    func setSeekTimerState(to timerOn: Bool) {
        timerOn ? seekTimer.startOrResume() : seekTimer.pause()
    }
    
    func playbackLoopChanged() {
        
        btnLoopStateMachine.setState(playbackDelegate.playbackLoopState)

        // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
        
        if let playingTrack = playbackDelegate.playingTrack, let loop = playbackDelegate.playbackLoop {
            
            // If loop start has not yet been marked, mark it (e.g. when marking chapter loops)
            
            let trackDuration = playingTrack.duration
            let startPerc = loop.startTime * 100 / trackDuration
            seekSliderCell.markLoopStart(startPerc: startPerc)
            
            // Use the seek slider clone to mark the exact position of the center of the slider knob, at both the start and end points of the playback loop (for rendering)
            if let loopEndTime = loop.endTime {
                
                let endPerc = (loopEndTime / trackDuration) * 100
                seekSliderCell.markLoopEnd(endPerc: endPerc)
            }
            
        } else {
            seekSliderCell.removeLoop()
        }

        seekSlider.redraw()
        updateSeekPosition()
    }
    
    func playChapter(index: Int) {
        
        playbackDelegate.playChapter(index)
        postChapterChange()
    }
    
    func previousChapter() {
        
        playbackDelegate.previousChapter()
        postChapterChange()
    }
    
    func nextChapter() {
        
        playbackDelegate.nextChapter()
        postChapterChange()
    }
    
    func replayChapter() {
        
        playbackDelegate.replayChapter()
        postChapterChange()
    }
    
    private func postChapterChange() {
        
        playbackLoopChanged()
        btnPlayPauseStateMachine.setState(playbackDelegate.state)
        updateSeekTimerState()
    }
    
    func toggleChapterLoop() {
        
        playbackDelegate.toggleChapterLoop()
        playbackLoopChanged()
        
        messenger.publish(.Player.playbackLoopChanged)
    }
    
    // Decreases the volume by a certain preset decrement
    func decreaseVolume(inputMode: UserInputMode) {
        
        let newVolume = audioGraph.decreaseVolume(inputMode: inputMode)
        volumeChanged(volume: newVolume, muted: audioGraph.muted)
    }
    
    // Increases the volume by a certain preset increment
    func increaseVolume(inputMode: UserInputMode) {
        
        let newVolume = audioGraph.increaseVolume(inputMode: inputMode)
        volumeChanged(volume: newVolume, muted: audioGraph.muted)
    }
    
    func muteOrUnmute() {
        
        audioGraph.muted.toggle()
        updateVolumeMuteButtonImage(volume: audioGraph.scaledVolume, muted: audioGraph.muted)
    }
    
    // updateSlider should be true if the action was not triggered by the slider in the first place.
    func volumeChanged(volume: Float, muted: Bool, updateSlider: Bool = true, showFeedback: Bool = true) {
        
        if updateSlider {
            volumeSlider.floatValue = volume
        }
        
        lblVolume.stringValue = audioGraph.formattedVolume
        volumeSlider.toolTip = "Volume: \(audioGraph.formattedVolume)" + (muted ? " (muted)" : "")
        
        updateVolumeMuteButtonImage(volume: volume, muted: muted)
        
        // Shows and automatically hides the volume label after a preset time interval
        if showFeedback {
            autoHidingVolumeLabel.showView()
        }
    }
    
    func updateVolumeMuteButtonImage(volume: Float, muted: Bool) {

        if muted {
            btnVolume.image = .imgMute
            
        } else {

            // Zero / Low / Medium / High (different images)
            
            switch volume {
                
            case highVolumeRange:
                btnVolume.image = .imgVolumeHigh
                
            case mediumVolumeRange:
                btnVolume.image = .imgVolumeMedium
                
            case lowVolumeRange:
                btnVolume.image = .imgVolumeLow
                
            default:
                btnVolume.image = .imgVolumeZero
            }
        }
        
        volumeSlider.toolTip = "Volume: \(audioGraph.formattedVolume)" + (muted ? " (muted)" : "")
    }
    
    func toggleRepeatMode() {
        updateRepeatAndShuffleControls(modes: playQueueDelegate.toggleRepeatMode())
    }
    
    func toggleShuffleMode() {
        updateRepeatAndShuffleControls(modes: playQueueDelegate.toggleShuffleMode())
    }
    
    func updateRepeatAndShuffleControls(modes: RepeatAndShuffleModes) {
        
        btnRepeatStateMachine.setState(modes.repeatMode)
        btnShuffleStateMachine.setState(modes.shuffleMode)
    }
    
    func setRepeatMode(to repeatMode: RepeatMode) {
        updateRepeatAndShuffleControls(modes: playQueueDelegate.setRepeatMode(repeatMode))
    }
    
    func setShuffleMode(to shuffleMode: ShuffleMode) {
        updateRepeatAndShuffleControls(modes: playQueueDelegate.setShuffleMode(shuffleMode))
    }
    
    func setRepeatAndShuffleModes(_ notif: RepeatAndShuffleModesCommandNotification) {
        
        playQueueDelegate.setRepeatAndShuffleModes(repeatMode: notif.repeatMode, shuffleMode: notif.shuffleMode)
        updateRepeatAndShuffleControls(modes: playQueueDelegate.repeatAndShuffleModes)
    }
    
    @objc dynamic func showOrHideArtist() {
        multilineTrackTextView.update()
    }
    
    @objc dynamic func showOrHideAlbum() {
        multilineTrackTextView.update()
    }
    
    @objc dynamic func showOrHideCurrentChapter() {
        multilineTrackTextView.update()
    }
    
    @objc dynamic func showOrHideAlbumArt() {}
    
    @objc dynamic func showOrHideMainControls() {}
    
    func showOrHidePlaybackPosition() {
        
        lblPlaybackPosition.showIf(playbackDelegate.playingTrack != nil && showPlaybackPosition)
        updateSeekTimerState()
    }
    
    func setPlaybackPositionDisplayType(to format: PlaybackPositionDisplayType) {
        
        let seekPosn = playbackDelegate.seekPosition
        lblPlaybackPosition.stringValue = ValueFormatter.formatPlaybackPosition(elapsedSeconds: seekPosn.timeElapsed, duration: seekPosn.trackDuration,
                                                                  percentageElapsed: seekPosn.percentageElapsed, playbackPositionDisplayType: playerUIState.playbackPositionDisplayType)
        
        updateSeekTimerState()
    }
    
    // MARK: Notification handling ---------------------------------------------------------------------
    
    func setUpNotificationHandling() {
        
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribeAsync(to: .Player.trackInfoUpdated, handler: playingTrackInfoUpdated(_:), filter: {notif in
            notif.updatedTrack == playbackDelegate.playingTrack
        })
        
        messenger.subscribe(to: .Player.playbackLoopChanged, handler: playbackLoopChanged)
        messenger.subscribe(to: .Player.chapterChanged, handler: chapterChanged(_:))
        messenger.subscribeAsync(to: .Player.trackNotPlayed, handler: trackNotPlayed(_:))
        messenger.subscribeAsync(to: .Player.trackNoLongerReadable, handler: trackNoLongerReadable(notification:))
        
        messenger.subscribe(to: .Effects.playbackRateChanged, handler: playbackRateChanged(_:))
    }
    
    func trackTransitioned(_ notification: TrackTransitionNotification) {
        trackChanged(to: notification.endTrack)
    }
    
    func chapterChanged(_ notification: ChapterChangedNotification) {
        
        if let playingTrack = notification.newChapter?.track {
            multilineTrackTextView?.trackInfo = PlayingTrackInfo(track: playingTrack, playingChapterTitle: notification.newChapter?.chapter.title)
        }
    }
    
    func playingTrackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
        
        if notification.updatedFields.contains(.art) {
            updateCoverArt(for: notification.updatedTrack)
        }
        
        if notification.updatedFields.contains(.duration) {
            updateDuration(for: notification.updatedTrack)
        }
    }
    
    func trackNotPlayed(_ notification: TrackNotPlayedNotification) {
        
        trackChanged(to: nil)
        
        NSAlert.showError(withTitle: "Track not played",
                          andText: "Error playing audio file '\(notification.errorTrack.file.lastPathComponent)':\n\(notification.error.message)")
    }
    
    func trackNoLongerReadable(notification: TrackNoLongerReadableNotification) {
        
        playbackDelegate.stop()
        
        NSAlert.showError(withTitle: "Track no longer readable",
                          andText: "Error playing audio file '\(notification.errorTrack.file.lastPathComponent)':\n\(notification.detailMessage)")
    }
    
    func playbackRateChanged(_ newPlaybackRate: Float) {
        
        let interval = (1000 / (2 * newPlaybackRate)).roundedInt
        
        if interval != seekTimer.interval {
            seekTimer.interval = interval
        }
    }
    
    override func destroy() {
        
        super.destroy()
        messenger.unsubscribeFromAll()
    }
}

extension AudioGraphProtocol {
    
    fileprivate var volumeDeltaDiscrete: Float {
        preferences.soundPreferences.volumeDelta.value
    }
    
    fileprivate var volumeDeltaContinuous: Float {
        preferences.soundPreferences.volumeDelta_continuous
    }
    
    var formattedVolume: String {
        ValueFormatter.formatVolume(scaledVolume)
    }
    
    func increaseVolume(inputMode: UserInputMode) -> Float {
        
        let volumeDelta = inputMode == .discrete ? volumeDeltaDiscrete : volumeDeltaContinuous
        increaseVolume(by: volumeDelta)
        return scaledVolume
    }
    
    func decreaseVolume(inputMode: UserInputMode) -> Float {
        
        let volumeDelta = inputMode == .discrete ? volumeDeltaDiscrete : volumeDeltaContinuous
        decreaseVolume(by: volumeDelta)
        return scaledVolume
    }
}
