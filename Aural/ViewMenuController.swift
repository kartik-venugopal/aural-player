import Cocoa

/*
    Provides actions for the View menu
 */
class ViewMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var togglePlaylistMenuItem: NSMenuItem!
    @IBOutlet weak var toggleEffectsMenuItem: NSMenuItem!
    
    func menuWillOpen(_ menu: NSMenu) {
        togglePlaylistMenuItem.state = WindowState.showingPlaylist ? 1 : 0
        toggleEffectsMenuItem.state = WindowState.showingEffects ? 1 : 0
    }
 
    @IBAction func dockPlaylistLeftAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.dockLeft, nil))
    }
    
    @IBAction func dockPlaylistBottomAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.dockBottom, nil))
    }
    
    @IBAction func dockPlaylistRightAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.dockRight, nil))
    }
    
    @IBAction func maximizePlaylistAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.maximize, nil))
    }
    
    @IBAction func maximizePlaylistVerticalAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.maximizeVertical, nil))
    }
    
    @IBAction func maximizePlaylistHorizontalAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.maximizeHorizontal, nil))
    }
    
    @IBAction func togglePlaylistAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.togglePlaylist))
    }
    
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.toggleEffects))
    }
}
