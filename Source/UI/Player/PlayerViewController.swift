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
    
    ButtonStateMachine(initialState: playbackOrch.state,
                       mappings: [
                        ButtonStateMachine.StateMapping(state: .stopped, image: .imgPlay, colorProperty: \.buttonColor, toolTip: "Play"),
                        ButtonStateMachine.StateMapping(state: .playing, image: .imgPause, colorProperty: \.buttonColor, toolTip: "Pause"),
                        ButtonStateMachine.StateMapping(state: .paused, image: .imgPlay, colorProperty: \.buttonColor, toolTip: "Play")
                       ],
                       button: btnPlayPause)
    
    lazy var btnRepeatStateMachine: ButtonStateMachine<RepeatMode> = ButtonStateMachine(initialState: playQueue.repeatAndShuffleModes.repeatMode,
                                                                                                mappings: [
                                                                                                    ButtonStateMachine.StateMapping(state: .off, image: .imgRepeat, colorProperty: \.inactiveControlColor, toolTip: "Repeat"),
                                                                                                    ButtonStateMachine.StateMapping(state: .all, image: .imgRepeat, colorProperty: \.activeControlColor, toolTip: "Repeat"),
                                                                                                    ButtonStateMachine.StateMapping(state: .one, image: .imgRepeatOne, colorProperty: \.activeControlColor, toolTip: "Repeat")
                                                                                                ],
                                                                                                button: btnRepeat)
    
    lazy var btnShuffleStateMachine: ButtonStateMachine<ShuffleMode> = ButtonStateMachine(initialState: playQueue.repeatAndShuffleModes.shuffleMode,
                                                                                                  mappings: [
                                                                                                    ButtonStateMachine.StateMapping(state: .off, image: .imgShuffle, colorProperty: \.inactiveControlColor, toolTip: "Shuffle"),
                                                                                                    ButtonStateMachine.StateMapping(state: .on, image: .imgShuffle, colorProperty: \.activeControlColor, toolTip: "Shuffle")
                                                                                                  ],
                                                                                                  button: btnShuffle)
    
    lazy var btnLoopStateMachine: ButtonStateMachine<PlaybackLoopState> = ButtonStateMachine(initialState: playbackOrch.playbackLoopState,
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
    lazy var seekTimer: RepeatingTaskExecutor = RepeatingTaskExecutor(intervalMillis: (1000 / (2 * soundOrch.timeStretchUnit.effectiveRate)).roundedInt,
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
        
        trackChanged(to: playbackOrch.playingTrack)
        
        setUpNotificationHandling()
        setUpCommandHandling()
        
        playbackOrch.registerUI(ui: self)
        soundOrch.registerUI(ui: self)
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
        
        guard let track = playbackOrch.playingTrack else {return 0}
        
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
                
                if let prevTrack = playQueue.peekPrevious() {
                    return String(format: "Previous track: '%@'", prevTrack.displayName)
                }
                
                return nil
            }
        }
        
        if var peekingNextTrackButton = btnNextTrack as? TrackPeekingButtonProtocol {
            
            peekingNextTrackButton.toolTipFunction = {
                
                if let nextTrack = playQueue.peekNext() {
                    return String(format: "Next track: '%@'", nextTrack.displayName)
                }

                return nil
            }
        }
        
        showOrHideMainControls()
    }
    
    func trackChanged(to newTrack: Track?) {
        
        updateTrackInfo(for: newTrack, playingChapterTitle: playbackOrch.playingChapter?.chapter.title)
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
            multilineTrackTextView.trackInfo = PlayingTrackInfo(track: theTrack, playbackPosition: playbackOrch.playbackPosition!, playingChapterTitle: playingChapterTitle)
            
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
        
        btnPlayPauseStateMachine.setState(playbackOrch.state)
        
        btnRepeatStateMachine.setState(playQueue.repeatMode)
        btnShuffleStateMachine.setState(playQueue.shuffleMode)
        
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
        volumeChanged(volume: soundOrch.volume, displayedVolume: soundOrch.displayedVolume, muted: soundOrch.muted)
    }
    
    // Creates a recurring task that polls the player to detect a change in the currently playing track chapter.
    // This only occurs when the currently playing track actually has chapters.
    func beginPollingForChapterChange() {
        
        seekTimerTaskQueue.enqueueTask(Self.chapterChangePollingTaskId, {
            
            let playingChapter: IndexedChapter? = playbackOrch.playingChapter
            
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
        
        messenger.subscribe(to: .Player.beginGaplessPlayback, handler: beginGaplessPlayback)
        
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
    
    func beginGaplessPlayback() {
        
//        do {
//            try playbackOrch.beginGaplessPlayback()
//            
//        } catch {
//            
//            let errorMsg = (error as? DisplayableError)?.message ?? "Unknown Error"
//            
//            NSAlert.showError(withTitle: "Gapless Playback not possible",
//                              andText: "Error: \(errorMsg)")
//        }
    }
    
    func showTrackInfo(for track: Track?) {
        
        // If there is a track currently playing, load detailed track info and toggle the popover view
        guard let theTrack = track ?? playbackOrch.playingTrack else {return}
                
        trackReader.loadAuxiliaryMetadata(for: theTrack)
        TrackInfoViewContext.displayedTrack = theTrack
        
        showTrackInfoView()
    }
    
    func addLyricsFile() {
        
        let fileOpenDialog: NSOpenPanel = DialogsAndAlerts.openLyricsFileDialog
        
        if fileOpenDialog.runModal() == .OK, let lyricsFile = fileOpenDialog.url {
            
            guard let track = playbackOrch.playingTrack, trackReader.loadTimedLyricsFromFile(at: lyricsFile, for: track) else {
                
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
        
        if let playingTrack = playbackOrch.playingTrack {
            trackReader.removeDownloadedLyrics(for: playingTrack)
        }
    }
    
    // Override this in subclasses!
    func showTrackInfoView() {}
    
    func updateSeekPosition() {
        updateSeekPosition(to: playbackOrch.playbackPosition)
    }
    
    func updateSeekPosition(to newPosition: PlaybackPosition?) {
        
        guard let newPosition else {return}
        
        seekSlider.doubleValue = newPosition.percentageElapsed
        
        lblPlaybackPosition.stringValue = ValueFormatter.formatPlaybackPosition(elapsedSeconds: newPosition.timeElapsed, duration: newPosition.trackDuration,
                                                                  percentageElapsed: newPosition.percentageElapsed, playbackPositionDisplayType: playerUIState.playbackPositionDisplayType)
        
        for task in seekTimerTaskQueue.tasks {
            task()
        }
    }
    
    var shouldEnableSeekTimer: Bool {
        playbackOrch.isPlaying
    }
    
    func updateSeekTimerState() {
        setSeekTimerState(to: shouldEnableSeekTimer)
    }
    
    func setSeekTimerState(to timerOn: Bool) {
        timerOn ? seekTimer.startOrResume() : seekTimer.pause()
    }
    
    func playbackLoopChanged() {
        
        btnLoopStateMachine.setState(playbackOrch.playbackLoopState)

        // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
        
        if let playingTrack = playbackOrch.playingTrack, let loop = playbackOrch.playbackLoop {
            
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
        playbackOrch.playChapter(index: index)
    }
    
    func previousChapter() {
        playbackOrch.previousChapter()
    }
    
    func nextChapter() {
        playbackOrch.nextChapter()
    }
    
    func replayChapter() {
        playbackOrch.replayChapter()
    }
    
//    private func postChapterChange() {
//        
//        playbackLoopChanged()
//        btnPlayPauseStateMachine.setState(playbackOrch.state)
//        updateSeekTimerState()
//    }
    
    func toggleChapterLoop() {
        
        playbackOrch.toggleChapterLoop()
        playbackLoopChanged()
        
        messenger.publish(.Player.playbackLoopChanged)
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
        
        lblPlaybackPosition.showIf(playbackOrch.playingTrack != nil && showPlaybackPosition)
        updateSeekTimerState()
    }
    
    func setPlaybackPositionDisplayType(to format: PlaybackPositionDisplayType) {
        
        guard let seekPosn = playbackOrch.playbackPosition else {return}
        lblPlaybackPosition.stringValue = ValueFormatter.formatPlaybackPosition(elapsedSeconds: seekPosn.timeElapsed, duration: seekPosn.trackDuration,
                                                                  percentageElapsed: seekPosn.percentageElapsed, playbackPositionDisplayType: playerUIState.playbackPositionDisplayType)
        
        updateSeekTimerState()
    }
    
    // MARK: Notification handling ---------------------------------------------------------------------
    
    func setUpNotificationHandling() {
        
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribeAsync(to: .Player.trackInfoUpdated, handler: playingTrackInfoUpdated(_:), filter: {notif in
            notif.updatedTrack == playbackOrch.playingTrack
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
            multilineTrackTextView?.trackInfo = PlayingTrackInfo(track: playingTrack, playbackPosition: playbackOrch.playbackPosition!, playingChapterTitle: notification.newChapter?.chapter.title)
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
        
        playbackOrch.stop()
        
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
        
        soundOrch.deregisterUI(ui: self)
        messenger.unsubscribeFromAll()
    }
}

extension AudioGraphProtocol {
    
    fileprivate var volumeDeltaDiscrete: Float {
        preferences.soundPreferences.volumeDelta
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
