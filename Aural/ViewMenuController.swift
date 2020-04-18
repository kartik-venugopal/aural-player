import Cocoa

/*
    Provides actions for the View menu that alters the layout of the app's windows and views.
 
    NOTE - No actions are directly handled by this class. Action messages are published to another app component that is responsible for these functions.
 */
class ViewMenuController: NSObject, NSMenuDelegate, StringInputClient {
    
    @IBOutlet weak var playerMenuItem: NSMenuItem!
    
    // Menu items whose states are toggled when they (or others) are clicked
    @IBOutlet weak var togglePlaylistMenuItem: NSMenuItem!
    @IBOutlet weak var toggleEffectsMenuItem: NSMenuItem!
    @IBOutlet weak var toggleChaptersListMenuItem: NSMenuItem!
    
    @IBOutlet weak var playlistViewMenuItem: NSMenuItem!
    @IBOutlet weak var effectsViewMenuItem: NSMenuItem!
    
    @IBOutlet weak var windowLayoutsMenu: NSMenu!
    @IBOutlet weak var manageLayoutsMenuItem: NSMenuItem!
    
    private let viewAppState = ObjectGraph.appState.ui.player
    
    // To save the name of a custom window layout
    private lazy var layoutNamePopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    private lazy var windowManager: WindowManagerProtocol = ObjectGraph.windowManager
    
    private lazy var editorWindowController: EditorWindowController = WindowFactory.editorWindowController
    
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        playerMenuItem.enableIf(player.state != .transcoding)
        manageLayoutsMenuItem.enableIf(!WindowLayouts.userDefinedLayouts.isEmpty)
        toggleChaptersListMenuItem.enableIf(player.chapterCount > 0)
    }
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuWillOpen(_ menu: NSMenu) {
        
        [togglePlaylistMenuItem, toggleEffectsMenuItem].forEach({$0?.show()})
        
        togglePlaylistMenuItem.onIf(windowManager.isShowingPlaylist)
        toggleEffectsMenuItem.onIf(windowManager.isShowingEffects)
        toggleChaptersListMenuItem.onIf(windowManager.isShowingChaptersList)
        
        
        playlistViewMenuItem.showIf_elseHide(windowManager.isShowingPlaylist)
        effectsViewMenuItem.showIf_elseHide(windowManager.isShowingEffects)
        
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
        
        playerMenuItem.off()
    }
 
    // Shows/hides the playlist window
    @IBAction func togglePlaylistAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.togglePlaylist))
    }
    
    // Shows/hides the effects window
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.toggleEffects))
    }
    
    // Shows/hides the chapters list window
    @IBAction func toggleChaptersListAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.toggleChaptersList))
    }
    
    @IBAction func changeTextSizeAction(_ sender: NSMenuItem) {
        
        let senderTitle: String = sender.title.lowercased()
        
        if let size = TextSize(rawValue: senderTitle) {
        
            if PlayerViewState.textSize != size {
                
                PlayerViewState.textSize = size
                SyncMessenger.publishActionMessage(TextSizeActionMessage(.changePlayerTextSize, size))
            }
            
            if PlaylistViewState.textSize != size {
                
                PlaylistViewState.textSize = size
                SyncMessenger.publishActionMessage(TextSizeActionMessage(.changePlaylistTextSize, size))
            }
            
            if EffectsViewState.textSize != size {
                
                EffectsViewState.textSize = size
                SyncMessenger.publishActionMessage(TextSizeActionMessage(.changeEffectsTextSize, size))
            }
        }
    }
    
    // TODO: Revisit this
    @IBAction func alwaysOnTopAction(_ sender: NSMenuItem) {
//        windowManager.toggleAlwaysOnTop()
    }
    
    @IBAction func windowLayoutAction(_ sender: NSMenuItem) {
        windowManager.layout(sender.title)
    }
    
    @IBAction func saveWindowLayoutAction(_ sender: NSMenuItem) {
        layoutNamePopover.show(windowManager.mainWindow.contentView!, NSRectEdge.maxX)
    }
    
    @IBAction func manageLayoutsAction(_ sender: Any) {
        editorWindowController.showLayoutsEditor()
    }
    
    // MARK - StringInputClient functions
    
    var inputPrompt: String {
        return "Enter a layout name:"
    }
    
    var defaultValue: String? {
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
    
    var inputFontSize: TextSize {
        return .normal
    }
}

fileprivate class CustomLayoutMenuItem: NSMenuItem {}
