//
//  PlayerViewPopupMenuController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Handles requests to show/hide or adjust different fields in the player view.
    e.g. show/hide album art or adjust seek time format.
 */
class PlayerViewPopupMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var playerDefaultViewMenuItem: NSMenuItem!
    @IBOutlet weak var playerExpandedArtViewMenuItem: NSMenuItem!
    
    @IBOutlet weak var showArtMenuItem: NSMenuItem!
    @IBOutlet weak var showTrackInfoMenuItem: NSMenuItem!
    @IBOutlet weak var showTrackFunctionsMenuItem: NSMenuItem!
    @IBOutlet weak var showMainControlsMenuItem: NSMenuItem!
    @IBOutlet weak var showTimeElapsedRemainingMenuItem: NSMenuItem!
    
    @IBOutlet weak var showArtistMenuItem: NSMenuItem!
    @IBOutlet weak var showAlbumMenuItem: NSMenuItem!
    @IBOutlet weak var showCurrentChapterMenuItem: NSMenuItem!
    
    @IBOutlet weak var timeElapsedFormatMenuItem: NSMenuItem!
    @IBOutlet weak var timeElapsedMenuItem_hms: NSMenuItem!
    @IBOutlet weak var timeElapsedMenuItem_seconds: NSMenuItem!
    @IBOutlet weak var timeElapsedMenuItem_percentage: NSMenuItem!
    private var timeElapsedDisplayFormats: [NSMenuItem] = []
    
    @IBOutlet weak var timeRemainingFormatMenuItem: NSMenuItem!
    @IBOutlet weak var timeRemainingMenuItem_hms: NSMenuItem!
    @IBOutlet weak var timeRemainingMenuItem_seconds: NSMenuItem!
    @IBOutlet weak var timeRemainingMenuItem_percentage: NSMenuItem!
    @IBOutlet weak var timeRemainingMenuItem_durationHMS: NSMenuItem!
    @IBOutlet weak var timeRemainingMenuItem_durationSeconds: NSMenuItem!
    private var timeRemainingDisplayFormats: [NSMenuItem] = []
    
    private let player: PlaybackInfoDelegateProtocol = objectGraph.playbackInfoDelegate
    
    private lazy var uiState: PlayerUIState = objectGraph.playerUIState
    
    private lazy var messenger = Messenger(for: self)
    
    override func awakeFromNib() {
        
        timeElapsedDisplayFormats = [timeElapsedMenuItem_hms, timeElapsedMenuItem_seconds, timeElapsedMenuItem_percentage]
        
        timeElapsedMenuItem_hms.representedObject = TimeElapsedDisplayType.formatted
        timeElapsedMenuItem_seconds.representedObject = TimeElapsedDisplayType.seconds
        timeElapsedMenuItem_percentage.representedObject = TimeElapsedDisplayType.percentage
        
        timeRemainingDisplayFormats = [timeRemainingMenuItem_hms, timeRemainingMenuItem_seconds, timeRemainingMenuItem_percentage, timeRemainingMenuItem_durationHMS, timeRemainingMenuItem_durationSeconds]
        
        timeRemainingMenuItem_hms.representedObject = TimeRemainingDisplayType.formatted
        timeRemainingMenuItem_seconds.representedObject = TimeRemainingDisplayType.seconds
        timeRemainingMenuItem_percentage.representedObject = TimeRemainingDisplayType.percentage
        timeRemainingMenuItem_durationHMS.representedObject = TimeRemainingDisplayType.duration_formatted
        timeRemainingMenuItem_durationSeconds.representedObject = TimeRemainingDisplayType.duration_seconds
    }
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuWillOpen(_ menu: NSMenu) {
        
        // Player view:
        playerDefaultViewMenuItem.onIf(uiState.viewType == .defaultView)
        playerExpandedArtViewMenuItem.onIf(uiState.viewType == .expandedArt)
        
        [showArtMenuItem, showMainControlsMenuItem].forEach({$0.hideIf(uiState.viewType == .expandedArt)})
        
        let trackInfoVisible: Bool = uiState.viewType == .defaultView || uiState.showTrackInfo
        
        var hasArtist: Bool = false
        var hasAlbum: Bool = false
        var hasChapters: Bool = false
        
        if let track = player.playingTrack {
            
            hasArtist = track.artist != nil
            hasAlbum = track.album != nil
            hasChapters = track.hasChapters
        }
        
        showArtistMenuItem.showIf(trackInfoVisible && hasArtist)
        showArtistMenuItem.onIf(uiState.showArtist)
        
        showAlbumMenuItem.showIf(trackInfoVisible && hasAlbum)
        showAlbumMenuItem.onIf(uiState.showAlbum)
        
        showCurrentChapterMenuItem.showIf(trackInfoVisible && hasChapters)
        showCurrentChapterMenuItem.onIf(uiState.showCurrentChapter)
        
        showTrackInfoMenuItem.hideIf(uiState.viewType == .defaultView)
        
        let defaultViewAndShowingControls = uiState.viewType == .defaultView && uiState.showControls
        showTimeElapsedRemainingMenuItem.showIf(defaultViewAndShowingControls)
        
        showArtMenuItem.onIf(uiState.showAlbumArt)
        showTrackInfoMenuItem.onIf(uiState.showTrackInfo)
        showTrackFunctionsMenuItem.onIf(uiState.showPlayingTrackFunctions)
        
        showMainControlsMenuItem.onIf(uiState.showControls)
        showTimeElapsedRemainingMenuItem.onIf(uiState.showTimeElapsedRemaining)
        
        timeElapsedFormatMenuItem.showIf(defaultViewAndShowingControls)
        timeRemainingFormatMenuItem.showIf(defaultViewAndShowingControls)
        
        if defaultViewAndShowingControls {
            
            timeElapsedDisplayFormats.forEach({$0.off()})
            
            switch uiState.timeElapsedDisplayType {
                
            case .formatted:    timeElapsedMenuItem_hms.on()
                
            case .seconds:      timeElapsedMenuItem_seconds.on()
                
            case .percentage:   timeElapsedMenuItem_percentage.on()
                
            }
            
            timeRemainingDisplayFormats.forEach({$0.off()})
            
            switch uiState.timeRemainingDisplayType {
                
            case .formatted:    timeRemainingMenuItem_hms.on()
                
            case .seconds:      timeRemainingMenuItem_seconds.on()
                
            case .percentage:   timeRemainingMenuItem_percentage.on()
                
            case .duration_formatted:   timeRemainingMenuItem_durationHMS.on()
                
            case .duration_seconds:     timeRemainingMenuItem_durationSeconds.on()
                
            }
        }
    }
   
    @IBAction func playerDefaultViewAction(_ sender: NSMenuItem) {
        
        if uiState.viewType != .defaultView {
            
            uiState.viewType = .defaultView
            messenger.publish(.player_changeView, payload: PlayerViewType.defaultView)
        }
    }
    
    @IBAction func playerExpandedArtViewAction(_ sender: NSMenuItem) {
        
        if uiState.viewType != .expandedArt {
            
            uiState.viewType = .expandedArt
            messenger.publish(.player_changeView, payload: PlayerViewType.expandedArt)
        }
    }
    
    @IBAction func showOrHidePlayingTrackFunctionsAction(_ sender: NSMenuItem) {
        
        uiState.showPlayingTrackFunctions.toggle()
        messenger.publish(.player_showOrHidePlayingTrackFunctions)
    }
    
    @IBAction func showOrHidePlayingTrackInfoAction(_ sender: NSMenuItem) {
        
        uiState.showTrackInfo.toggle()
        messenger.publish(.player_showOrHidePlayingTrackInfo)
    }
    
    @IBAction func showOrHideAlbumArtAction(_ sender: NSMenuItem) {
        
        uiState.showAlbumArt.toggle()
        messenger.publish(.player_showOrHideAlbumArt)
    }
    
    @IBAction func showOrHideArtistAction(_ sender: NSMenuItem) {
        
        uiState.showArtist.toggle()
        messenger.publish(.player_showOrHideArtist)
    }
    
    @IBAction func showOrHideAlbumAction(_ sender: NSMenuItem) {
        
        uiState.showAlbum.toggle()
        messenger.publish(.player_showOrHideAlbum)
    }
    
    @IBAction func showOrHideCurrentChapterAction(_ sender: NSMenuItem) {
        
        uiState.showCurrentChapter.toggle()
        messenger.publish(.player_showOrHideCurrentChapter)
    }
    
    @IBAction func showOrHideMainControlsAction(_ sender: NSMenuItem) {
        
        uiState.showControls.toggle()
        messenger.publish(.player_showOrHideMainControls)
    }
    
    @IBAction func showOrHideTimeElapsedRemainingAction(_ sender: NSMenuItem) {
        
        uiState.showTimeElapsedRemaining.toggle()
        messenger.publish(.player_showOrHideTimeElapsedRemaining)
    }
    
    @IBAction func timeElapsedDisplayFormatAction(_ sender: NSMenuItem) {
        
        if let format = sender.representedObject as? TimeElapsedDisplayType {
            
            uiState.timeElapsedDisplayType = format
            messenger.publish(.player_setTimeElapsedDisplayFormat, payload: format)
        }
    }
    
    @IBAction func timeRemainingDisplayFormatAction(_ sender: NSMenuItem) {
        
        if let format = sender.representedObject as? TimeRemainingDisplayType {
            
            uiState.timeRemainingDisplayType = format
            messenger.publish(.player_setTimeRemainingDisplayFormat, payload: format)
        }
    }
}
