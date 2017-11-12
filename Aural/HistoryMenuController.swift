import Cocoa

class HistoryMenuController: NSObject, NSMenuDelegate, ActionMessageSubscriber {
    
    private let history: HistoryDelegate = ObjectGraph.getHistoryDelegate()
    
    @IBOutlet weak var recentlyAddedMenu: NSMenu!
    @IBOutlet weak var recentlyPlayedMenu: NSMenu!
    @IBOutlet weak var favoritesMenu: NSMenu!
    
    private var itemsMap: [NSMenuItem: HistoryItem] = [:]
    
    override func awakeFromNib() {
        SyncMessenger.subscribe(actionTypes: [.addFavorite, .removeFavorite], subscriber: self)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        let tim = TimerUtils.start("historyMenu")
        
        recentlyAddedMenu.removeAllItems()
        recentlyPlayedMenu.removeAllItems()
        favoritesMenu.removeAllItems()
        itemsMap.removeAll()
        
        history.allAddedItems().forEach({recentlyAddedMenu.addItem(createMenuItem($0))})
        history.allPlayedItems().forEach({recentlyPlayedMenu.addItem(createMenuItem($0))})
        history.allFavorites().forEach({favoritesMenu.addItem(createMenuItem($0))})
        
        tim.end()
    }
    
    private func createMenuItem(_ item: HistoryItem) -> NSMenuItem {
        
        let action = item is PlayableHistoryItem ? #selector(self.playSelectedItemAction(_:)) : #selector(self.addSelectedItemAction(_:))
        
        let menuItem = NSMenuItem(title: "  " + item.displayName, action: action, keyEquivalent: "")
        menuItem.target = self
        
        menuItem.image = item.art
        menuItem.image?.size = Images.historyMenuItemImageSize
        
        itemsMap[menuItem] = item
        
        return menuItem
    }
    
    @IBAction func addSelectedItemAction(_ sender: NSMenuItem) {
        history.addItem(itemsMap[sender]!.file)
    }
    
    @IBAction func playSelectedItemAction(_ sender: NSMenuItem) {
        
        do {
            try history.playItem(itemsMap[sender]!.file, PlaylistViewState.current)
            
        } catch let error {
            
            if (error is FileNotFoundError) {
                //                handleTrackNotPlayedError(oldTrack, error as! InvalidTrackError)
                // TODO: Show alert
            }
        }
    }
    
    private func addFavorite(_ message: FavoritesActionMessage) {
        history.addFavorite(message.track)
    }
    
    private func removeFavorite(_ message: FavoritesActionMessage) {
        history.removeFavorite(message.track)
    }
    
    // MARK: Message handling
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .addFavorite:
            
            addFavorite(message as! FavoritesActionMessage)
            
        case .removeFavorite:
            
            removeFavorite(message as! FavoritesActionMessage)
            
        default: return
            
        }
    }
}
