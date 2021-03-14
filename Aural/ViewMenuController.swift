import Cocoa

/*
    Provides actions for the View menu that alters the layout of the app's windows and views.
 
    NOTE - No actions are directly handled by this class. Action messages are published to another app component that is responsible for these functions.
 */
class ViewMenuController: NSObject, NSMenuDelegate, StringInputClient {
    
    @IBOutlet weak var dockMiniBarMenu: NSMenuItem!
    
    @IBOutlet weak var switchViewMenuItem: ToggleMenuItem!
    
    @IBOutlet weak var playerMenuItem: NSMenuItem!
    
    // Menu items whose states are toggled when they (or others) are clicked
    @IBOutlet weak var togglePlaylistMenuItem: NSMenuItem!
    @IBOutlet weak var toggleEffectsMenuItem: NSMenuItem!
    
    @IBOutlet weak var playlistViewMenuItem: NSMenuItem!
    @IBOutlet weak var effectsViewMenuItem: NSMenuItem!
    
    @IBOutlet weak var windowLayoutsMenu: NSMenu!
    @IBOutlet weak var manageLayoutsMenuItem: NSMenuItem!
    
    @IBOutlet weak var colorSchemeDarkBackgroundMenuItem: NSMenuItem!
    @IBOutlet weak var colorSchemeLightBackgroundMenuItem: NSMenuItem!
    
    private let viewAppState = ObjectGraph.appState.ui.player
    
    // To save the name of a custom window layout
    private lazy var layoutNamePopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    private lazy var layoutManager: LayoutManager = ObjectGraph.layoutManager
    
    private lazy var editorWindowController: EditorWindowController = WindowFactory.getEditorWindowController()
    
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    override func awakeFromNib() {
        switchViewMenuItem.off()
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        playerMenuItem.enableIf(player.state != .transcoding)
        manageLayoutsMenuItem.enableIf(!WindowLayouts.userDefinedLayouts.isEmpty)
    }
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuWillOpen(_ menu: NSMenu) {
        
        switchViewMenuItem.onIf(AppModeManager.mode != .regular)
        dockMiniBarMenu.hideIf_elseShow(AppModeManager.mode == .regular)
        
        if (AppModeManager.mode == .regular) {
            
            [togglePlaylistMenuItem, toggleEffectsMenuItem].forEach({$0?.show()})
            
            togglePlaylistMenuItem.onIf(layoutManager.isShowingPlaylist())
            toggleEffectsMenuItem.onIf(layoutManager.isShowingEffects())
            
        } else {
            
            [togglePlaylistMenuItem, toggleEffectsMenuItem].forEach({$0?.hide()})
        }
        
        playlistViewMenuItem.showIf_elseHide(layoutManager.isShowingPlaylist())
        effectsViewMenuItem.showIf_elseHide(layoutManager.isShowingEffects())
        
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
        
        colorSchemeDarkBackgroundMenuItem.onIf(Colors.scheme == .darkBackground_lightText)
        colorSchemeLightBackgroundMenuItem.onIf(Colors.scheme == .lightBackground_darkText)
    }
 
    // Shows/hides the playlist window
    @IBAction func togglePlaylistAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.togglePlaylist))
    }
    
    // Shows/hides the effects panel
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.toggleEffects))
    }
    
    @IBAction func changeTextSizeAction(_ sender: NSMenuItem) {
        
        let senderTitle: String = sender.title.lowercased()
        let size = TextSizeScheme(rawValue: senderTitle)!
        
        TextSizes.playerScheme = size
        TextSizes.playlistScheme = size
        TextSizes.effectsScheme = size
        
        SyncMessenger.publishActionMessage(TextSizeActionMessage(.changePlayerTextSize, size))
        SyncMessenger.publishActionMessage(TextSizeActionMessage(.changePlaylistTextSize, size))
        SyncMessenger.publishActionMessage(TextSizeActionMessage(.changeEffectsTextSize, size))
    }
    
    @IBAction func changeColorSchemeAction(_ sender: NSMenuItem) {
        
        if let scheme = ColorScheme(rawValue: sender.identifier!.rawValue), scheme != Colors.scheme {
            Colors.scheme = scheme
            SyncMessenger.publishActionMessage(ColorSchemeActionMessage(scheme))
        }
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
    
    @IBAction func alwaysOnTopAction(_ sender: NSMenuItem) {
        layoutManager.toggleAlwaysOnTop()
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
    
    func getInputFontSize() -> TextSizeScheme {
        return .normal
    }
}

fileprivate class CustomLayoutMenuItem: NSMenuItem {}
