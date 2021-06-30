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
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var btnRepeat: NSButton!
    
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
    
    private var textViewConstraints: LayoutConstraintsManager!
    private var lblSeekPositionConstraints: LayoutConstraintsManager!
    private var seekSliderConstraints: LayoutConstraintsManager!
    
    private let minWindowWidthForShowingSeekPos: CGFloat = 610
    
    override func awakeFromNib() {
        
        lblSeekPositionConstraints = LayoutConstraintsManager(for: lblSeekPosition)
        seekSliderConstraints = LayoutConstraintsManager(for: seekSlider)
        textViewConstraints = LayoutConstraintsManager(for: textView)
        
        applyTheme()
        
        // Seek slider
        seekSliderConstraints.setLeading(relatedToLeadingOf: textView, offset: -1)
        seekSliderConstraints.setTrailing(relatedToLeadingOf: btnRepeat, offset: -21)
        
        textViewConstraints.setLeading(relatedToTrailingOf: imgArt, offset: 10)
        layoutTextView()
        textView.scrollingEnabled = true
        
        // MARK: Notification subscriptions
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:), queue: .main)
        Messenger.subscribeAsync(self, .player_trackInfoUpdated, self.trackInfoUpdated(_:), queue: .main)
        Messenger.subscribeAsync(self, .player_trackNotPlayed, self.trackNotPlayed(_:), queue: .main)
        
        Messenger.subscribe(self, .applyTheme, self.applyTheme)
        Messenger.subscribe(self, .applyFontScheme, self.applyFontScheme(_:))
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
    }
    
    private var isShowingSeekPosition: Bool = false
    
    func layoutTextView(forceChange: Bool = true) {
        
        let showSeekPosition: Bool = view.window!.width >= minWindowWidthForShowingSeekPos
        guard forceChange || (isShowingSeekPosition != showSeekPosition) else {return}
        
        // Seek Position label
        isShowingSeekPosition = showSeekPosition
        seekSliderView.showSeekPosition = showSeekPosition
        
        var labelWidth: CGFloat = 0
        
        if showSeekPosition {
            
            lblSeekPositionConstraints.removeAll()
            labelWidth = widthForSeekPosLabel() + 5 // Compute the required width and add some padding.
            
            lblSeekPositionConstraints.setWidth(labelWidth)
            lblSeekPositionConstraints.setHeight(textView.height)
            lblSeekPositionConstraints.setBottom(relatedToTopOf: seekSlider)
            lblSeekPositionConstraints.setTrailing(relatedToLeadingOf: btnRepeat, offset: -21)
        }
        
        // Text view
        
        textViewConstraints.removeAll(withAttributes: [.trailing])
        textViewConstraints.setTrailing(relatedToLeadingOf: btnRepeat,
                                        offset: showSeekPosition ? -(21 + labelWidth) : -21)
    }
    
    ///
    /// Computes the maximum required width for the seek position label, given
    /// 1. the duration of the track currently playing, and
    /// 2. the current font scheme.
    ///
    func widthForSeekPosLabel() -> CGFloat {
        
        guard let track = player.playingTrack else {return 0}
        
        let widthOfWidestNumber = String.widthOfWidestNumber(forFont: fontSchemesManager.systemScheme.player.trackTimesFont)
        let duration = track.duration
        
        let trackTimes = ValueFormatter.formatTrackTimes(0, duration, 0)
        let widthOfTimeRemainingString = CGFloat(trackTimes.remaining.count)
        let maxPossibleWidth = widthOfTimeRemainingString * widthOfWidestNumber
        
        return maxPossibleWidth
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
        
        layoutTextView()
        updateTrackInfo()
    }
    
    // When track info for the playing track changes, display fields need to be updated
    func trackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
        
        if notification.updatedTrack == player.playingTrack {
            
            if notification.updatedFields.contains(.duration) {
                layoutTextView()
            }
            
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
        
        layoutTextView(forceChange: false)
    }
    
    // MARK: Appearance ----------------------------------------
    
    func applyTheme() {
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        
        textView.font = fontScheme.player.infoBoxArtistAlbumFont
        layoutTextView()
    }
    
    func applyColorScheme(_ colorScheme: ColorScheme) {
        textView.textColor = colorScheme.player.trackInfoPrimaryTextColor
    }
}
