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

class ControlBarPlayerViewController: NSViewController, NSWindowDelegate, NotificationSubscriber, Destroyable {
    
    @IBOutlet weak var containerBox: NSBox!
    
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
        
        let textViewLeadingConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textView!, attribute: .leading, relatedBy: .equal,
                                                                            toItem: imgArt, attribute: .trailing, multiplier: 1, constant: 10)
        
        let textViewTrailingConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textView!, attribute: .trailing, relatedBy: .equal,
                                                                                toItem: playerSequencingViewController.btnRepeat, attribute: .leading, multiplier: 1, constant: -22)
        
        let textViewTopConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textView!, attribute: .top, relatedBy: .equal,
                                                                              toItem: containerBox, attribute: .top, multiplier: 1, constant: -5)
        
        let textViewHeightConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textView!, attribute: .height, relatedBy: .equal,
                                                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        containerBox.activateAndAddConstraints(textViewLeadingConstraint, textViewTrailingConstraint, textViewHeightConstraint, textViewTopConstraint)
        
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
            textView.toolTip = theTrack.displayName
            
        } else {
            
            textView.setup(string: "")
            textView.toolTip = nil
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
    
    func windowDidResize(_ notification: Notification) {
        
        if let theTrack = player.playingTrack {
            textView.setup(string: theTrack.displayName)
        }
    }
    
    @IBAction func windowedModeAction(_ sender: AnyObject) {
        AppModeManager.presentMode(.windowed)
    }

    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
}
