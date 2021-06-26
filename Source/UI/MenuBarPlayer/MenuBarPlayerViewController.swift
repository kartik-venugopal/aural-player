//
//  MenuBarPlayerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class MenuBarPlayerViewController: NSViewController, MenuBarMenuObserver, NotificationSubscriber, Destroyable {

    override var nibName: String? {"MenuBarPlayer"}
    
    @IBOutlet weak var appLogo: TintedImageView!
    @IBOutlet weak var btnQuit: TintedImageButton!
    @IBOutlet weak var btnRegularMode: TintedImageButton!
    
    @IBOutlet weak var infoBox: NSBox!
    @IBOutlet weak var trackInfoView: MenuBarPlayingTrackTextView!
    @IBOutlet weak var imgArt: NSImageView!
    @IBOutlet weak var artOverlayBox: NSBox!
    
    @IBOutlet weak var playbackView: MenuBarModePlaybackView!
    @IBOutlet weak var seekSliderView: MenuBarModeSeekSliderView!
    
    @IBOutlet weak var btnSettings: TintedImageButton!
    @IBOutlet weak var settingsBox: NSBox!
    
    @IBOutlet weak var playbackViewController: MenuBarModePlaybackViewController!
    @IBOutlet weak var playerAudioViewController: MenuBarModePlayerAudioViewController!
    @IBOutlet weak var playerSequencingViewController: MenuBarModePlayerSequencingViewController!
    
    private lazy var alertDialog: AlertWindowController = AlertWindowController.instance
    
    // TODO: Implement this for volume control / seeking, etc ???
//    private var gestureHandler: GestureHandler?
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    // Delegate that retrieves playback sequencing info (previous/next track)
    private let sequencer: SequencerDelegateProtocol = ObjectGraph.sequencerDelegate
    
    private var audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    override func awakeFromNib() {
        
        [btnQuit, btnRegularMode, btnSettings].forEach {$0?.tintFunction = {Colors.Constants.white70Percent}}
        
        appLogo.tintFunction = {Colors.Constants.white70Percent}

        // MARK: Notification subscriptions
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:), queue: .main)
        Messenger.subscribeAsync(self, .player_trackInfoUpdated, self.trackInfoUpdated(_:), queue: .main)
        Messenger.subscribe(self, .player_chapterChanged, self.chapterChanged(_:))
        Messenger.subscribeAsync(self, .player_trackNotPlayed, self.trackNotPlayed(_:), queue: .main)
    }
    
    func destroy() {
        
        [playbackViewController, playerAudioViewController, playerSequencingViewController].forEach {
            ($0 as? Destroyable)?.destroy()
        }
        
        Messenger.unsubscribeAll(for: self)
    }
    
    override func viewDidLoad() {
        
        updateTrackInfo()

        // When the view first loads, the menu bar's menu is closed (not visible), so
        // don't bother updating the seek position unnecessarily.
        if view.superview == nil {
            seekSliderView.stopUpdatingSeekPosition()
        }
    }
    
    // MARK: Track playback actions/functions ------------------------------------------------------------
    
    private func updateTrackInfo() {
        
        if let theTrack = player.playingTrack {
            
            trackInfoView.trackInfo = PlayingTrackInfo(theTrack, player.playingChapter?.chapter.title)
            
        } else {
            
            trackInfoView.trackInfo = nil
        }
        
        imgArt.image = player.playingTrack?.art?.image
        [imgArt, artOverlayBox].forEach {$0?.showIf(imgArt.image != nil && MenuBarPlayerViewState.showAlbumArt)}
        
        infoBox.bringToFront()
        
        if settingsBox.isShown {
            settingsBox.bringToFront()
        }
    }
    
    @IBAction func showOrHideSettingsAction(_ sender: NSButton) {
        
        if settingsBox.isHidden {

            settingsBox.show()
            settingsBox.bringToFront()

        } else {
            
            settingsBox.hide()
            infoBox.bringToFront()
        }
    }
    
    func menuBarMenuOpened() {
        
        if settingsBox.isShown {
            
            settingsBox.hide()
            infoBox.bringToFront()
        }
        
        // If the player is playing, we need to resume updating the seek
        // position as the view is now visible.
        if player.state == .playing {
            seekSliderView.resumeUpdatingSeekPosition()
        }
    }
    
    func menuBarMenuClosed() {
        
        if settingsBox.isShown {
            
            settingsBox.hide()
            infoBox.bringToFront()
        }
        
        // Updating seek position is not necessary when the view has been closed.
        seekSliderView.stopUpdatingSeekPosition()
    }
    
    // MARK: Message handling

    func trackTransitioned(_ notification: TrackTransitionNotification) {
        updateTrackInfo()
    }
    
    // When track info for the playing track changes, display fields need to be updated
    func trackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
        
        if notification.updatedTrack == player.playingTrack {
            updateTrackInfo()
        }
    }
    
    func chapterChanged(_ notification: ChapterChangedNotification) {
        
        if let playingTrack = player.playingTrack {
            trackInfoView.trackInfo = PlayingTrackInfo(playingTrack, notification.newChapter?.chapter.title)
        }
    }
    
    func trackNotPlayed(_ notification: TrackNotPlayedNotification) {
        
        updateTrackInfo()
        
        let errorDialog = DialogsAndAlerts.genericErrorAlert("Track not played",
                                                             notification.errorTrack.file.lastPathComponent,
                                                             notification.error.message)
            
        errorDialog.runModal()
    }
    
    @IBAction func windowedModeAction(_ sender: AnyObject) {
        AppModeManager.presentMode(.windowed)
    }

    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
}
