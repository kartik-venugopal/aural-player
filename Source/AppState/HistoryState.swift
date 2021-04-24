import Foundation

class HistoryState: PersistentStateProtocol {
    
    let recentlyAdded: [HistoryItemState]?
    let recentlyPlayed: [HistoryItemState]?
    
    init(recentlyAdded: [HistoryItemState], recentlyPlayed: [HistoryItemState]) {
        
        self.recentlyAdded = recentlyAdded
        self.recentlyPlayed = recentlyPlayed
    }
    
    required init?(_ map: NSDictionary) {
        
        self.recentlyAdded = map.arrayValue(forKey: "recentlyAdded", ofType: HistoryItemState.self)
        self.recentlyPlayed = map.arrayValue(forKey: "recentlyPlayed", ofType: HistoryItemState.self)
    }
}

class HistoryItemState: PersistentStateProtocol {
    
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
    
    var persistentState: HistoryState {
        
        let recentlyAdded = allRecentlyAddedItems().map {HistoryItemState(file: $0.file, name: $0.displayName, time: $0.time)}
        let recentlyPlayed = allRecentlyPlayedItems().map {HistoryItemState(file: $0.file, name: $0.displayName, time: $0.time)}
        
        return HistoryState(recentlyAdded: recentlyAdded, recentlyPlayed: recentlyPlayed)
    }
}
