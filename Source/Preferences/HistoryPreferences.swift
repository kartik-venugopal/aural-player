import Cocoa

class HistoryPreferences: PersistentPreferencesProtocol {
    
    var recentlyAddedListSize: Int
    var recentlyPlayedListSize: Int
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        recentlyAddedListSize = defaultsDictionary["history.recentlyAddedListSize"] as? Int ?? PreferencesDefaults.History.recentlyAddedListSize
        recentlyPlayedListSize = defaultsDictionary["history.recentlyPlayedListSize"] as? Int ?? PreferencesDefaults.History.recentlyPlayedListSize
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults.set(recentlyAddedListSize, forKey: "history.recentlyAddedListSize")
        defaults.set(recentlyPlayedListSize, forKey: "history.recentlyPlayedListSize")
    }
}
