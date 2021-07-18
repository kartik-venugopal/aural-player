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

class ControlBarPlayerViewController: NSViewController, NSMenuDelegate, Destroyable {
    
    @IBOutlet weak var containerBox: NSBox!

    @IBOutlet weak var imgArt: NSImageView!
    
    @IBOutlet weak var textView: ScrollingTrackInfoView!
    @IBOutlet weak var lblSeekPosition: CenterTextLabel!
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var btnRepeat: NSButton!
    
    @IBOutlet weak var playbackView: ControlBarPlaybackView!
    @IBOutlet weak var seekSliderView: ControlBarSeekSliderView!
    
    @IBOutlet weak var viewSettingsMenuButton: NSPopUpButton!
    
    @IBOutlet weak var scrollingEnabledMenuItem: NSMenuItem!
    @IBOutlet weak var showSeekPositionMenuItem: NSMenuItem!
    @IBOutlet weak var seekPositionDisplayTypeMenuItem: NSMenuItem!
    
    @IBOutlet weak var timeElapsedMenuItem: SeekPositionDisplayTypeMenuItem!
    @IBOutlet weak var timeRemainingMenuItem: SeekPositionDisplayTypeMenuItem!
    @IBOutlet weak var trackDurationMenuItem: SeekPositionDisplayTypeMenuItem!
    
    private var seekPositionDisplayTypeItems: [NSMenuItem] = []
    
    @IBOutlet weak var playbackViewController: ControlBarPlaybackViewController!
    @IBOutlet weak var audioViewController: ControlBarPlayerAudioViewController!
    @IBOutlet weak var sequencingViewController: ControlBarPlayerSequencingViewController!
    
    private lazy var alertDialog: AlertWindowController = AlertWindowController.instance
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = objectGraph.playbackDelegate
    
    // Delegate that provides access to the Favorites track list.
    private lazy var favorites: FavoritesDelegateProtocol = objectGraph.favoritesDelegate
    
    // Delegate that retrieves playback sequencing info (previous/next track)
    private let sequencer: SequencerDelegateProtocol = objectGraph.sequencerDelegate
    
    private var audioGraph: AudioGraphDelegateProtocol = objectGraph.audioGraphDelegate
    
    private let fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    private let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    private let uiState: ControlBarPlayerUIState = objectGraph.controlBarPlayerUIState
    
    private var textViewConstraints: LayoutConstraintsManager!
    private var lblSeekPositionConstraints: LayoutConstraintsManager!
    private var seekSliderConstraints: LayoutConstraintsManager!
    
    private let minWindowWidthToShowSeekPosition: CGFloat = 610
    private let distanceBetweenControlsAndInfo: CGFloat = 31
    
    private lazy var messenger = Messenger(for: self)
    
    override func awakeFromNib() {
        
        // Hack to properly align the view settings menu button.
        if !SystemUtils.isBigSur {
            viewSettingsMenuButton.moveLeft(distance: 2)
        }
        
        // Constraint managers
        lblSeekPositionConstraints = LayoutConstraintsManager(for: lblSeekPosition)
        seekSliderConstraints = LayoutConstraintsManager(for: seekSlider)
        textViewConstraints = LayoutConstraintsManager(for: textView)
        
        applyTheme()
        
        // Seek slider
        seekSliderConstraints.setLeading(relatedToLeadingOf: textView, offset: -1)
        seekSliderConstraints.setTrailing(relatedToLeadingOf: btnRepeat, offset: -distanceBetweenControlsAndInfo)
        seekSliderView.showSeekPosition = false
        
        // Text view
        textViewConstraints.setLeading(relatedToTrailingOf: imgArt, offset: 10)
        textViewConstraints.setHeight(26)
        textViewConstraints.centerVerticallyInSuperview(offset: -2)
        
        lblSeekPositionConstraints.setHeight(textView.height)
        lblSeekPositionConstraints.centerVerticallyInSuperview(offset: -2)
        
        layoutTextView()
        textView.scrollingEnabled = uiState.trackInfoScrollingEnabled
        
        updateTrackInfo()
        
        // View settings menu items
        timeElapsedMenuItem.displayType = .timeElapsed
        timeRemainingMenuItem.displayType = .timeRemaining
        trackDurationMenuItem.displayType = .duration
        
        seekPositionDisplayTypeItems = [timeElapsedMenuItem, timeRemainingMenuItem, trackDurationMenuItem]
        
        // MARK: Notification subscriptions
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribeAsync(to: .player_trackInfoUpdated, handler: trackInfoUpdated(_:))
        messenger.subscribeAsync(to: .player_trackNotPlayed, handler: trackNotPlayed(_:))
        
        messenger.subscribe(to: .favoritesList_addOrRemove, handler: addOrRemoveFavorite)
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
        messenger.subscribe(to: .applyFontScheme, handler: applyFontScheme(_:))
        messenger.subscribe(to: .applyColorScheme, handler: applyColorScheme(_:))
    }
    
    var windowWideEnoughForSeekPosition: Bool {
        (view.window?.width ?? 0) >= minWindowWidthToShowSeekPosition
    }
    
    func layoutTextView(forceChange: Bool = true) {
        
        let showSeekPosition: Bool = uiState.showSeekPosition && windowWideEnoughForSeekPosition
        
        guard forceChange || (seekSliderView.showSeekPosition != showSeekPosition) else {return}
        
        // Seek Position label
        seekSliderView.showSeekPosition = showSeekPosition
        
        var labelWidth: CGFloat = 0
        
        if showSeekPosition {
            
            lblSeekPositionConstraints.removeAll(withAttributes: [.width, .trailing])
            labelWidth = widthForSeekPosLabel() + 5 // Compute the required width and add some padding.
            
            lblSeekPositionConstraints.setWidth(labelWidth)
            lblSeekPositionConstraints.setTrailing(relatedToLeadingOf: btnRepeat, offset: -distanceBetweenControlsAndInfo)
        }
        
        // Text view
        textViewConstraints.removeAll(withAttributes: [.trailing])
        textViewConstraints.setTrailing(relatedToLeadingOf: btnRepeat,
                                        offset: -(distanceBetweenControlsAndInfo + (showSeekPosition ? labelWidth : 1)))
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

        return widthOfTimeRemainingString * widthOfWidestNumber
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
        layoutTextView(forceChange: false)
    }
    
    // Required for dock menu function "Add/Remove playing track to/from Favorites".
    private func addOrRemoveFavorite() {
        
        if let playingTrack = player.playingTrack {
            
            let file = playingTrack.file
            
            if favorites.favoriteWithFileExists(file) {
                favorites.deleteFavoriteWithFile(file)
            } else {
                _ = favorites.addFavorite(playingTrack)
            }
        }
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
    
    // MARK: View settings menu delegate functions and action handlers -----------------
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        scrollingEnabledMenuItem.onIf(textView.scrollingEnabled)
        
        let windowWideEnoughForSeekPosition = self.windowWideEnoughForSeekPosition
        showSeekPositionMenuItem.showIf(windowWideEnoughForSeekPosition)
        seekPositionDisplayTypeMenuItem.showIf(windowWideEnoughForSeekPosition && uiState.showSeekPosition)
        
        guard windowWideEnoughForSeekPosition else {return}
        
        showSeekPositionMenuItem.onIf(uiState.showSeekPosition)
        guard uiState.showSeekPosition else {return}
        
        seekPositionDisplayTypeItems.forEach {$0.off()}
        
        switch seekSliderView.seekPositionDisplayType {
        
        case .timeElapsed:
            
            timeElapsedMenuItem.on()
            
        case .timeRemaining:
            
            timeRemainingMenuItem.on()
            
        case .duration:
            
            trackDurationMenuItem.on()
        }
    }
    
    @IBAction func toggleTrackInfoScrollingAction(_ sender: NSMenuItem) {
        textView.scrollingEnabled.toggle()
    }
    
    @IBAction func toggleShowSeekPositionAction(_ sender: NSMenuItem) {
        
        uiState.showSeekPosition.toggle()
        layoutTextView()
    }
    
    @IBAction func changeSeekPositionDisplayTypeAction(_ sender: SeekPositionDisplayTypeMenuItem) {
        seekSliderView.seekPositionDisplayType = sender.displayType
    }
    
    // MARK: Tear down ------------------------------------------
    
    func destroy() {
        
        [playbackViewController, audioViewController, sequencingViewController].forEach {
            ($0 as? Destroyable)?.destroy()
        }
        
        messenger.unsubscribeFromAll()
    }
}

class SeekPositionDisplayTypeMenuItem: NSMenuItem {
    var displayType: ControlBarSeekPositionDisplayType = .timeElapsed
}
