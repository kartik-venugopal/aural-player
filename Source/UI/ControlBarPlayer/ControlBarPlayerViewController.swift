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

    @IBOutlet weak var imgArt: NSImageView!
    
    @IBOutlet weak var textView: ScrollingTrackInfoView! {
        
        didSet {
            textViewConstraints = LayoutConstraintsManager(for: textView)
        }
    }
    
    
    @IBOutlet weak var lblSeekPosition: CenterTextLabel! {
        
        didSet {
            lblSeekPositionConstraints = LayoutConstraintsManager(for: lblSeekPosition)
        }
    }
    
    @IBOutlet weak var playbackView: ControlBarPlaybackView!
    @IBOutlet weak var seekSliderView: ControlBarSeekSliderView!
    
    @IBOutlet weak var seekSlider: NSSlider! {
        
        didSet {
            seekSliderConstraints = LayoutConstraintsManager(for: seekSlider)
        }
    }
    
    @IBOutlet weak var btnRepeat: NSButton!
    
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
    
    private var textViewConstraints: LayoutConstraintsManager!
    private var lblSeekPositionConstraints: LayoutConstraintsManager!
    private var seekSliderConstraints: LayoutConstraintsManager!
    
    private let minWindowWidth: CGFloat = 570
    private let seekPosLabelWidth: CGFloat = 50
    private lazy var minWindowWidthForShowingSeekPos: CGFloat = minWindowWidth + seekPosLabelWidth + 5
    
    override func awakeFromNib() {
        
        textView.scrollingEnabled = true
        applyTheme()
        
        textViewConstraints.setLeading(relatedToTrailingOf: imgArt, offset: 10)
        layoutTextView()
        
        // Seek slider
        seekSliderConstraints.setLeading(relatedToLeadingOf: textView, offset: -1)
        seekSliderConstraints.setTrailing(relatedToLeadingOf: btnRepeat, offset: -21)
        
        // MARK: Notification subscriptions
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:), queue: .main)
        Messenger.subscribeAsync(self, .player_trackInfoUpdated, self.trackInfoUpdated(_:), queue: .main)
        Messenger.subscribeAsync(self, .player_trackNotPlayed, self.trackNotPlayed(_:), queue: .main)
        
        Messenger.subscribe(self, .applyTheme, self.applyTheme)
        Messenger.subscribe(self, .applyFontScheme, self.applyFontScheme(_:))
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
    }
    
    private var isShowingSeekPosition: Bool = false
    
    func layoutTextView() {
        
        let showSeekPosition: Bool = view.window!.width >= minWindowWidthForShowingSeekPos
        guard isShowingSeekPosition != showSeekPosition else {return}
        
        isShowingSeekPosition = showSeekPosition
        
        // Seek Position label
        
        seekSliderView.showSeekPosition = showSeekPosition
        
        if showSeekPosition {
            
            lblSeekPositionConstraints.removeAll()
            
            lblSeekPositionConstraints.setWidth(seekPosLabelWidth)
            lblSeekPositionConstraints.setHeight(25)
            lblSeekPositionConstraints.setBottom(relatedToTopOf: seekSlider)
            lblSeekPositionConstraints.setTrailing(relatedToLeadingOf: btnRepeat, offset: -21)
        }
        
        // Text view
        
        textViewConstraints.removeAll(withAttributes: [.trailing])
        textViewConstraints.setTrailing(relatedToLeadingOf: btnRepeat,
                                        offset: showSeekPosition ? -(21 + seekPosLabelWidth) : -21)
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
        
        layoutTextView()
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
