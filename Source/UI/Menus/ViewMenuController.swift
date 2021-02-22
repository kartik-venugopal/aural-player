import Cocoa

/*
    Provides actions for the View menu that alters the layout of the app's windows and views.
 
    NOTE - No actions are directly handled by this class. Command notifications are published to another app component that is responsible for these functions.
 */
class ViewMenuController: NSObject, NSMenuDelegate, StringInputReceiver {
    
    @IBOutlet weak var playerMenuItem: NSMenuItem!
    
    // Menu items whose states are toggled when they (or others) are clicked
    @IBOutlet weak var togglePlaylistMenuItem: NSMenuItem!
    @IBOutlet weak var toggleEffectsMenuItem: NSMenuItem!
    @IBOutlet weak var toggleChaptersListMenuItem: NSMenuItem!
    
    @IBOutlet weak var playerViewMenuItem: NSMenuItem!
    
    @IBOutlet weak var applyColorSchemeMenuItem: NSMenuItem!
    @IBOutlet weak var saveColorSchemeMenuItem: NSMenuItem!
    @IBOutlet weak var manageColorSchemesMenuItem: NSMenuItem!
    
    @IBOutlet weak var windowLayoutsMenu: NSMenu!
    @IBOutlet weak var manageLayoutsMenuItem: NSMenuItem!
    
    private let viewAppState = ObjectGraph.appState.ui.player
    
    // To save the name of a custom window layout
    private lazy var layoutNamePopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    private lazy var editorWindowController: EditorWindowController = WindowFactory.editorWindowController
    
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        playerMenuItem.enableIf(player.state != .transcoding)
        manageLayoutsMenuItem.enableIf(!WindowLayouts.userDefinedLayouts.isEmpty)
        toggleChaptersListMenuItem.enableIf(player.chapterCount > 0)
        
        let showingModalComponent: Bool = WindowManager.isShowingModalComponent
        
        [applyColorSchemeMenuItem, saveColorSchemeMenuItem].forEach({$0.enableIf(!showingModalComponent)})
        manageColorSchemesMenuItem.enableIf(!showingModalComponent && (ColorSchemes.numberOfUserDefinedSchemes > 0))
        
        playerViewMenuItem.enableIf(player.state != .transcoding)
    }
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuWillOpen(_ menu: NSMenu) {
        
        [togglePlaylistMenuItem, toggleEffectsMenuItem].forEach({$0?.show()})
        
        togglePlaylistMenuItem.onIf(WindowManager.isShowingPlaylist)
        toggleEffectsMenuItem.onIf(WindowManager.isShowingEffects)
        toggleChaptersListMenuItem.onIf(WindowManager.isShowingChaptersList)
        
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
        Messenger.publish(.windowManager_togglePlaylistWindow)
    }
    
    // Shows/hides the effects window
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        Messenger.publish(.windowManager_toggleEffectsWindow)
    }
    
    // Shows/hides the chapters list window
    @IBAction func toggleChaptersListAction(_ sender: AnyObject) {
        WindowManager.toggleChaptersList()
    }
    
    // TODO: Revisit this
    @IBAction func alwaysOnTopAction(_ sender: NSMenuItem) {
//        WindowManager.toggleAlwaysOnTop()
    }
    
    @IBAction func windowLayoutAction(_ sender: NSMenuItem) {
        WindowManager.layout(sender.title)
    }
    
    @IBAction func saveWindowLayoutAction(_ sender: NSMenuItem) {
        layoutNamePopover.show(WindowManager.mainWindow.contentView!, NSRectEdge.maxX)
    }
    
    @IBAction func manageLayoutsAction(_ sender: Any) {
        editorWindowController.showLayoutsEditor()
    }
    
    // TODO: Separate these functions into a new WindowLayoutNameInputReceiver class
    // MARK - StringInputReceiver functions
    
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
        WindowLayouts.addUserDefinedLayout(string, WindowManager.currentWindowLayout)
    }
}

fileprivate class CustomLayoutMenuItem: NSMenuItem {}
