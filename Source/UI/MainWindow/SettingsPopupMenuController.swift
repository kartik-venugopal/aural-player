import Cocoa

/*
    Controller for the settings popup menu on the main window.
 */
class SettingsPopupMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var playerViewMenuItem: NSMenuItem!
    
    @IBOutlet weak var applyFontSchemeMenuItem: NSMenuItem!
    @IBOutlet weak var saveFontSchemeMenuItem: NSMenuItem!
    
    @IBOutlet weak var applyColorSchemeMenuItem: NSMenuItem!
    @IBOutlet weak var saveColorSchemeMenuItem: NSMenuItem!
    
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        playerViewMenuItem.enableIf(player.state != .transcoding)
        
        // These items should be enabled only if there is no modal component currently shown.
        [applyFontSchemeMenuItem, saveFontSchemeMenuItem, applyColorSchemeMenuItem, saveColorSchemeMenuItem].forEach {$0.enableIf(!WindowManager.isShowingModalComponent)}
    }
}
