import Cocoa

class HistoryPreferences: PersistentPreferencesProtocol {
    
    var recentlyAddedListSize: Int
    var recentlyPlayedListSize: Int
    
    private static let keyPrefix: String = "history"
    private static let key_recentlyAddedListSize: String = "\(HistoryPreferences.keyPrefix).recentlyAddedListSize"
    private static let key_recentlyPlayedListSize: String = "\(HistoryPreferences.keyPrefix).recentlyPlayedListSize"
    
    internal required init(_ defaultsDictionary: [String: Any]) {
        
        recentlyAddedListSize = defaultsDictionary[Self.key_recentlyAddedListSize, Int.self] ?? PreferencesDefaults.History.recentlyAddedListSize
        recentlyPlayedListSize = defaultsDictionary[Self.key_recentlyPlayedListSize, Int.self] ?? PreferencesDefaults.History.recentlyPlayedListSize
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults.set(recentlyAddedListSize, forKey: Self.key_recentlyAddedListSize)
        defaults.set(recentlyPlayedListSize, forKey: Self.key_recentlyPlayedListSize)
    }
}
