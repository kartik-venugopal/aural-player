import Cocoa

/*
    Provides actions for the View menu that alters the layout of the app's windows and views.
 
    NOTE - No actions are directly handled by this class. Action messages are published to another app component that is responsible for these functions.
 */
class ViewMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var theMenu: NSMenuItem!
    
    @IBOutlet weak var dockPlaylistMenuItem: NSMenuItem!
    @IBOutlet weak var maximizePlaylistMenuItem: NSMenuItem!
    
    @IBOutlet weak var switchViewMenuItem: ToggleMenuItem!
    
    // Menu items whose states are toggled when they (or others) are clicked
    @IBOutlet weak var togglePlaylistMenuItem: NSMenuItem!
    @IBOutlet weak var toggleEffectsMenuItem: NSMenuItem!
    
    override func awakeFromNib() {
        switchViewMenuItem.off()
    }
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        switchViewMenuItem.onIf(AppModeManager.mode != .regular)
        
        if (AppModeManager.mode == .regular) {
            
            [togglePlaylistMenuItem, toggleEffectsMenuItem, dockPlaylistMenuItem, maximizePlaylistMenuItem].forEach({$0?.isHidden = false})
            
            togglePlaylistMenuItem.state = WindowState.showingPlaylist ? 1 : 0
            toggleEffectsMenuItem.state = WindowState.showingEffects ? 1 : 0
            
        } else {
            
            [togglePlaylistMenuItem, toggleEffectsMenuItem, dockPlaylistMenuItem, maximizePlaylistMenuItem].forEach({$0?.isHidden = true})
        }
    }
 
    // Docks the playlist window to the left of the main window
    @IBAction func dockPlaylistLeftAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.dockLeft, nil))
    }
    
    // Docks the playlist window below the main window
    @IBAction func dockPlaylistBottomAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.dockBottom, nil))
    }
    
    // Docks the playlist window to the right of the main window
    @IBAction func dockPlaylistRightAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.dockRight, nil))
    }
    
    // Maximizes the playlist window, both horizontally and vertically
    @IBAction func maximizePlaylistAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.maximize, nil))
    }
    
    // Maximizes the playlist window vertically
    @IBAction func maximizePlaylistVerticalAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.maximizeVertical, nil))
    }
    
    // Maximizes the playlist window horizontally
    @IBAction func maximizePlaylistHorizontalAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.maximizeHorizontal, nil))
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
}
