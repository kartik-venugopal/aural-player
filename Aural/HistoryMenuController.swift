import Cocoa

class HistoryMenuController: NSObject, NSMenuDelegate, ActionMessageSubscriber {
    
    private let history: HistoryDelegate = ObjectGraph.getHistoryDelegate()
    
    @IBOutlet weak var recentlyPlayedItemsMenu: NSMenu!
    @IBOutlet weak var favoritesMenu: NSMenu!
    
    private var itemsMap: [NSMenuItem: HistoryItem] = [:]
    
    override func awakeFromNib() {
        SyncMessenger.subscribe(actionTypes: [.addFavorite, .removeFavorite], subscriber: self)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        recentlyPlayedItemsMenu.removeAllItems()
        favoritesMenu.removeAllItems()
        itemsMap.removeAll()
        
        history.allPlayedItems().forEach({recentlyPlayedItemsMenu.addItem(createMenuItem($0))})
        history.allFavorites().forEach({favoritesMenu.addItem(createMenuItem($0))})
    }
    
    private func createMenuItem(_ item: HistoryItem) -> NSMenuItem {
        
        let tim = TimerUtils.start("createMenuItem")
        
        let menuItem = NSMenuItem(title: "  " + item.displayName, action: #selector(self.playSelectedItemAction(_:)), keyEquivalent: "")
        menuItem.target = self
        
        menuItem.image = item.art
        menuItem.image?.size = Images.historyMenuItemImageSize
        
        itemsMap[menuItem] = item
        
        tim.end()
        return menuItem
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
