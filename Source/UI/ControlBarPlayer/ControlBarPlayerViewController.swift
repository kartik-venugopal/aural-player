//
//  ControlBarPlayerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ControlBarPlayerViewController: NSViewController, NotificationSubscriber, Destroyable {
    
    @IBOutlet weak var btnQuit: TintedImageButton!
    @IBOutlet weak var btnRegularMode: TintedImageButton!
    
    @IBOutlet weak var textView: ScrollingTextView!
    @IBOutlet weak var imgArt: NSImageView!
    
    @IBOutlet weak var playbackView: ControlBarModePlaybackView!
    @IBOutlet weak var seekSliderView: ControlBarModeSeekSliderView!
    
    @IBOutlet weak var playbackViewController: ControlBarModePlaybackViewController!
    @IBOutlet weak var playerAudioViewController: ControlBarModePlayerAudioViewController!
    @IBOutlet weak var playerSequencingViewController: ControlBarModePlayerSequencingViewController!
    
    private lazy var alertDialog: AlertWindowController = AlertWindowController.instance
    
    // TODO: Implement this for volume control / seeking, etc ???
//    private var gestureHandler: GestureHandler?
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    // Delegate that retrieves playback sequencing info (previous/next track)
    private let sequencer: SequencerDelegateProtocol = ObjectGraph.sequencerDelegate
    
    private var audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    private let fontSchemesManager: FontSchemesManager = ObjectGraph.fontSchemesManager
    private let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    override func awakeFromNib() {
        
        [btnQuit, btnRegularMode].forEach {
            $0?.tintFunction = {self.colorSchemesManager.systemScheme.general.viewControlButtonColor}
        }
        
        textView.font = fontSchemesManager.systemScheme.player.infoBoxArtistAlbumFont
        textView.textColor = colorSchemesManager.systemScheme.player.trackInfoPrimaryTextColor
        
        // MARK: Notification subscriptions
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:), queue: .main)
        Messenger.subscribeAsync(self, .player_trackInfoUpdated, self.trackInfoUpdated(_:), queue: .main)
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
    }
    
    // MARK: Track playback actions/functions ------------------------------------------------------------
    
    private func updateTrackInfo() {
        
        if let theTrack = player.playingTrack {
            textView.setup(string: theTrack.displayName)
            
        } else {
            textView.setup(string: "")
        }
        
        imgArt.image = player.playingTrack?.art?.image
        imgArt.showIf(imgArt.image != nil)
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
