/*
 View controller for the popover that displays a brief information message when a track is added to or removed from the Favorites list
 */
import Cocoa

// TODO: Can this be a general info popup ? "Tracks are being added ... (progress)" ?
class StatusBarViewController: NSViewController, NSMenuDelegate, NotificationSubscriber {

    var statusItem: NSStatusItem!

    override var nibName: String? {return "StatusBar"}

    private var globalMouseClickMonitor: GlobalMouseClickMonitor!

    private var gestureHandler: GestureHandler?
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    // MARK: Track playback actions/functions ------------------------------------------------------------
    
    // Plays, pauses, or resumes playback
    @IBAction func playPauseAction(_ sender: AnyObject) {
        playOrPause()
    }
    
    func playOrPause() {
        
        player.togglePlayPause()
//        playbackView.playbackStateChanged(player.state)
    }
    
    func performTrackPlayback(_ command: TrackPlaybackCommandNotification) {
        
        switch command.type {
            
        case .index:
            
            if let index = command.index {
                playTrackWithIndex(index)
            }
            
        case .track:
            
            if let track = command.track {
                playTrack(track)
            }
            
        case .group:
            
            if let group = command.group {
                playGroup(group)
            }
        }
    }
    
    private func playTrackWithIndex(_ trackIndex: Int) {
        player.play(trackIndex, PlaybackParams.defaultParams())
    }
    
    private func playTrack(_ track: Track) {
        player.play(track, PlaybackParams.defaultParams())
    }
    
    private func playGroup(_ group: Group) {
        player.play(group, PlaybackParams.defaultParams())
    }
    
    // Plays the previous track in the current playback sequence
    @IBAction func previousTrackAction(_ sender: AnyObject) {
        previousTrack()
    }
    
    func previousTrack() {
        player.previousTrack()
    }
    
    // Plays the next track in the current playback sequence
    @IBAction func nextTrackAction(_ sender: AnyObject) {
        nextTrack()
    }

    func nextTrack() {
        player.nextTrack()
    }
    
    func stop() {
        player.stop()
    }
    
//    // Replays the currently playing track, from the beginning, if there is one
//    func replayTrack() {
//
//        let wasPaused: Bool = player.state == .paused
//
//        player.replay()
//        playbackView.updateSeekPosition()
//
//        if wasPaused {
//            playbackView.playbackStateChanged(player.state)
//        }
//    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
//    private func trackChanged(_ newTrack: Track?) {
//
//        playbackView.trackChanged(player.state, player.playbackLoop, newTrack)
//
////        if let track = newTrack, track.hasChapters {
////            beginPollingForChapterChange()
////        } else {
////            stopPollingForChapterChange()
////        }
//    }
    
//    func trackNotPlayed(_ notification: TrackNotPlayedNotification) {
//
//        self.trackChanged(nil)
//
//        let error = notification.error
//        alertDialog.showAlert(.error, "Track not played", error.track?.displayName ?? "<Unknown>", error.message)
//    }
//
    func dismiss() {

//        close()
        NSStatusBar.system.removeStatusItem(statusItem)
    }

    @IBAction func regularModeAction(_ sender: AnyObject) {

        globalMouseClickMonitor.stop()

//        SyncMessenger.publishActionMessage(AppModeActionMessage(.regularAppMode))
    }

    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }

    func popoverDidShow(_ notification: Notification) {

        NSApp.activate(ignoringOtherApps: true)
        globalMouseClickMonitor.start()
    }

    func popoverDidClose(_ notification: Notification) {
        globalMouseClickMonitor.stop()
    }

    var subscriberId: String {
        return self.className
    }
}

fileprivate class GlobalMouseClickMonitor {

    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void

    public init(_ mask: NSEvent.EventTypeMask, _ handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }

    deinit {
        stop()
    }

    public func start() {

        if (monitor == nil) {
            monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
        }
    }

    public func stop() {

        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}

//
//        globalMouseClickMonitor = GlobalMouseClickMonitor([.leftMouseDown, .rightMouseDown], {(event: NSEvent!) -> Void in
//
//            // If window is non-nil, it means it's the popover window (first time after launching)
//            if event.window == nil {
//                self.close()
//            }
//        })
//
////        SyncMessenger.subscribe(messageTypes: [.appResignedActiveNotification], subscriber: self)
//
//        NSApp.unhide(self)
//    }
