import Cocoa

/*
    Provides actions for the View menu
 */
class ViewMenuController: NSObject {
 
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
}
