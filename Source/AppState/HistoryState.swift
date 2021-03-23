import Foundation

class HistoryState: PersistentState {
    
    var recentlyAdded: [(file: URL, name: String, time: Date)] = [(file: URL, name: String, time: Date)]()
    var recentlyPlayed: [(file: URL, name: String, time: Date)] = [(file: URL, name: String, time: Date)]()
    
    static func deserialize(_ map: NSDictionary) -> HistoryState {
        
        let state = HistoryState()
        
        if let recentlyAdded = map["recentlyAdded"] as? [NSDictionary] {
            recentlyAdded.forEach({if let item = deserializeHistoryItem($0) {state.recentlyAdded.append(item)}})
        }
        
        if let recentlyPlayed = map["recentlyPlayed"] as? [NSDictionary] {
            recentlyPlayed.forEach({if let item = deserializeHistoryItem($0) {state.recentlyPlayed.append(item)}})
        }
        
        return state
    }
    
    private static func deserializeHistoryItem(_ map: NSDictionary) -> (file: URL, name: String, time: Date)? {
        
        if let file = map["file"] as? String, let name = map["name"] as? String, let timestamp = map["time"] as? String {
            return (URL(fileURLWithPath: file), name, Date.fromString(timestamp))
        }
        
        return nil
    }
}

extension HistoryDelegate: PersistentModelObject {
    
    var persistentState: HistoryState {
        
        let state = HistoryState()
        
        allRecentlyAddedItems().forEach({state.recentlyAdded.append(($0.file, $0.displayName, $0.time))})
        allRecentlyPlayedItems().forEach({state.recentlyPlayed.append(($0.file, $0.displayName, $0.time))})
        
        return state
    }
}
