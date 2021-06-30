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
    @IBOutlet weak var textView: ScrollingTrackInfoView!
    @IBOutlet weak var lblSeekPosition: CenterTextLabel!
    
    @IBOutlet weak var playbackView: ControlBarPlaybackView!
    @IBOutlet weak var seekSliderView: ControlBarSeekSliderView!
    
    @IBOutlet weak var seekSlider: NSSlider!
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
    
    private var textViewSuperview: NSView!
    private var seekSliderSuperview: NSView!
    
    private let minWindowWidth: CGFloat = 570
    private let seekPosLabelWidth: CGFloat = 50
    private lazy var minWindowWidthForShowingSeekPos: CGFloat = minWindowWidth + seekPosLabelWidth + 5
    
    override func awakeFromNib() {
        
        textView.scrollingEnabled = true
        applyTheme()
        
        [textView, seekSlider, lblSeekPosition].forEach {$0?.translatesAutoresizingMaskIntoConstraints = false}
        
        textViewSuperview = textView.superview
        seekSliderSuperview = seekSlider.superview
        
        let textViewLeadingConstraint = NSLayoutConstraint(item: textView!, attribute: .leading, relatedBy: .equal,
                                                           toItem: imgArt, attribute: .trailing, multiplier: 1, constant: 10)
        
        textViewSuperview.activateAndAddConstraint(textViewLeadingConstraint)
        layoutTextView()
        
        // Seek slider
        
        let seekSliderLeadingConstraint: NSLayoutConstraint = NSLayoutConstraint(item: seekSlider!, attribute: .leading, relatedBy: .equal,
                                                                                 toItem: textView, attribute: .leading, multiplier: 1, constant: -1)
        
        let seekSliderTrailingConstraint: NSLayoutConstraint = NSLayoutConstraint(item: seekSlider!, attribute: .trailing, relatedBy: .equal,
                                                                                  toItem: btnRepeat, attribute: .leading,
                                                                                  multiplier: 1, constant: -21)
        
        seekSliderSuperview.activateAndAddConstraints(seekSliderLeadingConstraint, seekSliderTrailingConstraint)
        
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
        
        lblSeekPosition.removeAllConstraintsFromSuperview()
        
        if showSeekPosition {
            
            // TODO: Create a struct LayoutConstraintSet to simplify this kind of code. Maybe with builder pattern: LCSet(for: view).removingExistingConstraints(attributes?).withWidth().withBottomTop().activate()
            
            let lblWidthConstraint = NSLayoutConstraint.widthConstraint(forItem: lblSeekPosition!, equalTo: seekPosLabelWidth)
            
            let lblHeightConstraint = NSLayoutConstraint.heightConstraint(forItem: lblSeekPosition!, equalTo: 25)
            
            let lblBottomConstraint = NSLayoutConstraint.bottomTopConstraint(forItem: lblSeekPosition!, relatedTo: seekSlider!)
            
            let lblTrailingConstraint = NSLayoutConstraint.trailingLeadingConstraint(forItem: lblSeekPosition!,
                                                                                     relatedTo: btnRepeat!, offset: -21)
            
            lblSeekPosition.superview?.activateAndAddConstraints(lblWidthConstraint, lblTrailingConstraint,
                                                                 lblBottomConstraint, lblHeightConstraint)
        }
        
        // Text view
        
        textView.removeAllConstraintsFromSuperview(attributes: [.trailing])
            
        let textViewTrailingConstraint = NSLayoutConstraint.trailingLeadingConstraint(forItem: textView!, relatedTo: btnRepeat!,
                                                                                      offset: showSeekPosition ? -(21 + seekPosLabelWidth) : -21)
        
        textViewSuperview.activateAndAddConstraint(textViewTrailingConstraint)
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
