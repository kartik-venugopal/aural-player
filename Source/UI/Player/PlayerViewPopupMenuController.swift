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
    
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    override func awakeFromNib() {
        
        timeElapsedDisplayFormats = [timeElapsedMenuItem_hms, timeElapsedMenuItem_seconds, timeElapsedMenuItem_percentage]
        
        timeRemainingDisplayFormats = [timeRemainingMenuItem_hms, timeRemainingMenuItem_seconds, timeRemainingMenuItem_percentage, timeRemainingMenuItem_durationHMS, timeRemainingMenuItem_durationSeconds]
    }
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuWillOpen(_ menu: NSMenu) {
        
        // Player view:
        playerDefaultViewMenuItem.onIf(PlayerViewState.viewType == .defaultView)
        playerExpandedArtViewMenuItem.onIf(PlayerViewState.viewType == .expandedArt)
        
        [showArtMenuItem, showMainControlsMenuItem].forEach({$0.hideIf_elseShow(PlayerViewState.viewType == .expandedArt)})
        
        let trackInfoVisible: Bool = PlayerViewState.viewType == .defaultView || PlayerViewState.showTrackInfo
        
        var hasArtist: Bool = false
        var hasAlbum: Bool = false
        var hasChapters: Bool = false
        
        if let track = player.playingTrack {
            
            hasArtist = track.artist != nil
            hasAlbum = track.album != nil
            hasChapters = track.hasChapters
        }
        
        showArtistMenuItem.showIf_elseHide(trackInfoVisible && hasArtist)
        showArtistMenuItem.onIf(PlayerViewState.showArtist)
        
        showAlbumMenuItem.showIf_elseHide(trackInfoVisible && hasAlbum)
        showAlbumMenuItem.onIf(PlayerViewState.showAlbum)
        
        showCurrentChapterMenuItem.showIf_elseHide(trackInfoVisible && hasChapters)
        showCurrentChapterMenuItem.onIf(PlayerViewState.showCurrentChapter)
        
        showTrackInfoMenuItem.hideIf_elseShow(PlayerViewState.viewType == .defaultView)
        
        let defaultViewAndShowingControls = PlayerViewState.viewType == .defaultView && PlayerViewState.showControls
        showTimeElapsedRemainingMenuItem.showIf_elseHide(defaultViewAndShowingControls)
        
        showArtMenuItem.onIf(PlayerViewState.showAlbumArt)
        showTrackInfoMenuItem.onIf(PlayerViewState.showTrackInfo)
        showTrackFunctionsMenuItem.onIf(PlayerViewState.showPlayingTrackFunctions)
        
        showMainControlsMenuItem.onIf(PlayerViewState.showControls)
        showTimeElapsedRemainingMenuItem.onIf(PlayerViewState.showTimeElapsedRemaining)
        
        timeElapsedFormatMenuItem.showIf_elseHide(defaultViewAndShowingControls)
        timeRemainingFormatMenuItem.showIf_elseHide(defaultViewAndShowingControls)
        
        if defaultViewAndShowingControls {
            
            timeElapsedDisplayFormats.forEach({$0.off()})
            
            switch PlayerViewState.timeElapsedDisplayType {
                
            case .formatted:    timeElapsedMenuItem_hms.on()
                
            case .seconds:      timeElapsedMenuItem_seconds.on()
                
            case .percentage:   timeElapsedMenuItem_percentage.on()
                
            }
            
            timeRemainingDisplayFormats.forEach({$0.off()})
            
            switch PlayerViewState.timeRemainingDisplayType {
                
            case .formatted:    timeRemainingMenuItem_hms.on()
                
            case .seconds:      timeRemainingMenuItem_seconds.on()
                
            case .percentage:   timeRemainingMenuItem_percentage.on()
                
            case .duration_formatted:   timeRemainingMenuItem_durationHMS.on()
                
            case .duration_seconds:     timeRemainingMenuItem_durationSeconds.on()
                
            }
        }
    }
   
    @IBAction func playerDefaultViewAction(_ sender: NSMenuItem) {
        
        if PlayerViewState.viewType != .defaultView {
            
            PlayerViewState.viewType = .defaultView
            Messenger.publish(.player_changeView, payload: PlayerViewType.defaultView)
        }
    }
    
    @IBAction func playerExpandedArtViewAction(_ sender: NSMenuItem) {
        
        if PlayerViewState.viewType != .expandedArt {
            
            PlayerViewState.viewType = .expandedArt
            Messenger.publish(.player_changeView, payload: PlayerViewType.expandedArt)
        }
    }
    
    @IBAction func showOrHidePlayingTrackFunctionsAction(_ sender: NSMenuItem) {
        
        PlayerViewState.showPlayingTrackFunctions.toggle()
        Messenger.publish(.player_showOrHidePlayingTrackFunctions)
    }
    
    @IBAction func showOrHidePlayingTrackInfoAction(_ sender: NSMenuItem) {
        
        PlayerViewState.showTrackInfo.toggle()
        Messenger.publish(.player_showOrHidePlayingTrackInfo)
    }
    
    @IBAction func showOrHideAlbumArtAction(_ sender: NSMenuItem) {
        
        PlayerViewState.showAlbumArt.toggle()
        Messenger.publish(.player_showOrHideAlbumArt)
    }
    
    @IBAction func showOrHideArtistAction(_ sender: NSMenuItem) {
        
        PlayerViewState.showArtist.toggle()
        Messenger.publish(.player_showOrHideArtist)
    }
    
    @IBAction func showOrHideAlbumAction(_ sender: NSMenuItem) {
        
        PlayerViewState.showAlbum.toggle()
        Messenger.publish(.player_showOrHideAlbum)
    }
    
    @IBAction func showOrHideCurrentChapterAction(_ sender: NSMenuItem) {
        
        PlayerViewState.showCurrentChapter.toggle()
        Messenger.publish(.player_showOrHideCurrentChapter)
    }
    
    @IBAction func showOrHideMainControlsAction(_ sender: NSMenuItem) {
        
        PlayerViewState.showControls.toggle()
        Messenger.publish(.player_showOrHideMainControls)
    }
    
    @IBAction func showOrHideTimeElapsedRemainingAction(_ sender: NSMenuItem) {
        
        PlayerViewState.showTimeElapsedRemaining.toggle()
        Messenger.publish(.player_showOrHideTimeElapsedRemaining)
    }
    
    @IBAction func timeElapsedDisplayFormatAction(_ sender: NSMenuItem) {
        
        var format: TimeElapsedDisplayType
        
        switch sender.tag {
            
        case 0: format = .formatted
            
        case 1: format = .seconds
            
        case 2: format = .percentage
            
        default: format = .formatted
            
        }
        
        PlayerViewState.timeElapsedDisplayType = format
        Messenger.publish(.player_setTimeElapsedDisplayFormat, payload: format)
    }
    
    @IBAction func timeRemainingDisplayFormatAction(_ sender: NSMenuItem) {
        
        var format: TimeRemainingDisplayType
        
        switch sender.tag {
            
        case 0: format = .formatted
            
        case 1: format = .seconds
            
        case 2: format = .percentage
            
        case 3: format = .duration_formatted
            
        case 4: format = .duration_seconds
            
        default: format = .formatted
            
        }
        
        PlayerViewState.timeRemainingDisplayType = format
        Messenger.publish(.player_setTimeRemainingDisplayFormat, payload: format)
    }
}
