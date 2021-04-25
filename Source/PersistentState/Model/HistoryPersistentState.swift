import Foundation

class HistoryPersistentState: PersistentStateProtocol {
    
    let recentlyAdded: [HistoryItemPersistentState]?
    let recentlyPlayed: [HistoryItemPersistentState]?
    
    init(recentlyAdded: [HistoryItemPersistentState], recentlyPlayed: [HistoryItemPersistentState]) {
        
        self.recentlyAdded = recentlyAdded
        self.recentlyPlayed = recentlyPlayed
    }
    
    required init?(_ map: NSDictionary) {
        
        self.recentlyAdded = map.arrayValue(forKey: "recentlyAdded", ofType: HistoryItemPersistentState.self)
        self.recentlyPlayed = map.arrayValue(forKey: "recentlyPlayed", ofType: HistoryItemPersistentState.self)
    }
}

class HistoryItemPersistentState: PersistentStateProtocol {
    
    let file: URL
    let name: String
    let time: Date
    
    init(file: URL, name: String, time: Date) {
        
        self.file = file
        self.name = name
        self.time = time
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let file = map.urlValue(forKey: "file"),
              let name = map.stringValue(forKey: "name"),
              let time = map.dateValue(forKey: "time") else {return nil}
        
        self.file = file
        self.name = name
        self.time = time
    }
}

extension HistoryDelegate: PersistentModelObject {
    
    var persistentState: HistoryPersistentState {
        
        let recentlyAdded = allRecentlyAddedItems().map {HistoryItemPersistentState(file: $0.file, name: $0.displayName, time: $0.time)}
        let recentlyPlayed = allRecentlyPlayedItems().map {HistoryItemPersistentState(file: $0.file, name: $0.displayName, time: $0.time)}
        
        return HistoryPersistentState(recentlyAdded: recentlyAdded, recentlyPlayed: recentlyPlayed)
    }
}
