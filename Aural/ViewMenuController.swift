import Cocoa

/*
    Provides actions for the View menu that alters the layout of the app's windows and views.
 
    NOTE - No actions are directly handled by this class. Action messages are published to another app component that is responsible for these functions.
 */
class ViewMenuController: NSObject, NSMenuDelegate, StringInputClient {
    
    @IBOutlet weak var dockMiniBarMenu: NSMenuItem!
    
    @IBOutlet weak var maximizePlaylistMenuItem: NSMenuItem!
    
    @IBOutlet weak var switchViewMenuItem: ToggleMenuItem!
    
    @IBOutlet weak var playerMenuItem: NSMenuItem!
    
    @IBOutlet weak var playerDefaultViewMenuItem: NSMenuItem!
    @IBOutlet weak var playerExpandedArtViewMenuItem: NSMenuItem!
    
    @IBOutlet weak var showArtMenuItem: NSMenuItem!
    @IBOutlet weak var showTrackInfoMenuItem: NSMenuItem!
    @IBOutlet weak var showSequenceInfoMenuItem: NSMenuItem!
    @IBOutlet weak var showTrackFunctionsMenuItem: NSMenuItem!
    @IBOutlet weak var showMainControlsMenuItem: NSMenuItem!
    @IBOutlet weak var showTimeElapsedRemainingMenuItem: NSMenuItem!
    
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
    
    // Menu items whose states are toggled when they (or others) are clicked
    @IBOutlet weak var togglePlaylistMenuItem: NSMenuItem!
    @IBOutlet weak var toggleEffectsMenuItem: NSMenuItem!
    
    @IBOutlet weak var windowLayoutsMenu: NSMenu!
    @IBOutlet weak var manageLayoutsMenuItem: NSMenuItem!
    
    private let viewAppState = ObjectGraph.appState.ui.player
    
    // To save the name of a custom window layout
    private lazy var layoutNamePopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    private lazy var layoutManager: LayoutManager = ObjectGraph.layoutManager
    
    private lazy var editorWindowController: EditorWindowController = WindowFactory.getEditorWindowController()
    
    override func awakeFromNib() {
        
        switchViewMenuItem.off()
        
        timeElapsedDisplayFormats = [timeElapsedMenuItem_hms, timeElapsedMenuItem_seconds, timeElapsedMenuItem_percentage]
        timeRemainingDisplayFormats = [timeRemainingMenuItem_hms, timeRemainingMenuItem_seconds, timeRemainingMenuItem_percentage, timeRemainingMenuItem_durationHMS, timeRemainingMenuItem_durationSeconds]
    }
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        switchViewMenuItem.onIf(AppModeManager.mode != .regular)
        dockMiniBarMenu.hideIf_elseShow(AppModeManager.mode == .regular)
        
        if (AppModeManager.mode == .regular) {
            
            [togglePlaylistMenuItem, toggleEffectsMenuItem].forEach({$0?.show()})
            
            togglePlaylistMenuItem.onIf(layoutManager.isShowingPlaylist())
            toggleEffectsMenuItem.onIf(layoutManager.isShowingEffects())
            
        } else {
            
            [togglePlaylistMenuItem, toggleEffectsMenuItem].forEach({$0?.hide()})
        }
        
        // Recreate the custom layout items
        self.windowLayoutsMenu.items.forEach({
        
            if $0 is CustomLayoutMenuItem {
                 windowLayoutsMenu.removeItem($0)
            }
        })
        
        // Add custom window layouts
        let customLayouts = WindowLayouts.userDefinedLayouts
            
        customLayouts.forEach({
        
            // The action for the menu item will depend on whether it is a playable item
            let action = #selector(self.windowLayoutAction(_:))
            
            let menuItem = CustomLayoutMenuItem(title: $0.name, action: action, keyEquivalent: "")
            menuItem.target = self
            
            self.windowLayoutsMenu.insertItem(menuItem, at: 0)
        })
    
        manageLayoutsMenuItem.enableIf(!customLayouts.isEmpty)
        
        playerMenuItem.off()
        
        // Player view:
        playerDefaultViewMenuItem.onIf(PlayerViewState.viewType == .defaultView)
        playerExpandedArtViewMenuItem.onIf(PlayerViewState.viewType == .expandedArt)
        
        [showArtMenuItem, showMainControlsMenuItem].forEach({$0.hideIf_elseShow(PlayerViewState.viewType == .expandedArt)})
        
        showTrackInfoMenuItem.hideIf_elseShow(PlayerViewState.viewType == .defaultView)
        showSequenceInfoMenuItem.showIf_elseHide(PlayerViewState.viewType == .defaultView || PlayerViewState.showTrackInfo)
        
        let defaultViewAndShowingControls = PlayerViewState.viewType == .defaultView && PlayerViewState.showControls
        showTimeElapsedRemainingMenuItem.showIf_elseHide(defaultViewAndShowingControls)
        
        showArtMenuItem.onIf(PlayerViewState.showAlbumArt)
        showTrackInfoMenuItem.onIf(PlayerViewState.showTrackInfo)
        showSequenceInfoMenuItem.onIf(PlayerViewState.showSequenceInfo)
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
 
    // Shows/hides the playlist window
    @IBAction func togglePlaylistAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.togglePlaylist))
    }
    
    // Shows/hides the effects panel
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.toggleEffects))
    }
    
    @IBAction func switchViewAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(AppModeActionMessage(AppModeManager.mode == .regular ? .miniBarAppMode : .regularAppMode))
    }
    
    @IBAction func dockMiniBarTopLeftAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(MiniBarActionMessage(.dockTopLeft))
    }
    
    @IBAction func dockMiniBarTopRightAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(MiniBarActionMessage(.dockTopRight))
    }
    
    @IBAction func dockMiniBarBottomLeftAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(MiniBarActionMessage(.dockBottomLeft))
    }
    
    @IBAction func dockMiniBarBottomRightAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(MiniBarActionMessage(.dockBottomRight))
    }
    
    @IBAction func windowLayoutAction(_ sender: NSMenuItem) {
        layoutManager.layout(sender.title)
    }
    
    @IBAction func saveWindowLayoutAction(_ sender: NSMenuItem) {
        layoutNamePopover.show(layoutManager.mainWindow.contentView!, NSRectEdge.maxX)
    }
    
    @IBAction func manageLayoutsAction(_ sender: Any) {
        editorWindowController.showLayoutsEditor()
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
    
    @IBAction func showOrHideSequenceInfoAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.showOrHideSequenceInfo))
    }
    
    @IBAction func showOrHideAlbumArtAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.showOrHideAlbumArt))
    }
    
    @IBAction func showOrHideMainControlsAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.showOrHideMainControls))
    }
    
    @IBAction func showOrHideTimeElapsedRemainingAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.showOrHideTimeElapsedRemaining))
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
    
    // MARK - StringInputClient functions
    
    func getInputPrompt() -> String {
        return "Enter a layout name:"
    }
    
    func getDefaultValue() -> String? {
        return "<My custom layout>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        let valid = !WindowLayouts.layoutWithNameExists(string)

        if (!valid) {
            return (false, "A layout with this name already exists !")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new EQ preset name and saves the new preset
    func acceptInput(_ string: String) {
        WindowLayouts.addUserDefinedLayout(string)
    }
}

fileprivate class CustomLayoutMenuItem: NSMenuItem {}
