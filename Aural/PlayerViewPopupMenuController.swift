import Cocoa

class PlayerViewPopupMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var playerDefaultViewMenuItem: NSMenuItem!
    @IBOutlet weak var playerExpandedArtViewMenuItem: NSMenuItem!
    
    @IBOutlet weak var showArtMenuItem: NSMenuItem!
    @IBOutlet weak var showTrackInfoMenuItem: NSMenuItem!
    //    @IBOutlet weak var showSequenceInfoMenuItem: NSMenuItem!
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
    
    @IBOutlet weak var textSizeNormalMenuItem: NSMenuItem!
    @IBOutlet weak var textSizeLargerMenuItem: NSMenuItem!
    @IBOutlet weak var textSizeLargestMenuItem: NSMenuItem!
    private var textSizes: [NSMenuItem] = []
    
    private let viewAppState = ObjectGraph.appState.ui.player
    
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    override func awakeFromNib() {
        
        timeElapsedDisplayFormats = [timeElapsedMenuItem_hms, timeElapsedMenuItem_seconds, timeElapsedMenuItem_percentage]
        
        timeRemainingDisplayFormats = [timeRemainingMenuItem_hms, timeRemainingMenuItem_seconds, timeRemainingMenuItem_percentage, timeRemainingMenuItem_durationHMS, timeRemainingMenuItem_durationSeconds]
        
        textSizes = [textSizeNormalMenuItem, textSizeLargerMenuItem, textSizeLargestMenuItem]
    }
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Can't change the player view while transcoding
        for index in 2..<menu.items.count {
            menu.items[index].disableIf(player.state == .transcoding)
        }
        
        // Player view:
        playerDefaultViewMenuItem.onIf(PlayerViewState.viewType == .defaultView)
        playerExpandedArtViewMenuItem.onIf(PlayerViewState.viewType == .expandedArt)
        
        [showArtMenuItem, showMainControlsMenuItem].forEach({$0.hideIf_elseShow(PlayerViewState.viewType == .expandedArt)})
        
        let trackInfoVisible: Bool = PlayerViewState.viewType == .defaultView || PlayerViewState.showTrackInfo
        
        var hasArtist: Bool = false
        var hasAlbum: Bool = false
        var hasChapters: Bool = false
        
        if let track = player.playingTrack?.track {
            
            hasArtist = track.displayInfo.artist != nil
            hasAlbum = track.groupingInfo.album != nil
            hasChapters = track.hasChapters
        }
        
        showArtistMenuItem.showIf_elseHide(trackInfoVisible && hasArtist)
        showArtistMenuItem.onIf(PlayerViewState.showArtist)
        
        showAlbumMenuItem.showIf_elseHide(trackInfoVisible && hasAlbum)
        showAlbumMenuItem.onIf(PlayerViewState.showAlbum)
        
        showCurrentChapterMenuItem.showIf_elseHide(trackInfoVisible && hasChapters)
        showCurrentChapterMenuItem.onIf(PlayerViewState.showCurrentChapter)
        
        showTrackInfoMenuItem.hideIf_elseShow(PlayerViewState.viewType == .defaultView)
        //        showSequenceInfoMenuItem.showIf_elseHide(PlayerViewState.viewType == .defaultView || PlayerViewState.showTrackInfo)
        
        let defaultViewAndShowingControls = PlayerViewState.viewType == .defaultView && PlayerViewState.showControls
        showTimeElapsedRemainingMenuItem.showIf_elseHide(defaultViewAndShowingControls)
        
        showArtMenuItem.onIf(PlayerViewState.showAlbumArt)
        showTrackInfoMenuItem.onIf(PlayerViewState.showTrackInfo)
        //        showSequenceInfoMenuItem.onIf(PlayerViewState.showSequenceInfo)
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
        
        textSizes.forEach({
            $0.off()
        })
        
        switch PlayerViewState.textSize {
            
        case .normal:   textSizeNormalMenuItem.on()
            
        case .larger:   textSizeLargerMenuItem.on()
            
        case .largest:  textSizeLargestMenuItem.on()
            
        }
    }
    
    @IBAction func playerDefaultViewAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(PlayerViewActionMessage(.defaultView))
    }
    
    @IBAction func playerExpandedArtViewAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(PlayerViewActionMessage(.expandedArt))
    }
    
    @IBAction func showOrHidePlayingTrackFunctionsAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.showOrHidePlayingTrackFunctions))
    }
    
    @IBAction func showOrHidePlayingTrackInfoAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.showOrHidePlayingTrackInfo))
    }
    
    //    @IBAction func showOrHideSequenceInfoAction(_ sender: NSMenuItem) {
    //        SyncMessenger.publishActionMessage(ViewActionMessage(.showOrHideSequenceInfo))
    //    }
    
    @IBAction func showOrHideAlbumArtAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.showOrHideAlbumArt))
    }
    
    @IBAction func showOrHideArtistAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.showOrHideArtist))
    }
    
    @IBAction func showOrHideAlbumAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.showOrHideAlbum))
    }
    
    @IBAction func showOrHideCurrentChapterAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.showOrHideCurrentChapter))
    }
    
    @IBAction func showOrHideMainControlsAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.showOrHideMainControls))
    }
    
    @IBAction func showOrHideTimeElapsedRemainingAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.showOrHideTimeElapsedRemaining))
    }
    
    @IBAction func changeTextSizeAction(_ sender: NSMenuItem) {
        
        let senderTitle: String = sender.title.lowercased()
        let size = TextSizeScheme(rawValue: senderTitle)!
        
        if TextSizes.playerScheme != size {
            
            TextSizes.playerScheme = size
            SyncMessenger.publishActionMessage(TextSizeActionMessage(.changePlayerTextSize, size))
        }
    }
    
    @IBAction func timeElapsedDisplayFormatAction(_ sender: NSMenuItem) {
        
        var format: TimeElapsedDisplayType
        
        switch sender.tag {
            
        case 0: format = .formatted
            
        case 1: format = .seconds
            
        case 2: format = .percentage
            
        default: format = .formatted
            
        }
        
        SyncMessenger.publishActionMessage(SetTimeElapsedDisplayFormatActionMessage(format))
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
        
        SyncMessenger.publishActionMessage(SetTimeRemainingDisplayFormatActionMessage(format))
    }
}
