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
    
    @IBOutlet weak var containerBox: NSBox!
    
    @IBOutlet weak var textView: ScrollingTrackInfoView!
    @IBOutlet weak var imgArt: NSImageView!
    
    @IBOutlet weak var playbackView: ControlBarPlaybackView!
    @IBOutlet weak var seekSliderView: ControlBarSeekSliderView!
    
    @IBOutlet weak var playbackViewController: ControlBarPlaybackViewController!
    @IBOutlet weak var audioViewController: ControlBarPlayerAudioViewController!
    @IBOutlet weak var sequencingViewController: ControlBarPlayerSequencingViewController!
    
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
        
        textView.scrollingEnabled = true
        applyTheme()
        
        let textViewLeadingConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textView!, attribute: .leading, relatedBy: .equal,
                                                                            toItem: imgArt, attribute: .trailing, multiplier: 1, constant: 10)
        
        let textViewTrailingConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textView!, attribute: .trailing, relatedBy: .equal,
                                                                                toItem: sequencingViewController.btnRepeat, attribute: .leading, multiplier: 1, constant: -21)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.superview?.activateAndAddConstraints(textViewLeadingConstraint, textViewTrailingConstraint)
        
        let seekSlider = seekSliderView.seekSlider!
        
        let seekSliderLeadingConstraint: NSLayoutConstraint = NSLayoutConstraint(item: seekSlider, attribute: .leading, relatedBy: .equal,
                                                                            toItem: textView, attribute: .leading, multiplier: 1, constant: -1)
        
        let seekSliderTrailingConstraint: NSLayoutConstraint = NSLayoutConstraint(item: seekSlider, attribute: .trailing, relatedBy: .equal,
                                                                                toItem: textView, attribute: .trailing, multiplier: 1, constant: 1)
        
        seekSlider.translatesAutoresizingMaskIntoConstraints = false
        seekSlider.superview?.activateAndAddConstraints(seekSliderLeadingConstraint, seekSliderTrailingConstraint)
        
        // MARK: Notification subscriptions
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:), queue: .main)
        Messenger.subscribeAsync(self, .player_trackInfoUpdated, self.trackInfoUpdated(_:), queue: .main)
        Messenger.subscribeAsync(self, .player_trackNotPlayed, self.trackNotPlayed(_:), queue: .main)
        
        Messenger.subscribe(self, .applyTheme, self.applyTheme)
        Messenger.subscribe(self, .applyFontScheme, self.applyFontScheme(_:))
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
    }
    
    func destroy() {
        
        [playbackViewController, audioViewController, sequencingViewController].forEach {
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
            textView.update(artist: theTrack.artist, title: theTrack.title ?? theTrack.defaultDisplayName)
            
        } else {
            textView.clear()
        }
        
        imgArt.image = player.playingTrack?.art?.image ?? Images.imgPlayingArt
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
    
    func windowResized() {
    
        // If a track is playing, 
        if player.playingTrack != nil {
            textView.resized()
        }
    }
    
    // MARK: Appearance ----------------------------------------
    
    func applyTheme() {
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        textView.font = fontScheme.player.infoBoxArtistAlbumFont
    }
    
    func applyColorScheme(_ colorScheme: ColorScheme) {
        textView.textColor = colorScheme.player.trackInfoPrimaryTextColor
    }
}
