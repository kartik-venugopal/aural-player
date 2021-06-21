import Cocoa

class HistoryPreferences: PersistentPreferencesProtocol {
    
    var recentlyAddedListSize: Int
    var recentlyPlayedListSize: Int
    
    private static let keyPrefix: String = "history"
    
    private static let key_recentlyAddedListSize: String = "\(keyPrefix).recentlyAddedListSize"
    private static let key_recentlyPlayedListSize: String = "\(keyPrefix).recentlyPlayedListSize"
    
    private typealias Defaults = PreferencesDefaults.History
    
    internal required init(_ dict: [String: Any]) {
        
        recentlyAddedListSize = dict[Self.key_recentlyAddedListSize, Int.self] ?? Defaults.recentlyAddedListSize
        recentlyPlayedListSize = dict[Self.key_recentlyPlayedListSize, Int.self] ?? Defaults.recentlyPlayedListSize
    }
    
    func persist(to defaults: UserDefaults) {
        
        defaults.set(recentlyAddedListSize, forKey: Self.key_recentlyAddedListSize)
        defaults.set(recentlyPlayedListSize, forKey: Self.key_recentlyPlayedListSize)
    }
}
