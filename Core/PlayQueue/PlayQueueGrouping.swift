import Foundation

//class PlayQueueGroup: Group<String, Track> {}
//
//class PlayQueueGrouping: Grouping<String, Track> {}
//
//class PlayQueueGenericGrouping: PlayQueueGrouping {
//    
//    private let keyFunction: (Track) -> String
//    
//    private let givenId: String
//    override var id: String {givenId}
//    
//    init(id: String, keyFunction: @escaping (Track) -> String) {
//        
//        self.givenId = id
//        self.keyFunction = keyFunction
//    }
//    
//    override func keyForItem(_ item: Track) -> String {
//        return keyFunction(item)
//    }
//}
//
//class PlayQueueArtistGrouping: Grouping<String, Track> {
//    
//    private static let defaultKey: String = "<Unknown Artist>"
//    
//    override var id: String {"playQueue_artists"}
//    
//    override func keyForItem(_ item: Track) -> String {
//        return item.artist ?? Self.defaultKey
//    }
//}
//
//class PlayQueueAlbumGrouping: PlayQueueGrouping {
//    
//    private static let defaultKey: String = "<Unknown Album>"
//    
//    override var id: String {"playQueue_albums"}
//    
//    override func keyForItem(_ item: Track) -> String {
//        return item.album ?? Self.defaultKey
//    }
//}
//
//class PlayQueueGenreGrouping: PlayQueueGrouping {
//    
//    private static let defaultKey: String = "<Unknown Genre>"
//    
//    override var id: String {"playQueue_genres"}
//    
//    override func keyForItem(_ item: Track) -> String {
//        return item.genre ?? Self.defaultKey
//    }
//}
