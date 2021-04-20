import Cocoa

class HistoryPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var recentlyAddedListSizeMenu: NSPopUpButton!
    @IBOutlet weak var recentlyPlayedListSizeMenu: NSPopUpButton!
    
    private lazy var history: HistoryDelegateProtocol = ObjectGraph.historyDelegate
    
    override var nibName: String? {"HistoryPreferences"}
    
    var preferencesView: NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let historyPrefs = preferences.historyPreferences
        
        let recentlyAddedListSize = historyPrefs.recentlyAddedListSize
        let recentlyPlayedListSize = historyPrefs.recentlyPlayedListSize
        
        selectItemWithTag(recentlyAddedListSizeMenu, recentlyAddedListSize)
        selectItemWithTag(recentlyPlayedListSizeMenu, recentlyPlayedListSize)
    }
    
    private func selectItemWithTag(_ list: NSPopUpButton, _ tag: Int) {
        list.selectItem(withTag: tag)
    }
    
    func save(_ preferences: Preferences) throws {
        
        let historyPrefs = preferences.historyPreferences
        
        historyPrefs.recentlyAddedListSize = recentlyAddedListSizeMenu.selectedTag()
        historyPrefs.recentlyPlayedListSize = recentlyPlayedListSizeMenu.selectedTag()
        
        history.resizeLists(historyPrefs.recentlyAddedListSize, historyPrefs.recentlyPlayedListSize)
    }
}
