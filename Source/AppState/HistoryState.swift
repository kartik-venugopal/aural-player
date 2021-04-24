import Foundation

class HistoryState: PersistentStateProtocol {
    
    var recentlyAdded: [HistoryItemState] = []
    var recentlyPlayed: [HistoryItemState] = []
    
    required init?(_ map: NSDictionary) -> HistoryState {
        
        let state = HistoryState()
        
        if let recentlyAddedArr = map["recentlyAdded"] as? [NSDictionary] {
            state.recentlyAdded = recentlyAddedArr.compactMap {HistoryItemState.deserialize($0)}
        }
        
        if let recentlyPlayedArr = map["recentlyPlayed"] as? [NSDictionary] {
            state.recentlyPlayed = recentlyPlayedArr.compactMap {HistoryItemState.deserialize($0)}
        }
        
        return state
    }
}

struct HistoryItemState {
    
    let file: URL
    let name: String
    let time: Date
    
    required init?(_ map: NSDictionary) -> HistoryItemState? {
        
        if let file = map["file"] as? String, let name = map["name"] as? String, let timestamp = map["time"] as? String {
            return HistoryItemState(file: URL(fileURLWithPath: file), name: name, time: Date.fromString(timestamp))
        }
        
        return nil
    }
}

extension HistoryDelegate: PersistentModelObject {
    
    var persistentState: HistoryState {
        
        let state = HistoryState()
        
        state.recentlyAdded = allRecentlyAddedItems().map {HistoryItemState(file: $0.file, name: $0.displayName, time: $0.time)}
        state.recentlyPlayed = allRecentlyPlayedItems().map {HistoryItemState(file: $0.file, name: $0.displayName, time: $0.time)}
        
        return state
    }
}
