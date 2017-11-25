import Cocoa

class HistoryPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var recentlyAddedListSizeMenu: NSPopUpButton!
    @IBOutlet weak var recentlyPlayedListSizeMenu: NSPopUpButton!
    @IBOutlet weak var favoritesListSizeMenu: NSPopUpButton!
    
    private lazy var history: HistoryDelegateProtocol = ObjectGraph.getHistoryDelegate()
    
    override var nibName: String? {return "HistoryPreferences"}
    
    func getView() -> NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let historyPrefs = preferences.historyPreferences
        
        let recentlyAddedListSize = historyPrefs.recentlyAddedListSize
        let recentlyPlayedListSize = historyPrefs.recentlyPlayedListSize
        let favoritesListSize = historyPrefs.favoritesListSize
        
        selectItemWithTag(recentlyAddedListSizeMenu, recentlyAddedListSize)
        selectItemWithTag(recentlyPlayedListSizeMenu, recentlyPlayedListSize)
        selectItemWithTag(favoritesListSizeMenu, favoritesListSize)
    }
    
    private func selectItemWithTag(_ list: NSPopUpButton, _ tag: Int) {
        list.selectItem(withTag: tag)
    }
    
    func save(_ preferences: Preferences) {
        
        let historyPrefs = preferences.historyPreferences
        
        historyPrefs.recentlyAddedListSize = recentlyAddedListSizeMenu.selectedTag()
        historyPrefs.recentlyPlayedListSize = recentlyPlayedListSizeMenu.selectedTag()
        historyPrefs.favoritesListSize = favoritesListSizeMenu.selectedTag()
        
        history.resizeLists(historyPrefs.recentlyAddedListSize, historyPrefs.recentlyPlayedListSize, historyPrefs.favoritesListSize)
    }
}
